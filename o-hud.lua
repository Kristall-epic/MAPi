LevelIndex = 2
Menu = false
settings = false
goalFadeout = 0
curSetting = 1
MOD_STORAGE_LTRIG_EXISTS = mod_storage_exists("LTRIG")
SETTING_LTRIG = (MOD_STORAGE_LTRIG_EXISTS == true) and mod_storage_load_bool("LTRIG") or true
prevNone = get_texture_info("prev_unk")
local playerhud = get_texture_info("hud_players")
local actselect = get_texture_info("hud_actselect")
local selectedact = get_texture_info("hud_selectedact")
local hudcursor = get_texture_info("hud_cursor")
local mapilogo = get_texture_info("logo_mapi")

MAPiUI = {
  logo = {
    pos = {x = 0, y = 0},
    tex = mapilogo
  },

  preview = {
    pos = {x = 0, y = 0},
    rect = {x1 = 0, y1 = 0, x2 = 4, y2 = 4},
    rotation = 0x0,
    cur = {tex = prevNone, opacity = 255, sclX = 1, sclY = 1},
    last = {tex = prevNone, opacity = 255, sclX = 1, sclY = 1}
  },

  info = {
    name = {
      pos = {x = 0, y = 0},
      txt = "",
      scale = 1,
      color = {r = 255, g = 255, b = 255, a = 255}
    },
    credit = {
      pos = {x = 0, y = 0},
      txt = {""},
      scale = 1
    },
    desc = {
      pos = {x = 0, y = 0},
      txt = {""},
      scale = 1
    },
    act = {
      pos = {x = 0, y = 0}
    }
  },

  settings = {
    pos = {x = 0, y = 600},
    goalY = 600
  }
  
}

mapiSettings = {
  
  [1] = {
    val = SETTING_LTRIG,
    name = "Open bind",
    desc = {"The way of opening MAPi"},
    visTrue = "Start + L",
    visFalse = "Command only.",
    host = false,
    func = function() 
      SETTING_LTRIG = not SETTING_LTRIG
      mod_storage_save_bool("LTRIG", SETTING_LTRIG)
      end
  },
  
  [2] = {
    val = true,
    name = "Allow warping",
    desc = {"[HOST] Allow others", "to warp with MAPi?"},
    visTrue = "Allow",
    visFalse = "Don't allow",
    host = true,
    func = toggle_warping
  },

  [3] = {
    val = true,
    name = "Warp popups",
    desc = {"[HOST] Show popups", "when players warp?"},
    visTrue = "Yes",
    visFalse = "No",
    host = true,
    func = toggle_popups
  }
  
}

random_text = {
  [1] = "Map? API? MAPi!",
  [2] = "Enjoy your stay!",
  [3] = "Thanks for using MAPi!",
  [4] = "Who even takes those pictures?",
  [5] = "MAPi.hangout_map_add()!",
  [6] = "Travel the world!"
}

local MAX_TILT = 0x600
RANDOM_TOP_TEXT = 1
local selectedTilt = 0x0
local intendedSelectedTilt = MAX_TILT
local fadeout = 0
local LevelAct = 1
local posX = 0
local lerpNameScale = 1
local lerpCreditScale = 0.5
local debounce = 0
local PIC_INTENDED_ROT = math.random(-MAX_TILT, MAX_TILT)
local picRot = 0
local settingsPos = 0
local PREV_SELECTED = 2
local PREV_SELECTED_OPACITY = 255

local function mario_update(m)
 
 if m.playerIndex == 0 then
   
if is_game_paused() and djui_hud_is_pause_menu_created() == false then

if SETTING_LTRIG == true and m.controller.buttonPressed & L_TRIG ~= 0 and debounce == 0 then
  open_mapi_menu()
end
end

if debounce > 0 then
  debounce = debounce - 1
end

