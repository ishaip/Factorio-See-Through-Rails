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

-- Calculate alpha value from transparency setting (0-100 becomes 1.0-0.0)
local transparency_percent = settings.startup["rail-transparency"].value
local alpha = (100 - transparency_percent) / 100
local tint = {alpha, alpha, alpha, alpha}

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
                                    layer.tint = tint
                                end
                            else
                                target.tint = tint
                            end
                        end
                    end
                end
            end
        end
        
        -- Remove fence pictures and make non-selectable
        transparent_rail.fence_pictures = nil
        transparent_rail.selectable_in_game = false
        
        -- Extend data with the transparent variant
        data:extend({transparent_rail})
    else
        log("Warning: Could not find rail prototype for " .. rail_name)
    end
end