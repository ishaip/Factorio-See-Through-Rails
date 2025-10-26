-- Elevated rail entity types
local elevated_rail_types = {
    "elevated-straight-rail",
    "elevated-curved-rail-a",
    "elevated-curved-rail-b",
    "elevated-half-diagonal-rail"
}

-- Helper function to get base entity name (removes "transparent-" prefix)
local function get_base_name(name)
    return name:gsub("^transparent%-", "")
end

-- Helper function to check if entity is handled by this mod
local function is_handled_entity(entity)
    if not entity or not entity.valid then
        return false
    end
    
    local base_name = get_base_name(entity.name)
    
    -- Check if it's an elevated rail
    for _, rail_type in pairs(elevated_rail_types) do
        if base_name == rail_type then
            return true
        end
    end
    
    -- Check if it's a rail-ramp or rail-support
    if base_name == "rail-ramp" or base_name == "rail-support" then
        return true
    end
    
    return false
end

-- Helper function to check if a value exists in an array
local function array_has_value(array, value)
    for _, item in pairs(array) do
        if item == value then
            return true
        end
    end
    return false
end

-- Initialize storage
local function init()
    if not storage.rails_transparent then
        storage.rails_transparent = false
    end
    if not storage.retry_on_tick then
        storage.retry_on_tick = {}
    end
end

-- Configuration changed handler
script.on_configuration_changed(function()
    init()
end)

-- Init handler
script.on_init(function()
    init()
end)

-- Function to replace a single entity with its transparent/normal variant
local function replace_rail(surface, entity, to_transparent, retry)
    if not entity or not entity.valid then
        return
    end
    
    -- Check if entity is one we handle
    if not is_handled_entity(entity) then
        return
    end
    
    -- Don't replace rails if trains are in the rail block (only applies to rails, not ramps/supports)
    local base_name = get_base_name(entity.name)
    local is_rail = false
    for _, rail_type in pairs(elevated_rail_types) do
        if base_name == rail_type then
            is_rail = true
            break
        end
    end
    
    -- Check for trains on rails - use a larger search radius to catch trains on connected rails
    if is_rail then
        -- Check if there are any trains within a reasonable radius (to catch long trains)
        local nearby_trains = surface.find_entities_filtered{
            position = entity.position,
            radius = 2,
            type = "locomotive"
        }
        
        -- Also check cargo wagons and artillery wagons
        local nearby_wagons = surface.find_entities_filtered{
            position = entity.position,
            radius = 2,
            type = {"cargo-wagon", "fluid-wagon", "artillery-wagon"}
        }
        
        if #nearby_trains > 0 or #nearby_wagons > 0 then
            -- Schedule retry
            if not storage.retry_on_tick then
                init()
            end
            local retry_tick = game.tick + 60 -- Retry in 1 second
            if not storage.retry_on_tick[retry_tick] then
                storage.retry_on_tick[retry_tick] = {}
            end
            local retry_data = {
                surface = surface,
                entity = entity,
                to_transparent = to_transparent,
                retry = (retry or 0) + 1
            }
            table.insert(storage.retry_on_tick[retry_tick], retry_data)
            return
        end
    end
    
    -- Check for trains near rail ramps (within 5 tiles)
    if base_name == "rail-ramp" then
        local nearby_trains = surface.find_entities_filtered{
            position = entity.position,
            radius = 10,
            type = "locomotive"
        }
        local nearby_wagons = surface.find_entities_filtered{
            position = entity.position,
            radius = 10,
            type = {"cargo-wagon", "fluid-wagon", "artillery-wagon"}
        }
        
        if #nearby_trains > 0 or #nearby_wagons > 0 then
            -- Schedule retry for ramp too
            if not storage.retry_on_tick then
                init()
            end
            local retry_tick = game.tick + 60
            if not storage.retry_on_tick[retry_tick] then
                storage.retry_on_tick[retry_tick] = {}
            end
            local retry_data = {
                surface = surface,
                entity = entity,
                to_transparent = to_transparent,
                retry = (retry or 0) + 1
            }
            table.insert(storage.retry_on_tick[retry_tick], retry_data)
            return
        end
    end
    
    -- Determine the new name
    local new_name
    if to_transparent then
        -- Convert normal rail to transparent
        if entity.name:find("^transparent%-") then
            return -- Already transparent
        end
        new_name = "transparent-" .. entity.name
    else
        -- Convert transparent rail back to normal
        if not entity.name:find("^transparent%-") then
            return -- Already normal
        end
        new_name = entity.name:gsub("^transparent%-", "")
    end
    
    -- Store entity properties
    local pos = entity.position
    local dir = entity.direction
    local quality = entity.quality
    local force = entity.force
    local to_be_deconstructed = entity.to_be_deconstructed()
    
    -- Destroy old entity
    entity.destroy()
    
    -- Create new entity with transparency
    local new_entity = surface.create_entity{
        name = new_name,
        position = pos,
        direction = dir,
        quality = quality,
        force = force,
        raise_built = false
    }
    
    if not new_entity then
        game.print("[Elevated Rail Transparency] Error: Could not replace rail at position [gps=" .. pos.x .. "," .. pos.y .. "," .. surface.name .. "]")
    else
        -- Restore deconstruction order if it existed
        if to_be_deconstructed then
            new_entity.order_deconstruction(force)
        end
    end