if Menu == true then
  nullify_inputs(m)
  
  if debounce > 0 then
    return end
  
  if MAPi.controller.buttonPressed & START_BUTTON ~= 0 and debounce == 0 then
    debounce = 15
    settings = not settings
  end
  
  if MAPi.controller.buttonPressed & B_BUTTON ~= 0 then
    if settings == true then
      settings = false
      else
  close_mapi_menu()
  end
  end
  
  if settings == true then
    if (MAPi.controller.rawStickY > 50 or MAPi.controller.buttonDown & U_JPAD ~= 0) and debounce == 0 then
      debounce = 5
      curSetting = curSetting - 1
      
      if curSetting == 0 then
        curSetting = #mapiSettings
        end
      
    end
    
    if (MAPi.controller.rawStickY < -50 or MAPi.controller.buttonDown & D_JPAD ~= 0) and debounce == 0 then
      debounce = 5
      curSetting = curSetting + 1
      
      if curSetting == #mapiSettings + 1 then
        curSetting = 1
        end
      
    end
    
    if MAPi.controller.buttonPressed & A_BUTTON ~= 0 then
      local cur = mapiSettings[curSetting]
      if (cur.host == true and network_is_server()) or cur.host == false then
        cur.val = not cur.val
        debounce = 15
        cur.func(cur.val)
        play_sound(SOUND_ACTION_READ_SIGN, m.marioObj.header.gfx.cameraToObject)
        end
      
      end
    
    MAPiUI.settings.goalY = halfheight
    
    return
    else
      MAPiUI.settings.goalY = djuiheight + halfheight
    end
  
  if MAPi.controller.buttonPressed & A_BUTTON ~= 0 and debounce == 0 then
    debounce = 15
    if network_is_server() or gGlobalSyncTable.canWarp == true then
warp_to_hangout(LevelIndex, LevelAct, (LevelIndex == 2 and 0x20 or LevelIndex == 1 and 0xFF) or 0x0A)
else
  djui_popup_create("Warping is disabled by host!", 2)
end
  end
  
  if (MAPi.controller.rawStickX > 50 or MAPi.controller.buttonDown & R_JPAD ~= 0) and debounce == 0 then
  debounce = 5
  MAPiUI.preview.last.tex = mapTable[LevelIndex].prev
  MAPiUI.preview.last.opacity = 255
  LevelIndex = LevelIndex + 1
  if LevelIndex == #mapTable + 1 then
    LevelIndex = 1
  end
  play_sound(SOUND_MENU_STAR_SOUND, m.marioObj.header.gfx.cameraToObject)
  PIC_INTENDED_ROT = math.random(-MAX_TILT, MAX_TILT)
elseif (MAPi.controller.rawStickX < -50 or MAPi.controller.buttonDown & L_JPAD ~= 0) and debounce == 0 then
  debounce = 5
  MAPiUI.preview.last.tex = mapTable[LevelIndex].prev
  MAPiUI.preview.last.opacity = 255
 LevelIndex = LevelIndex - 1
  if LevelIndex == 0 then
    LevelIndex = #mapTable
  end
  play_sound(SOUND_MENU_STAR_SOUND, m.marioObj.header.gfx.cameraToObject)
  PIC_INTENDED_ROT = math.random(-MAX_TILT, MAX_TILT)
end
  
  if (MAPi.controller.buttonPressed & L_CBUTTONS ~= 0 or MAPi.controller.buttonPressed & D_JPAD ~= 0) then
LevelAct = LevelAct - 1
if LevelAct < 1 then
  LevelAct = 6
end
play_sound(SOUND_MENU_PINCH_MARIO_FACE, m.marioObj.header.gfx.cameraToObject)
elseif (MAPi.controller.buttonPressed & R_CBUTTONS ~= 0 or MAPi.controller.buttonPressed & U_JPAD ~= 0) then
LevelAct = LevelAct + 1
if LevelAct > 6 then
  LevelAct = 1
end
play_sound(SOUND_MENU_PINCH_MARIO_FACE, m.marioObj.header.gfx.cameraToObject)
end
  
  end

end

end

hook_event(HOOK_BEFORE_MARIO_UPDATE, mario_update)

local function on_hud_render(m)
  local BIND = SETTING_LTRIG == true and "L Button" or "/mapi-warp"
  local hangoutPlayers = MAPi.check_players_in_hangout(LevelIndex)
  
  if is_game_paused() and djui_hud_is_pause_menu_created() == false then
    djui_hud_set_font(djui_menu_get_font())
