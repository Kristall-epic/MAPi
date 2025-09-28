
function check_players_in_hangout(mapID)
    local level = mapTable[mapID].source
    local plr = 0

    for _, player in pairs(gNetworkPlayers) do
        if player.connected and player.currLevelNum == level then
            plr = plr + 1
        end
    end

    return plr
end

function check_players_hangout_per_act(mapID)
  local level = mapTable[mapID].source
  local plr = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
  }
  
  for _, player in pairs(gNetworkPlayers) do
        if player.connected and player.currLevelNum == level and player.currActNum > 0 then
              plr[player.currActNum] = plr[player.currActNum] + 1
        end
  end
  
  return plr
  end

function lerp(a, b, t)
    return a * (1 - t) + b * t
end

function replace_skybox(sky, p)
texture_override_set("Custom_Skybox_Icosphere_cloud_floor_rgba16", sky[p.currAreaIndex].front or prevNone)
        if sky[p.currAreaIndex].skytype == "box" then
        texture_override_set("Custom_Skybox_Cube_skyast_up_rgba16", sky[p.currAreaIndex].up or prevNone)
        texture_override_set("Custom_Skybox_Cube_skyast_lf_rgba16", sky[p.currAreaIndex].left or prevNone)
        texture_override_set("Custom_Skybox_Cube_skyast_dn_rgba16", sky[p.currAreaIndex].down or prevNone)
        texture_override_set("Custom_Skybox_Cube_skyast_rt_rgba16", sky[p.currAreaIndex].right or prevNone)
        texture_override_set("Custom_Skybox_Cube_skyast_bk_rgba16", sky[p.currAreaIndex].back or prevNone)
       texture_override_set("Custom_Skybox_Cube_skyast_ft_rgba16", sky[p.currAreaIndex].front or prevNone)
        end
        
        end