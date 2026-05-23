-- name: MAPi!
-- description: A hangout map based API library that lets you add custom levels to a warping menu. Also with the ability of easily adding custom music, skyboxes, and more!
-- pausable: false


bgm = {
  src = nil,
  goalVolume = 1,
  volume = 1
}

warpInfo = {
  ing = false,
  timer = 0,
  info = {
    lvl = 0,
    ar = 0,
    nd = 0
  }
}

VOLUME_PAUSE = 0.25
VOLUME_DEFAULT = 0.85
VOLUME_MUTE = 0.001
curLevel = 1
gGlobalSyncTable.canWarp = true
gGlobalSyncTable.warpPopups = true
gLevelValues.fixCollisionBugs = true
gLevelValues.fixCollisionBugsRoundedCorners = false
IS_ROMHACK = false

local prevCG = get_texture_info("prev_cg")
local prevCMF = get_texture_info("prev_cmf")

_G.MAPi_Active = true

mapTable = {

  [1] = {
    source = gLevelValues.entryLevel,
    name = "Castle Grounds",
    description = "The starting area of the game! Walk around or go directly into the castle to kick off this great adventure!",
    credit = "Nintendo",
    prev = prevCG,
    entrysnd = SOUND_MENU_MARIO_CASTLE_WARP2,
    bgm = nil,
    skybox = {nil},
    envtint = {
        [1] = {
          color = {r = 255, g = 255, b = 255},
        dir = {x = 0, y = 0, z = 0}
        }
      },
    textColor = {r = 255, g = 255, b = 255}
  },
  [2] = {
    source = LEVEL_CASTLE,
    name = "Castle Main Floor",
    description = "Princess Peach's castle. The main area of the game",
    credit = "Nintendo",
    prev = prevCMF,
    entrysnd = SOUND_MENU_MARIO_CASTLE_WARP,
    bgm = nil,
    skybox = {nil},
    envtint = {
        color = {r = 255, g = 255, b = 255},
        dir = {x = 0, y = 0, z = 0}
      },
    textColor = {r = 0xff, g = 0xff, b = 0xff}
  },
  
}