djui_hud_print_text(BIND.." - MAPi Menu", 20, 16, 1)
end
  
  djui_hud_set_resolution(RESOLUTION_N64)
  djui_hud_set_filter(FILTER_LINEAR)
  djuiwidth = djui_hud_get_screen_width()
  djuiheight = djui_hud_get_screen_height()
  halfwidth = djuiwidth * 0.5
  halfheight = djuiheight * 0.5
  quarterwidth = djuiwidth * 0.25
  actplayers = MAPi.check_players_hangout_per_act(LevelIndex)
  SETTINGS_POS_HIDDEN = djuiwidth + 100
  SETTINGS_POS_SHOW = djuiwidth - 100

  curMap = mapTable[LevelIndex]
  prevScaleY = (halfheight/curMap.prev.height)
  prevScaleX = (halfwidth/curMap.prev.width)
  lastPrevScaleY = (halfheight/MAPiUI.preview.last.tex.height)
  lastPrevScaleX = (halfwidth/MAPiUI.preview.last.tex.width)

  if posX ~= (65 * LevelIndex) then
   posX = lerp(posX, (65 * LevelIndex), 0.15)
  end
  
  MAPiUI.preview.rotation = lerp(MAPiUI.preview.rotation, PIC_INTENDED_ROT, 0.2)
  
  selectedTilt = lerp(selectedTilt, intendedSelectedTilt, 0.05)
  
  MAPiUI.preview.last.opacity = lerp(MAPiUI.preview.last.opacity, 0, 0.3)
  
  if math.abs(selectedTilt - intendedSelectedTilt) < 0x300 then
    intendedSelectedTilt = -intendedSelectedTilt
    end
  
  MAPiUI.settings.pos.x = halfwidth
  MAPiUI.settings.pos.y = lerp(MAPiUI.settings.pos.y, MAPiUI.settings.goalY, 0.3)
    
if Menu == true then
  
  fadeout = lerp(fadeout, goalFadeout, 0.3)
  if goalFadeout == 0 and fadeout < 0.1 then
    Menu = false
  end

  djui_hud_set_color(0, 0, 0, 200*fadeout)
  djui_hud_render_rect(-20, -20, djuiwidth + 40, djuiheight + 20)
  djui_hud_set_color(255, 255, 255, 225*fadeout)
  
  if mapTable[LevelIndex].textColor ~= nil and type(mapTable[LevelIndex].textColor) == "table" then
    mapTextColor = mapTable[LevelIndex].textColor
    
    approach_color_to_color(MAPiUI.info.name.color, mapTextColor)
    else
      approach_color_to_color(MAPiUI.info.name.color, {r = 255, g = 255, b = 255, a = 255})
    end
 
 --Small photos 
 
for i, map in pairs(mapTable) do
  djui_hud_set_font(FONT_ALIASED)
  local players = MAPi.check_players_in_hangout(i)
  local preview = mapTable[i].prev
  local previewScaleX = (256/preview.width)
  local previewScaleY = (128/preview.height)
  local diff = math.abs(i - LevelIndex)
  local intendedY = (10/(diff+1))
  local photoPosX =  (((65 * i) - posX) + halfwidth - 20) - 2
  
  if diff == 0 then
    djui_hud_set_rotation(selectedTilt, 0.5, 0.5)
    
  djui_hud_set_color(MAPiUI.info.name.color.r, MAPiUI.info.name.color.g, MAPiUI.info.name.color.b, MAPiUI.info.name.color.a*fadeout)
  
  djui_hud_render_rect( (((65 * i) - posX) + halfwidth - 20) - 3, djuiheight - 40 - 3 - intendedY, 256*0.2 + 6, 128*0.2 + 10)
  
  djui_hud_set_color(255, 255, 255, 255*fadeout)
    
  end
 
 if (photoPosX > -64) and (photoPosX < djuiwidth) then
  djui_hud_render_rect(photoPosX, djuiheight - 40 - 2 - intendedY, 256*0.2 + 4, 128*0.2 + 8)
  
  djui_hud_render_texture(preview ~= nil and preview or prevNone, ((65 * i) - posX) + halfwidth - 20, djuiheight - 40 - intendedY, previewScaleX*0.2, previewScaleY*0.2)
  
  if (players ~= 0) then
  djui_hud_render_texture(playerhud, ((65 * i) - posX) + halfwidth - (playerhud.width*0.5), djuiheight - 65 - intendedY, 0.5, 0.5)
  end
  
  djui_hud_print_text(players ~= 0 and tostring(players) or "", ((65 * i) - posX) + halfwidth, djuiheight - 65 - intendedY, 0.5)
  end
  djui_hud_set_rotation(0x0, 0, 0)
  
end

local UPPER_OFFSET = 8 + (djuiheight/4)/(djuiwidth/djuiheight)
local LEFT_OFFSET = 12

