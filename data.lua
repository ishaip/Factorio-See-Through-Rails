require("prototypes.shortcuts")

-- Elevated rail entity types and their names
local elevated_rail_types = {
    "elevated-straight-rail",
    "elevated-curved-rail-a",
    "elevated-curved-rail-b",
    "elevated-half-diagonal-rail"
}

-- Direction names for rail sprites
local directions = {
    "north", "northeast", "east", "southeast",
    "south", "southwest", "west", "northwest"
}

-- Picture components to make transparent
local picture_components = {
    "metals", "backplates", "ties", "stone_path",
    "stone_path_background", "segment_visualisation_middle",
    "water_reflection", "underwater_structure"
}

-- Calculate alpha values from transparency settings (0-100 becomes 1.0-0.0)
local rail_transparency_percent = settings.startup["rail-transparency"].value
local rail_alpha = (100 - rail_transparency_percent) / 100
local rail_tint = {rail_alpha, rail_alpha, rail_alpha, rail_alpha}
local rail_selectable = (rail_transparency_percent < 100)

local support_transparency_percent = settings.startup["support-transparency"].value
local support_alpha = (100 - support_transparency_percent) / 100
local support_tint = {support_alpha, support_alpha, support_alpha, support_alpha}
local support_selectable = (support_transparency_percent < 100)

-- Helper function to apply tint recursively to any structure
local function apply_tint_recursive(obj, tint)
    if not obj then return end
    
    if type(obj) == "table" then
        -- Check if this is a layer or sprite with tint support
        if obj.filename or obj.filenames then
            obj.tint = tint
        end
        
        -- Recursively apply to all table contents
        for key, value in pairs(obj) do
            if type(value) == "table" and key ~= "tint" then
                apply_tint_recursive(value, tint)
            end
        end
    end
end

-- Create transparent variants of each elevated rail type
for _, rail_name in pairs(elevated_rail_types) do
    -- Try to find the rail prototype in different type categories
    local rail_prototype = nil
    local rail_type = nil
    
    -- Check all possible rail types
    if data.raw["elevated-straight-rail"] and data.raw["elevated-straight-rail"][rail_name] then
        rail_prototype = data.raw["elevated-straight-rail"][rail_name]
        rail_type = "elevated-straight-rail"
    elseif data.raw["elevated-curved-rail-a"] and data.raw["elevated-curved-rail-a"][rail_name] then
        rail_prototype = data.raw["elevated-curved-rail-a"][rail_name]
        rail_type = "elevated-curved-rail-a"
    elseif data.raw["elevated-curved-rail-b"] and data.raw["elevated-curved-rail-b"][rail_name] then
        rail_prototype = data.raw["elevated-curved-rail-b"][rail_name]
        rail_type = "elevated-curved-rail-b"
    elseif data.raw["elevated-half-diagonal-rail"] and data.raw["elevated-half-diagonal-rail"][rail_name] then
        rail_prototype = data.raw["elevated-half-diagonal-rail"][rail_name]
        rail_type = "elevated-half-diagonal-rail"
    end
    
    if rail_prototype and rail_type then
        -- Create a deep copy of the rail prototype
        local transparent_rail = table.deepcopy(rail_prototype)
        transparent_rail.name = "transparent-" .. rail_name
        transparent_rail.type = rail_type
        
        -- Apply transparency tint to all picture components
        if transparent_rail.pictures then
            for _, direction in pairs(directions) do
                if transparent_rail.pictures[direction] then
                    for _, component in pairs(picture_components) do
                        local target = transparent_rail.pictures[direction][component]
                        if target then
                            if target.layers then
                                for _, layer in pairs(target.layers) do
                                    layer.tint = rail_tint
                                end
                            else
                                target.tint = rail_tint
                            end
                        end
                    end
                end
            end
        end
        
        -- Remove fence pictures and set selectability based on transparency
        transparent_rail.fence_pictures = nil
        transparent_rail.selectable_in_game = rail_selectable
        
        -- Extend data with the transparent variant
        data:extend({transparent_rail})
    else
        log("Warning: Could not find rail prototype for " .. rail_name)
    end
end

-- Create transparent variant of rail-ramp
if data.raw["rail-ramp"] and data.raw["rail-ramp"]["rail-ramp"] then
    local ramp_prototype = data.raw["rail-ramp"]["rail-ramp"]
    local transparent_ramp = table.deepcopy(ramp_prototype)
    transparent_ramp.name = "transparent-rail-ramp"
    
    -- Apply transparency tint recursively to ALL properties
    -- This ensures we catch every possible graphics property including handles
    for key, value in pairs(transparent_ramp) do
        if type(value) == "table" and key ~= "name" and key ~= "type" then
            apply_tint_recursive(value, support_tint)
        end
    end
    
    -- Set selectability based on transparency
    transparent_ramp.selectable_in_game = support_selectable
    
    data:extend({transparent_ramp})
else
    log("Warning: Could not find rail-ramp prototype")
end

-- Create transparent variant of rail-support
if data.raw["rail-support"] and data.raw["rail-support"]["rail-support"] then
    local support_prototype = data.raw["rail-support"]["rail-support"]
    local transparent_support = table.deepcopy(support_prototype)
    transparent_support.name = "transparent-rail-support"
    
    -- Apply transparency tint recursively to all graphics
    apply_tint_recursive(transparent_support.pictures, support_tint)
    apply_tint_recursive(transparent_support.graphics_set, support_tint)
    
    -- Set selectability based on transparency
    transparent_support.selectable_in_game = support_selectable
    
    data:extend({transparent_support})
else
    log("Warning: Could not find rail-support prototype")
end