end

-- Function to toggle transparency for all elevated rails, ramps, and supports on all surfaces
local function toggle_all_rails()
    storage.rails_transparent = not storage.rails_transparent
    local to_transparent = storage.rails_transparent
    
    -- Process all surfaces
    for _, surface in pairs(game.surfaces) do
        local all_entities = {}
        
        -- Search for each rail type
        local rail_types = {
            "elevated-straight-rail",
            "elevated-curved-rail-a", 
            "elevated-curved-rail-b",
            "elevated-half-diagonal-rail"
        }
        
        for _, rail_type in pairs(rail_types) do
            local rails = surface.find_entities_filtered{
                type = rail_type
            }
            for _, rail in pairs(rails) do
                table.insert(all_entities, rail)
            end
        end
        
        -- Search for rail ramps
        local ramps = surface.find_entities_filtered{
            type = "rail-ramp"
        }
        for _, ramp in pairs(ramps) do
            table.insert(all_entities, ramp)
        end
        
        -- Search for rail supports
        local supports = surface.find_entities_filtered{
            type = "rail-support"
        }
        for _, support in pairs(supports) do
            table.insert(all_entities, support)
        end
        
        -- Replace each entity
        for _, entity in pairs(all_entities) do
            replace_rail(surface, entity, to_transparent)
        end
    end
    
    -- Update all player shortcut toggle states
    for _, player in pairs(game.players) do
        player.set_shortcut_toggled("toggle-elevated-rail-transparency", storage.rails_transparent)
    end
    
    -- Print message to all players
    if storage.rails_transparent then
        game.print({"message.elevated-rails-transparent"})
    else
        game.print({"message.elevated-rails-normal"})
    end
end

-- Handle shortcut button press
script.on_event(defines.events.on_lua_shortcut, function(event)
    if event.prototype_name == "toggle-elevated-rail-transparency" then
        toggle_all_rails()
    end
end)

-- Handle retries for rails that had trains blocking
script.on_event(defines.events.on_tick, function(event)
    if not storage.retry_on_tick then
        init()
        return
    end
    
    if storage.retry_on_tick[event.tick] then
        for _, retry_data in pairs(storage.retry_on_tick[event.tick]) do
            if retry_data.entity and retry_data.entity.valid then
                -- Only retry a limited number of times (15 retries = 15 seconds)
                if not retry_data.retry or retry_data.retry < 15 then
                    replace_rail(retry_data.surface, retry_data.entity, retry_data.to_transparent, retry_data.retry)
                end
            end
        end
        storage.retry_on_tick[event.tick] = nil
    end
end)

-- Update shortcut toggle state for new players
script.on_event(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index)
    if player then
        player.set_shortcut_toggled("toggle-elevated-rail-transparency", storage.rails_transparent or false)
    end
end)

-- Handle newly built elevated rails, ramps, and supports
local function on_rail_built(event)
    if not storage.rails_transparent then
        return
    end
    
    local entity = event.entity or event.created_entity
    if not entity or not entity.valid then
        return
    end
    
    -- Handle ghost entities (blueprints, copy-paste, etc)
    if entity.name == "entity-ghost" then
        local ghost_name = entity.ghost_name
        
        -- Check if this is a transparent variant ghost
        if ghost_name and ghost_name:find("^transparent%-") then
            -- Replace with normal (non-transparent) ghost
            local normal_name = ghost_name:gsub("^transparent%-", "")
            local surface = entity.surface
            local position = entity.position
            local force = entity.force
            local direction = entity.direction
            local quality = entity.quality
            local player_index = event.player_index
            
            entity.destroy()
            
            surface.create_entity{
                name = "entity-ghost",
                inner_name = normal_name,
                position = position,
                force = force,
                direction = direction,
                quality = quality,
                player = player_index,
                create_build_effect_smoke = false
            }
        end
        return
    end
    
    -- Check if it's an entity we handle
    if is_handled_entity(entity) then
        replace_rail(entity.surface, entity, true)
    end
end

script.on_event(defines.events.on_built_entity, on_rail_built)
script.on_event(defines.events.on_robot_built_entity, on_rail_built)
script.on_event(defines.events.script_raised_built, on_rail_built)