MAPiUI.preview.cur.tex = curMap.prev or prevNone

MAPiUI.preview.pos.x = LEFT_OFFSET + 4
MAPiUI.preview.pos.y = (mapilogo.height*0.35) + 6/(djuiwidth/djuiheight)
MAPiUI.preview.cur.sclX = prevScaleX*0.8
MAPiUI.preview.cur.sclY = prevScaleY*0.8
MAPiUI.preview.last.sclX = lastPrevScaleX*0.8
MAPiUI.preview.last.sclY = lastPrevScaleY*0.8

if MAPiUI.preview.cur.sclX > MAPiUI.preview.cur.sclY then
  MAPiUI.preview.cur.sclX = MAPiUI.preview.cur.sclY
end

if MAPiUI.preview.cur.sclY > MAPiUI.preview.cur.sclX then
  MAPiUI.preview.cur.sclY = MAPiUI.preview.cur.sclX
end

if MAPiUI.preview.last.sclX > MAPiUI.preview.last.sclY then
  MAPiUI.preview.last.sclX = MAPiUI.preview.last.sclY
end

if MAPiUI.preview.last.sclY > MAPiUI.preview.last.sclX then
  MAPiUI.preview.last.sclY = MAPiUI.preview.last.sclX
end

MAPiUI.preview.rect = {
  x1 = MAPiUI.preview.pos.x - ((MAPiUI.preview.cur.tex.width*MAPiUI.preview.cur.sclX)*1.025 - (MAPiUI.preview.cur.tex.width*MAPiUI.preview.cur.sclX)),
  y1 = MAPiUI.preview.pos.y - ((MAPiUI.preview.cur.tex.width*MAPiUI.preview.cur.sclX)*1.045 - (MAPiUI.preview.cur.tex.width*MAPiUI.preview.cur.sclX)),
  x2 = (MAPiUI.preview.cur.tex.width*MAPiUI.preview.cur.sclX)*1.05,
  y2 = (MAPiUI.preview.cur.tex.height*MAPiUI.preview.cur.sclX)*1.25
}

--Preview photo
djui_hud_set_rotation(MAPiUI.preview.rotation, 0.5, 0.5)
djui_hud_render_rect(MAPiUI.preview.rect.x1, MAPiUI.preview.rect.y1, MAPiUI.preview.rect.x2, MAPiUI.preview.rect.y2)

djui_hud_set_rotation(MAPiUI.preview.rotation, 0.5, 0.6)
djui_hud_render_texture(MAPiUI.preview.cur.tex, MAPiUI.preview.pos.x, MAPiUI.preview.pos.y, MAPiUI.preview.cur.sclX, MAPiUI.preview.cur.sclY)

djui_hud_set_color(255,255,255,MAPiUI.preview.last.opacity*fadeout)

djui_hud_render_texture(MAPiUI.preview.last.tex or prevNone, MAPiUI.preview.pos.x, MAPiUI.preview.pos.y, MAPiUI.preview.last.sclX, MAPiUI.preview.last.sclY)

djui_hud_set_color(255,255,255,255*fadeout)

djui_hud_set_rotation(0, 0.5, 0.5)

djui_hud_render_texture(MAPiUI.logo.tex, -2, 4, 0.35, 0.35)

djui_hud_print_text(random_text[RANDOM_TOP_TEXT], mapilogo.width*0.35 - 2, (mapilogo.height*0.35)/4, 0.35)

djui_hud_set_font(FONT_RECOLOR_HUD)
djui_hud_set_color(MAPiUI.info.name.color.r, MAPiUI.info.name.color.g, MAPiUI.info.name.color.b, MAPiUI.info.name.color.a*fadeout)

local intendedNameScale = MAPiUI.info.name.scale < 1.15 and MAPiUI.info.name.scale or 1.15
local intendedCreditScale = MAPiUI.info.credit.scale < 0.5 and MAPiUI.info.credit.scale or 0.5

lerpNameScale = lerp(lerpNameScale, intendedNameScale, 0.2)
lerpCreditScale = lerp(lerpCreditScale, intendedCreditScale, 0.2)

MAPiUI.info.name.txt = mapTable[LevelIndex].name
MAPiUI.info.name.pos.x = LEFT_OFFSET + (MAPiUI.preview.cur.tex.width*MAPiUI.preview.cur.sclX) + 4 + 16*(djuiwidth/djuiheight)
MAPiUI.info.name.pos.y = UPPER_OFFSET