nuhuhdontusethatone = {
  [0] = true,
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
    if mapTable[tonumber(mapID)].source == nil or nuhuhdontusethatone[mapTable[tonumber(mapID)].source] or (mapTable[tonumber(mapID)].source >= 50 and smlua_level_util_get_info(mapTable[tonumber(mapID)].source) == nil) then
      djui_popup_create("This map has an invalid levelNum!", 2)
        else
  
    local warped = warp_to_warpnode(mapTable[tonumber(mapID)].source, 1, actID or 1, warpNode or 0x0A)
    if warped == true then
        close_mapi_menu()
        curLevel = tonumber(mapID)
        if gGlobalSyncTable.warpPopups == true then
          local playerName =  network_get_player_text_color_string(0)..gNetworkPlayers[0].name
          local mapName = "\\#"..string.format("%02X", mapTable[mapID].textColor.r)..string.format("%02X", mapTable[mapID].textColor.g)..string.format("%02X", mapTable[mapID].textColor.b).."\\"..mapTable[mapID].name
          djui_popup_create_global(playerName.."\\#dcdcdc\\ entered "..mapName.."\\#dcdcdc\\, Act \\#ffffff\\#"..tostring(actID), 2)
        end
    else
      djui_popup_create("Failed to warp!", 2)
    end
        end
        return true
    end
  
end

local function custom_hangout_bgm(m, seq)
  if gMarioStates[0].playerIndex == 0 then
    if bgm.src and seq == get_current_background_music() then
        return 0
    end
  end
end

hook_event(HOOK_ON_SEQ_LOAD, custom_hangout_bgm)


local function play_init_sound()
  local mapID = MAPi.get_cur_hangout()
  warpInfo.ing = false
  warpInfo.timer = 0

  if mapID == nil then
  return end

  if mapTable[mapID].entrysnd then
    snd = mapTable[mapID].entrysnd
    if type(snd) == "number" then
      play_sound(snd, gMarioStates[0].pos)
    else
      if snd.isStream == false then
      audio_sample_play(mapTable[mapID].entrysnd, gMarioStates[0].pos, 3)
      end
      end
  end

end

hook_event(HOOK_ON_LEVEL_INIT, play_init_sound)

local function before_warp(lvl, area, node)
  
  if (MAPi.get_cur_hangout()) then
    warpInfo.ing = true
    warpInfo.info = {
      lvl = lvl,
      ar = area,
      nd = node
    }
  end
  
  if bgm.src and (lvl ~= gNetworkPlayers[0].currLevelNum or area ~= gNetworkPlayers[0].currAreaIndex) then
  end
  
  set_env_tint({r = 255, g = 255, b = 255}, {x = 0,y = 0, z = 0})
  
  if not MAPi.get_cur_hangout() then return end
  
  local curMap = mapTable[curLevel]
  
  if lvl == 64 then
    return {
      destLevel = curMap.source,
      destArea = area,
      destNode = node
    }
  end
  
  
  if curMap.codeWarps and curMap.codeWarps[lvl] then
    if MAPi.get_hangout_from_levelnum(curMap.codeWarps[lvl]) then
      curLevel = MAPi.get_hangout_from_levelnum(curMap.codeWarps[lvl])
    end
    
    if curMap.codeWarps[lvl] == gNetworkPlayers[0].currLevelNum then
      return {
        destLevel = curMap.codeWarps[lvl],
        destArea = area,
        destNode = node
      }
    else
      warp_to_warpnode(curMap.codeWarps[lvl], area, gNetworkPlayers[0].currActNum, node)
    end
  end
  
end

hook_event(HOOK_BEFORE_WARP, before_warp)


function on_warp(warpType, lvl, area, node)
  warpInfo.ing = false
  warpInfo.timer = 0
  
  if MAPi.get_hangout_from_levelnum(lvl) then
    curLevel = MAPi.get_hangout_from_levelnum(lvl)
    if warpType ~= WARP_TYPE_SAME_AREA then
      if bgm.src then
        audio_stream_stop(bgm.src)
      end
    end
  end
  
  curMap = mapTable[curLevel]
  curArea = gNetworkPlayers[0].currAreaIndex
  
  local l = gLakituState
    local skyboxcheck = obj_get_nearest_object_with_behavior_id(o, id_bhvmapiskybox)
    local p = gNetworkPlayers[0]
    if skyboxcheck == nil and mapTable[curLevel].skybox ~= {nil} and (MAPi.get_levelnum_from_hangout(curLevel) ~= nil and gNetworkPlayers[0].currLevelNum == MAPi.get_levelnum_from_hangout(curLevel)) then
      local sky = mapTable[curLevel].skybox
      if sky[p.currAreaIndex] then
      if sky[p.currAreaIndex].skytype == "ico" then
        spawn_non_sync_object(id_bhvmapiskybox, E_MODEL_SKYBOX_CUSTOM_ICO, l.pos.x, l.pos.y, l.pos.z, nil)
      elseif sky[p.currAreaIndex].skytype == "box" then
        spawn_non_sync_object(id_bhvmapiskybox, E_MODEL_SKYBOX_CUSTOM_BOX, l.pos.x, l.pos.y, l.pos.z, nil)
      end
      replace_skybox(sky, p)
      end
    end
  
if gNetworkPlayers[0].currLevelNum == MAPi.get_levelnum_from_hangout(curLevel) and mapTable[curLevel].bgm then
  if type(mapTable[curLevel].bgm) == "table" then
    for i, musc in pairs(mapTable[curLevel].bgm) do
    if i == gNetworkPlayers[0].currAreaIndex then
      set_bgm(musc.isStream == true and musc or nil)
    end
    end
    else
      
    set_bgm(mapTable[curLevel].bgm.isStream == true and mapTable[curLevel].bgm or nil)
  end
else
  set_bgm(nil)
end

if gNetworkPlayers[0].currLevelNum == MAPi.get_levelnum_from_hangout(curLevel) and mapTable[curLevel].envtint[p.currAreaIndex] then
  local env = mapTable[curLevel].envtint[p.currAreaIndex]
 set_env_tint(env.color, env.dir)
 else
   set_env_tint({r = 255, g = 255, b = 255}, {x = 0,y = 0, z = 0})
end

end

hook_event(HOOK_ON_WARP, on_warp)

local startPopup = 5

function play_custom_bgm()
  local m = gMarioStates[0]
  local curMap = mapTable[MAPi.get_cur_hangout()]
  local seq = get_current_background_music()
  if m.playerIndex ~= 0 then
    return end
  
  if bgm.src then
  audio_stream_play(bgm.src, false, bgm.volume)
  audio_stream_set_looping(bgm.src, true)
  
  if gNetworkPlayers[0].currLevelNum ~= mapTable[curLevel].source then
    audio_stream_stop(bgm.src)
    bgm.src = nil
    set_env_tint({r = 255, g = 255, b = 255}, {x = 0,y = 0, z = 0})
    end
  
  end
  
  if m.flags & MARIO_WING_CAP ~= 0 or m.flags & MARIO_VANISH_CAP ~= 0 or m.flags & MARIO_METAL_CAP ~= 0 or m.action & ACT_FLAG_RIDING_SHELL ~= 0 then
   bgm.goalVolume = VOLUME_MUTE
    else 
      if is_game_paused() == true or MAPi.is_menu_open() == true then
        bgm.goalVolume = VOLUME_PAUSE
        else
      bgm.goalVolume = VOLUME_DEFAULT
      end
      
    if (bgm.src) then
    stop_background_music(get_current_background_music())
    end
  end
  
  if (charSelectExists) then
    if (charSelect.is_menu_open()) then
      if charSelect.get_option(charSelect.optionTableRef.music).toggle == 1 or charSelect.get_option(charSelect.optionTableRef.music).toggle == 2 then
        bgm.goalVolume = VOLUME_MUTE
      end
    end
  end
  
  bgm.volume = lerp(bgm.volume, bgm.goalVolume, 0.2)
  
  if (startPopup > 0) then
    startPopup = startPopup - 1
  end
  if (startPopup == 1) then
    startup_msg()
  end
  
  if (warpInfo.ing == true and MAPi.get_cur_hangout() and MAPi.get_cur_hangout() > 2) then
    warpInfo.timer = warpInfo.timer + 1
    
    if (not m.area.camera) then
      warpInfo.timer = 0
    end
    
    if warpInfo.timer > 30 and m.area.camera.cutscene ~= CUTSCENE_ENTER_PAINTING then
      
      local wasItLevel = smlua_level_util_get_info(warpInfo.info.lvl)
      local wasItArea = not area_get_any_warp_node()
      local wasItNode = not area_get_warp_node(warpInfo.info.nd)
      djui_chat_message_create("\\#00ffff\\MAPi\\#dcdcdc\\: Warp in "..mapTable[curLevel].name.." failed! \nDest. Level:\\#00ffff\\"..warpInfo.info.lvl.." \\#dcdcdc\\Dest. Area:\\#00ffff\\"..warpInfo.info.ar.."\\#dcdcdc\\ Dest. Node:\\#00ffff\\"..warpInfo.info.nd.." ("..string.format("0x%X", warpInfo.info.nd)..")")
      
      warp_to_hangout(2, 1, 0x20)
      m.health = 0x2000
      warpInfo.ing = false
      warpInfo.timer = 0
      
      warpInfo.info = {
        lvl = 0,
        ar = 0,
        nd = 0
      }
    end
    
  end
  
end

hook_event(HOOK_UPDATE, play_custom_bgm)


local function what_maps()
  
  for _, data in pairs(mapTable) do
    djui_chat_message_create(tostring(_).. " -".. tostring(data.name))
end
  
  return true
end

function tp_everyone_level()
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
    open_mapi_menu()
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
      warp_to_hangout(map, 1, (map == 2 and gLevelValues.exitCastleWarpNode or map == 1 and 0xFF) or 0x0A)
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
    mapiSettings[2].txt = "Allow"
    return true
  elseif msg == "false" then
    gGlobalSyncTable.canWarp = false
    djui_popup_create_global("Host toggled MAPi warping off!", 2)
    mapiSettings[2].txt = "Do not allow"
    return true
    else
      gGlobalSyncTable.canWarp = not gGlobalSyncTable.canWarp
      if gGlobalSyncTable.canWarp == true then
    djui_popup_create_global("Host toggled MAPi warping on!", 2)
    mapiSettings[2].txt = "Allow"
    else
      djui_popup_create_global("Host toggled MAPi warping off!", 2)
      mapiSettings[2].txt = "Do not allow"
      end
      return true
  end
  
end


function toggle_popups(ms)
  msg = tostring(ms)
  
  if msg == "true" then
    gGlobalSyncTable.warpPopups = true
    djui_popup_create_global("MAPi popups have been activated.", 2)
    mapiSettings[3].txt = "Show"
    return true
  elseif msg == "false" then
    gGlobalSyncTable.warpPopups = false
    djui_popup_create_global("MAPi popups have been deactivated.", 2)
    mapiSettings[3].txt = "Do not show"
    return true
    else
      gGlobalSyncTable.warpPopups = not gGlobalSyncTable.warpPopups
      if gGlobalSyncTable.warpPopups == true then
    djui_popup_create_global("MAPi popups have been activated.", 2)
    mapiSettings[3].txt = "Show"
    else
      djui_popup_create_global("MAPi popups have been deactivated.", 2)
      mapiSettings[3].txt = "Do not show"
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
        warp_to_hangout(entered_level, entered_act, (entered_level == 2 and gLevelValues.exitCastleWarpNode or entered_level == 1 and 0xFF) or 0x0A)
       end
    end

end
hook_event(HOOK_ON_PACKET_RECEIVE, packet_receive)

function startup_msg()
  
  mapTable[1].source = gLevelValues.entryLevel
  mapTable[2].source = gLevelValues.exitCastleLevel
  
  local hangouts = #mapTable - 2
  local BIND = openBind == OPENBIND_NONE and "/mapi-warp" or openBind == OPENBIND_X and "Start + X" or openBind == OPENBIND_L and "Start + L"
  local TEXT_BIND = "Use \\#00ffff\\"..BIND.."\\#ffffff\\"..(openBind ~= OPENBIND_NONE and " or \\#00ffff\\/mapi-warp\\#ffffff\\" or "").." to open the menu!"
  local string = "\\#ee3333\\M\\#00cc00\\A\\#cccc00\\P\\#916cca\\i\\#ffffff\\ currently has \\#00ff00\\".. tostring(hangouts).. "\\#ffffff\\ hangout maps available! \n".. TEXT_BIND
  
  djui_chat_message_create(string)
  
end

if network_is_server() then
  hook_chat_command("mapi-warp-all", "- Warps everyone to your current hangout", tp_everyone_level)
  hook_chat_command("mapi-toggle-warps", " [true / false] - Toggles if other players should be able to warp using the MAPi menu", toggle_warping)
  end

hook_chat_command("mapi-maps", "- shows currently available maps from MAPi", what_maps)
hook_chat_command("mapi-warp", "- warps to a currently available hangout map on MAPi or opens the menu", mapi_warp_command)
