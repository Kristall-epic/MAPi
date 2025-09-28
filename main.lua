--name: Hangout select
--description: let's you warp into custom levels using api
-- pausable: false
gLevelValues.fixCollisionBugs = true

curBGM = nil
curLevel = 1
gGlobalSyncTable.canWarp = true

local prevCG = get_texture_info("prev_cg")
local prevCMF = get_texture_info("prev_cmf")

_G.MAPi_Active = true

mapTable = {

  [1] = {
    source = LEVEL_CASTLE_GROUNDS,
    name = "Castle Grounds",
    description = {
      "The starting area of the game!",
      "walk around or go directly",
      "into the castle to kick off this",
      "adventure!"
    },
    credit = "Nintendo",
    prev = prevCG,
    sound = nil,
    bgm = nil,
    skybox = {nil},
  },
  [2] = {
    source = LEVEL_CASTLE,
    name = "Castle Main Floor",
    description = {
      "Princess Peach's castle",
      "i don't really know what",
      "to say here =dsjzgwkd:xig",
      "HELLO THIS IS A VERY LONG DESCRIPTION LINE I THINK IT EVEN GOES BEYOND THE SCREEN WAIT THEN YOU WOULDN'T BE ABLE TO READ THIS",
    },
    credit = "Nintendo",
    prev = prevCMF,
    sound = nil,
    bgm = nil,
    skybox = {nil},
  },
  
}

nuhuhdontusethatone = {
  [1] = true,
  [2] = true,
  [3] = true,
  [32] = true,
  [35] = true,
  [37] = true,
  [38] = true,
  [39] = true,
}

function warp_to_hangout(mapID, actID, warpNode)
  
  if gNetworkPlayers[0] then
    if mapTable[tonumber(mapID)] == nil then
      djui_popup_create("This map does not Exist!", 1)
      return true
    end
    if curBGM ~= nil then
      audio_stream_stop(curBGM)
      curBGM = nil
    end
    if nuhuhdontusethatone[mapTable[tonumber(mapID)].source] then
      djui_popup_create("This map does not Exist!", 1)
      return true
        else
          warp_to_warpnode(mapTable[tonumber(mapID)].source, 1, actID or 1, warpNode or 0x0A)
        curLevel = tonumber(mapID)
        djui_popup_create_global(gNetworkPlayers[0].name.."\\#dcdcdc\\ entered \\#ffffff\\"..mapTable[mapID].name.."\\#dcdcdc\\, Act \\#ffffff\\#"..tostring(actID), 2)
        end
       -- djui_chat_message_create(       tostring(mapTable[tonumber(mapID)].source).." "..tostring(mapTable[tonumber(mapID)].name).." "..tostring(mapTable[tonumber(mapID)].credit)  )
        return true
    end
  
end

local function custom_hangout_bgm(m, seq)

if gMarioStates[0].playerIndex == 0 then
  if curBGM ~= nil and seq == get_current_background_music() then
return 0
end
end
end

hook_event(HOOK_ON_SEQ_LOAD, custom_hangout_bgm)

local function before_warp()
  
  if curBGM ~= nil then
      audio_stream_stop(curBGM)
      curBGM = nil
  end
  
end

hook_event(HOOK_BEFORE_WARP, before_warp)


local function on_warp()
  
  local l = gLakituState
    local skyboxcheck = obj_get_nearest_object_with_behavior_id(o, id_bhvmapiskybox)
    local p = gNetworkPlayers[0]
    if skyboxcheck == nil and mapTable[curLevel].skybox ~= {nil} and (_G.MAPi.get_levelnum_from_hangout(curLevel) ~= nil and gNetworkPlayers[0].currLevelNum == _G.MAPi.get_levelnum_from_hangout(curLevel)) then
      local sky = mapTable[curLevel].skybox
      if sky[p.currAreaIndex] ~= nil then
      if sky[p.currAreaIndex].skytype == "ico" then
        spawn_non_sync_object(id_bhvmapiskybox, E_MODEL_SKYBOX_CUSTOM_ICO, l.pos.x, l.pos.y, l.pos.z, nil)
      elseif sky[p.currAreaIndex].skytype == "box" then
        spawn_non_sync_object(id_bhvmapiskybox, E_MODEL_SKYBOX_CUSTOM_BOX, l.pos.x, l.pos.y, l.pos.z, nil)
      end
      replace_skybox(sky, p)
      end
    end
  
  if curBGM ~= nil then
    audio_stream_stop(curBGM)
    end
  