MAPiUI.info.name.scale = (MAPiUI.info.name.pos.x/djui_hud_measure_text(mapTable[LevelIndex].name))*0.75
MAPiUI.info.credit.scale = (halfwidth/djui_hud_measure_text(mapTable[LevelIndex].credit))*0.85

djui_hud_print_text(mapTable[LevelIndex].name, MAPiUI.info.name.pos.x, MAPiUI.info.name.pos.y, lerpNameScale)

djui_hud_set_color(255, 255, 255, 255*fadeout)

djui_hud_set_font(FONT_ALIASED)

MAPiUI.info.credit.txt = "By: "..tostring(mapTable[LevelIndex].credit)
MAPiUI.info.credit.pos.x = LEFT_OFFSET + (MAPiUI.preview.cur.tex.width*MAPiUI.preview.cur.sclX) + 4 + 16*(djuiwidth/djuiheight)
MAPiUI.info.credit.pos.y = MAPiUI.info.name.pos.y + 28*lerpNameScale - 8

djui_hud_print_text(MAPiUI.info.credit.txt, MAPiUI.info.credit.pos.x, MAPiUI.info.credit.pos.y, lerpCreditScale)

MAPiUI.info.act.pos.x = LEFT_OFFSET + (MAPiUI.preview.cur.tex.width*MAPiUI.preview.cur.sclX) + 4 + 16*(djuiwidth/djuiheight)
MAPiUI.info.act.pos.y = MAPiUI.info.credit.pos.y + ((hangoutPlayers > 0 and LevelIndex > 2) and 24 or 16)

djui_hud_render_texture(actselect, MAPiUI.info.act.pos.x, MAPiUI.info.act.pos.y, 1, 1)
  djui_hud_render_texture(selectedact, MAPiUI.info.act.pos.x + 11* (LevelAct-1) - 4, MAPiUI.info.act.pos.y + 4, 0.5, 0.5)
  
  for i, num in pairs(actplayers) do
  if num > 0 then
    djui_hud_render_texture(playerhud, MAPiUI.info.act.pos.x + 11*(i-1), MAPiUI.info.act.pos.y - 8, 0.25, 0.25)
  end
  
  djui_hud_print_text(num > 0 and tostring(num) or "", MAPiUI.info.act.pos.x + 11*(i-1), MAPiUI.info.act.pos.y - 8, 0.35)
  
  
  end
  
  local desc = mapTable[LevelIndex].description
  MAPiUI.info.desc.txt = string_to_lines(desc, 128 + 128/(djuiheight/djuiwidth))
  MAPiUI.info.desc.pos.x = MAPiUI.info.name.pos.x
  MAPiUI.info.desc.pos.y = MAPiUI.info.act.pos.y + 12
  
  for i, line in pairs(MAPiUI.info.desc.txt) do
    djui_hud_print_text(line, MAPiUI.info.desc.pos.x, (10*i) + MAPiUI.info.desc.pos.y, 0.4)
    end

    local curSett = mapiSettings[curSetting]
    local visValue = curSett.val == true and curSett.visTrue or curSett.visFalse
  
  djui_hud_render_rect(halfwidth - 96, MAPiUI.settings.pos.y - 16, 216, 128)
  
  djui_hud_set_color(0, 0, 0, 255*fadeout)
  for i, set in pairs(mapiSettings) do
    if set.host == true then
      if network_is_server() == false then
        djui_hud_set_color(127, 127, 127, 255*fadeout)
      else
        djui_hud_set_color(0,0,0,255*fadeout)
      end
    end
    djui_hud_print_text(set.name, halfwidth - 92, MAPiUI.settings.pos.y - 10 + 14*i, 0.35)
    end
     djui_hud_set_color(0,0,0,255*fadeout)

    djui_hud_print_text(visValue, halfwidth + 64, MAPiUI.settings.pos.y + 16, 0.4)
    for i, line in pairs(curSett.desc) do
    djui_hud_print_text(line, halfwidth - (djui_hud_measure_text(line)*.35)/2, MAPiUI.settings.pos.y + 14*i, 0.35)
    end

  djui_hud_set_color(255, 255, 255, 255*fadeout)
  
  djui_hud_render_texture(hudcursor, halfwidth - 90, MAPiUI.settings.pos.y - 10 + 14*curSetting, 0.5, 0.5)

end
end
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
