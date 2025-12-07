-- name: MAPi
-- description: An API that let's you add and warp to custom levels
-- pausable: false

curBGM = nil
curVolume = 1
VOLUME_PAUSE = 0.35
VOLUME_DEFAULT = 1
VOLUME_MUTE = 0
curLevel = 1
gGlobalSyncTable.canWarp = true
gGlobalSyncTable.warpPopups = true

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
    envtint = {
        [1] = {
          color = {r = 255, g = 255, b = 255},
        dir = {x = 0, y = 0, z = 0}
        }
      },
  },
  [2] = {
    source = LEVEL_CASTLE,
    name = "Castle Main Floor",
    description = {
      "Princess Peach's castle.",
      "The main area of the game,",
    },
    credit = "Nintendo",
    prev = prevCMF,
    sound = nil,
    bgm = nil,
    skybox = {nil},
    envtint = {
        color = {r = 255, g = 255, b = 255},
        dir = {x = 0, y = 0, z = 0}
      },
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
    if mapTable[tonumber(mapID)].source == nil or nuhuhdontusethatone[mapTable[tonumber(mapID)].source] or (level_is_vanilla_level(mapTable[tonumber(mapID)].source) == false and smlua_level_util_get_info(mapTable[tonumber(mapID)].source) == nil) then
      djui_popup_create("This map has an invalid levelNum!", 2)
        else
  
         if curBGM ~= nil then
      audio_stream_stop(curBGM)
      curBGM = nil
    end 
          warp_to_warpnode(mapTable[tonumber(mapID)].source, 1, actID or 1, warpNode or 0x0A)
          Menu = false
if mapTable[mapID].sound ~= nil then
  snd = mapTable[mapID].sound
  if type(snd) == "number" then
    play_sound(snd, gMarioStates[0].pos)
  else
    audio_sample_play(mapTable[mapID].sound, gMarioStates[0].pos, 3)
    end
    end
        curLevel = tonumber(mapID)
        if gGlobalSyncTable.warpPopups == true then
        djui_popup_create_global(gNetworkPlayers[0].name.."\\#dcdcdc\\ entered \\#ffffff\\"..mapTable[mapID].name.."\\#dcdcdc\\, Act \\#ffffff\\#"..tostring(actID), 2)
        end
        end
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
    if skyboxcheck == nil and mapTable[curLevel].skybox ~= {nil} and (MAPi.get_levelnum_from_hangout(curLevel) ~= nil and gNetworkPlayers[0].currLevelNum == MAPi.get_levelnum_from_hangout(curLevel)) then
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
  
if gNetworkPlayers[0].currLevelNum == MAPi.get_levelnum_from_hangout(curLevel) and mapTable[curLevel].bgm ~= nil then
  if type(mapTable[curLevel].bgm) == "table" then
    for i, bgm in pairs(mapTable[curLevel].bgm) do
    if i == gNetworkPlayers[0].currAreaIndex then
    stop_background_music(get_current_background_music())
    curBGM = bgm
    end
    end
    else
      stop_background_music(get_current_background_music())
      if curBGM ~= nil then
    audio_stream_stop(curBGM)
    end
    curBGM = mapTable[curLevel].bgm
    end
end

if gNetworkPlayers[0].currLevelNum == MAPi.get_levelnum_from_hangout(curLevel) and mapTable[curLevel].envtint[p.currAreaIndex] ~= nil then
  local env = mapTable[curLevel].envtint[p.currAreaIndex]
 set_env_tint(env.color, env.dir)
 else
   set_env_tint({r = 255, g = 255, b = 255}, {x = 0,y = 0, z = 0})
end

end

hook_event(HOOK_ON_WARP, on_warp)

function play_custom_bgm(m)
  if m.playerIndex ~= 0 then
    return end
  
  if curBGM ~= nil then
  audio_stream_play(curBGM, false, curVolume)
  audio_stream_set_looping(curBGM, true)
  
  if m.numLives < 0 then
    audio_stream_stop(curBGM)
    curBGM = nil
    end
  
  end
  
  if m.flags & MARIO_WING_CAP ~= 0 or m.flags & MARIO_VANISH_CAP ~= 0 or m.flags & MARIO_METAL_CAP ~= 0 or m.action & ACT_FLAG_RIDING_SHELL ~= 0 then
   curVolume = VOLUME_MUTE
    else 
      if is_game_paused() == true or MAPi.is_menu_open() == true then
        curVolume = VOLUME_PAUSE
        else
      curVolume = VOLUME_DEFAULT
      end
  end
  
end

hook_event(HOOK_MARIO_UPDATE, play_custom_bgm)


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
  local map = tonumber(msg) or 0
  
  if gNetworkPlayers[0] then
    
    if map == 0 then
    debounce = 15
    Menu = true
    game_unpause()
    return true
    end
    
    if mapTable[map] == nil then
      djui_popup_create("This map does not Exist!", 1)
      return true
    end
    end
  
  if network_is_server() or gGlobalSyncTable.canWarp == true then
  if nuhuhdontusethatone[MAPi.get_levelnum_from_hangout(map)] then
    djui_popup_create("This map does not Exist!", 1)
    return true
    else
      play_transition(WARP_TRANSITION_FADE_FROM_BOWSER, 30, 0, 0, 0)
      warp_to_hangout(map, 1, (map == 2 and 0x20 or map == 1 and 0xFF) or 0x0A)
      return true
  end
  else
    djui_popup_create("Warping is disabled by host!", 2)
    return true
  end
  
  
  end

function toggle_warping(ms)
  msg = tostring(ms)
  
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


function toggle_popups(ms)
  msg = tostring(ms)
  
  if msg == "true" then
    gGlobalSyncTable.warpPopups = true
    djui_popup_create_global("MAPi popups have been activated.", 2)
    return true
  elseif msg == "false" then
    gGlobalSyncTable.warpPopups = false
    djui_popup_create_global("MAPi popups have been deactivated.", 2)
    return true
    else
      gGlobalSyncTable.warpPopups = not gGlobalSyncTable.warpPopups
      if gGlobalSyncTable.warpPopups == true then
    djui_popup_create_global("MAPi popups have been activated.", 2)
    else
      djui_popup_create_global("MAPi popups have been deactivated.", 2)
      end
      return true
  end
  
  end


function packet_receive(data_table)
  
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
  hook_chat_command("mapi-warp-all", "- Warps everyone to your current hangout", tp_everyone_level)
  hook_chat_command("mapi-toggle-warps", " [true / false] - Toggles if other players should be able to warp using the MAPi menu", toggle_warping)
  end

hook_chat_command("mapi-maps", "- shows currently available maps from MAPi", what_maps)
hook_chat_command("mapi-warp", "- warps to a currently available hangout map on MAPi or opens the menu", mapi_warp_command)