if gNetworkPlayers[0].currLevelNum == _G.MAPi.get_levelnum_from_hangout(curLevel) and mapTable[curLevel].bgm ~= nil then
  if type(mapTable[curLevel].bgm) == "table" then
    for i, bgm in pairs(mapTable[curLevel].bgm) do
    if i == gNetworkPlayers[0].currAreaIndex then
    stop_background_music(get_current_background_music())
    audio_stream_play(bgm, false, 1)
    audio_stream_set_looping(bgm, true)
    curBGM = bgm
    end
    end
    else
      stop_background_music(get_current_background_music())
      if curBGM ~= nil then
    audio_stream_stop(curBGM)
    end
    audio_stream_play(mapTable[curLevel].bgm, false, 1)
    audio_stream_set_looping(mapTable[curLevel].bgm, true)
    curBGM = mapTable[curLevel].bgm
    end
   -- djui_chat_message_create(tostring(gNetworkPlayers[0].currAreaIndex))

end
end

hook_event(HOOK_ON_WARP, on_warp)

local function what_maps()
  
  for _, data in pairs(mapTable) do
    djui_chat_message_create(tostring(_).. " -".. tostring(data.name))
end
  
  return true
end

local function tp_everyone_level()
  network_send(true, {
        entered_level = curLevel,
        entered_act = gNetworkPlayers[0].currActNum
    })
  return true
end

local function mapi_warp_command(msg) 
  local map = tonumber(msg) or 1
  if gNetworkPlayers[0] then
    if mapTable[map] == nil then
      djui_popup_create("This map does not Exist!", 1)
      return false
    end
    end
  
  if network_is_server() or gGlobalSyncTable.canWarp == true then
  if mapTable[map].sound ~= nil then
    audio_sample_play(mapTable[map].sound, gMarioStates[0].pos, 3)
  end
  if nuhuhdontusethatone[_G.MAPi.get_levelnum_from_hangout(map)] then
    djui_popup_create("This map does not Exist!", 1)
    return true
    else
      warp_to_hangout(map, 1, (map == 2 and 0x20 or map == 1 and 0xFF) or 0x0A)
      return true
  end
  end
  
  
  end

local function toggle_warping(msg)
  
  if msg == "true" then
    gGlobalSyncTable.canWarp = true
    djui_popup_create_global("Host toggled MAPi warping on!", 2)
    return true
  elseif msg == "false" then
    gGlobalSyncTable.canWarp = false
    djui_popup_create_global("Host toggled MAPi warping off!", 2)
    return true
    else
      gGlobalSyncTable.canWarp = not gGlobalSyncTable.canWarp
      if gGlobalSyncTable.canWarp == true then
    djui_popup_create_global("Host toggled MAPi warping on!", 2)
    else
      djui_popup_create_global("Host toggled MAPi warping off!", 2)
      end
      return true
  end
  
  end

function packet_receive(data_table)
    -----@type NetworkPlayer
    --gNetworkPlayers[0] = gNetworkPlayers[0]
    if data_table.entered_level ~= nil then
    local entered_level = data_table.entered_level
    local entered_act = data_table.entered_act
    if gNetworkPlayers[0].currLevelNum ~= entered_level or
       gNetworkPlayers[0].currActNum ~= entered_act then
        warp_to_hangout(entered_level, entered_act)
       end
    end

end
hook_event(HOOK_ON_PACKET_RECEIVE, packet_receive)

if network_is_server() then
  hook_chat_command("mapi-warp-all", "- Warps everyone to your current level", tp_everyone_level)
  hook_chat_command("mapi-toggle-warps", " [true / false] - Toggles if other players should be able to warp using the MAPi menu", toggle_warping)
  end

hook_chat_command("maps", "- shows currently available maps", what_maps)
hook_chat_command("mapi-warp", "- warps to a map on maptable", mapi_warp_command)