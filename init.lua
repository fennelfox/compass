local waypointPositions = {}
local playerWaypoints = {}
local validParams = {"circle", "square", "triangle", "house", "pickaxe", "star"}
local colors = {
    circle = 0xcb2121,
    square = 0x269a1d,
    triangle = 0xd6d223,
    house = nil,
    pickaxe = nil,
    star = nil
}
local modMeta = minetest.get_mod_storage()


local function reregister_waypoints(name)
    for i=1,6 do
        local key = validParams[i]
        local metaTable = modMeta:to_table()
        local pos = nil
        
        if metaTable[name][key] ~= nil then
            pos = metaTable[name][key]
        end
        
        if pos ~= nil then
        
            playerWaypoints[name][key] = player:hud_add({
                hud_elem_type = "waypoint",
                --name = param,
                --text = param,
                precision = 10,
                world_pos = pos,
                number = colors[key],
            })
                
            playerWaypoints[name][key .. "_image"] = player:hud_add({
                hud_elem_type = "image_waypoint",
                offset = {x = 0, y = -8},
                name = key .. "_image",
                text = "marker_" .. key .. ".png",
                --size = { x = 1, y = 1},
                scale = { x = 1, y = 1},
                alignment = { x = 0, y = 0 },
                z_index = 0,
                --direction = 2
                world_pos = pos,  
            })
        end
    end
end

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    playerWaypoints[name] = {}
    
    waypointPositions[name] = {
        circle = nil,
        square = nil,
        triangle = nil,
        house = nil,
        pickaxe = nil,
        star = nil
    }
    
    --local waypointsMeta = modMeta:to_table()
    
    --if waypointsMeta ~= nil then
    --    waypointPositions = waypointsMeta
    --    reregister_waypoints(name)
    --end

    playerWaypoints[name]["compass"] = player:hud_add({
            hud_elem_type = "compass",
            position = {x = 0.5, y = 0},
            offset = {x = 0, y = 32},
            text = "compass.png",
            size = { x = 650, y = 32},
            scale = { x = 1, y = 1},
            alignment = { x = 0, y = 0 },
            z_index = 0,
            direction = 2
        })

        playerWaypoints[name]["compass_reticle"] = player:hud_add({
            hud_elem_type = "image",
            position = {x = 0.5, y = 0},
            offset = {x = 0, y = 32},
            text = "compass_reticle.png",
            --size = { x = 1, y = 1},
            scale = { x = 1, y = 1},
            alignment = { x = 0, y = 0 },
            z_index = 0,
            --direction = 2
        })

    
end)

minetest.register_chatcommand("wpadd", {

    params = "<1-6> | circle | square | triangle | house | pickaxe | star",
    
    description = "Adds a waypoint with an icon indicator.",

    func = function(name, param)

        local isValid = false

        if tonumber(param) ~= nil then
            param = validParams[tonumber(param)]
        end
        
        for i, v in pairs(validParams) do
            if v == param then
                isValid = true
            end
        end
        
        if isValid then
            local player = minetest.get_player_by_name(name)
            local pos = player:get_pos()
            
            if playerWaypoints[name][param] ~= nil then
                player:hud_remove(playerWaypoints[name][param])
                player:hud_remove(playerWaypoints[name][param .. "_image"])
            end

            playerWaypoints[name][param] = player:hud_add({
                hud_elem_type = "waypoint",
                --name = param,
                --text = param,
                precision = 10,
                world_pos = pos,
                number = colors[param],
            })
                
            playerWaypoints[name][param .. "_image"] = player:hud_add({
                hud_elem_type = "image_waypoint",
                offset = {x = 0, y = -8},
                name = param .. "_image",
                text = "marker_" .. param .. ".png",
                --size = { x = 1, y = 1},
                scale = { x = 1, y = 1},
                alignment = { x = 0, y = 0 },
                z_index = 0,
                --direction = 2
                world_pos = pos,  
            })
                
            waypointPositions[name][param] = pos

            return true, "Waypoint created."
        else
            return false, "Invalid icon name."
        end
    end
})

minetest.register_globalstep(function()
    for _,player in pairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local positions = waypointPositions[name]
        local waypointTextures = ""
        local objectTextures = ""
        local playerTextures = ""
        local playerPos = player:get_pos()

        for i=1,6 do
            local idx = validParams[i]
            if waypointPositions[name][idx] ~= nil then
                local v = waypointPositions[name][idx]
                local x = v.x - playerPos.x
                local z = v.z - playerPos.z
                local arctan = math.atan2(x, z)
                local angle = math.deg(arctan)
                local distance = math.sqrt((x)^2 + (z)^2)

                angle = angle + 180

                if angle < 0 then
                        
                    angle = 360 + angle

                end


                -- minetest.chat_send_all(" " .. distance)

                local markerX = (angle * 5.33333) - 8
                local size = ""
                local markerY = 0
                if distance > 100 then
                    size = "2"
                    markerX = markerX + 4
                    markerY = 4
                end
                
                waypointTextures = waypointTextures .. ":" .. markerX .. "," .. markerY .. "=marker_" .. validParams[i] .. size .. ".png"
            end
        end


            for i,v in pairs(minetest.get_objects_inside_radius(playerPos, 100)) do
                
                if not v == nil then

                    local vPos = v:get_pos()
                    local x = vPos.x - playerPos.x
                    local z = vPos.z - playerPos.z

                    local arctan = math.atan2(x, z)
                    local angle = math.deg(arctan)

                    angle = angle + 180

                    if angle < 0 then
                        
                        angle = 360 + angle

                    end

                    --minetest.get_objects_inside_radius(pos, radius)

                    --minetest.chat_send_all(" " .. angle .. "    z " .. z .. "     x " .. x)

                    local markerX = angle * 5.333333333        
                    
                    objectTextures = objectTextures .. ":" .. markerX .. ",12=object_marker.png"

                end
            end



        
        local cplayers = minetest.get_connected_players()
        for i,v in pairs(cplayers) do
            
            if minetest.is_player(v) then
                
                local playerPos = player:get_pos()
                local vPos = v:get_pos()
                local x = vPos.x - playerPos.x
                local z = vPos.z - playerPos.z

                local arctan = math.atan2(x, z)
                local angle = math.deg(arctan)

                angle = angle + 180

                if angle < 0 then
                    
                    angle = 360 + angle

                end

                --minetest.get_objects_inside_radius(pos, radius)

                --minetest.chat_send_all(" " .. angle .. "    z " .. z .. "     x " .. x)

                local markerX = angle * 5.333333333        
                
                playerTextures = playerTextures .. ":" .. markerX .. ",0=player_marker.png"

            end
        
        
        player:hud_change(playerWaypoints[name]["compass"], "text", "[combine:1920x32:0,0=compass.png" .. waypointTextures .. objectTextures)

        end
    end
end)

minetest.register_on_shutdown(function()
    local meta = modMeta:to_table()
    meta.list = playerWaypoints
    modMeta:from_table(meta)
end)