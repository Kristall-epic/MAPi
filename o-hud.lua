LevelIndex = 2
Menu = false
settings = false
curSetting = 1
SETTING_LTRIG = mod_storage_load_bool("LTRIG")

mapiSettings = {
  
  [1] = {
    val = SETTING_LTRIG,
    name = "Start + L",
    desc = {"Start + L to open MAPi", "or only command"},
    visTrue = "Use for MAPi",
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
    desc = {"[HOST] Toggle if others", "should be able to warp"},
    visTrue = "Allow.",
    visFalse = "Don't allow.",
    host = true,
    func = toggle_warping
  },

  [3] = {
    val = true,
    name = "Warp popups",
    desc = {"[HOST] Show popups when", "players warp."},
    visTrue = "Show.",
    visFalse = "Hide.",
    host = true,
    func = toggle_popups
  }
  
}

local menuTextColor = {
  r = 255,
  g = 255,
  b = 255,
  a = 255
}

local MAX_TILT = 0x600
local selectedTilt = 0x0
local intendedSelectedTilt = MAX_TILT
local fadeout = 0
local LevelAct = 1
local posX = 0
local scale = 1
local debounce = 0
local PIC_INTENDED_ROT = math.random(-MAX_TILT, MAX_TILT)
local picRot = 0
local settingsPos = 0

prevNone = get_texture_info("prev_unk")
local playerhud = get_texture_info("hud_players")
local actselect = get_texture_info("hud_actselect")
local selectedact = get_texture_info("hud_selectedact")
local hudcursor = get_texture_info("hud_cursor")

local function mario_update(m)
 
 if m.playerIndex == 0 then
   
if is_game_paused() and djui_hud_is_pause_menu_created() == false then

if SETTING_LTRIG == true and m.controller.buttonPressed & L_TRIG ~= 0 and debounce == 0 then
  debounce = 15
  game_unpause()
  Menu = true
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
  
  if settings == true then
    if (MAPi.controller.rawStickY > 50 or MAPi.controller.buttonDown & U_JPAD ~= 0) and debounce == 0 then
      debounce = 5
      curSetting = curSetting - 1
      
      if curSetting == 0 then
        curSetting = #mapiSettings
        end
      
    end

    if (MAPi.controller.buttonPressed & B_BUTTON ~= 0) then
      settings = false
    end
    
    if (MAPi.controller.rawStickY < -50 or MAPi.controller.buttonDown & D_JPAD ~= 0) and debounce == 0 then
      debounce = 5
      curSetting = curSetting + 1
      
      if curSetting == #mapiSettings + 1 then
        curSetting = 1
        end
      
    end
    
    if _G.MAPi.controller.buttonPressed & A_BUTTON ~= 0 then
      local cur = mapiSettings[curSetting]
      if (cur.host == true and network_is_server()) or cur.host == false then
        cur.val = not cur.val
        debounce = 15
        cur.func(cur.val)
        play_sound(SOUND_ACTION_READ_SIGN, m.pos)
        end
      
      end
    
    
    return end
  
  if _G.MAPi.controller.buttonPressed & A_BUTTON ~= 0 then
    if network_is_server() or gGlobalSyncTable.canWarp == true then
warp_to_hangout(LevelIndex, LevelAct, (LevelIndex == 2 and 0x20 or LevelIndex == 1 and 0xFF) or 0x0A)
else
  djui_popup_create("Warping is disabled by host!", 2)
end
  end
  
  if MAPi.controller.buttonPressed & B_BUTTON ~= 0 then
    if settings == true then
      settings = false
      else
  Menu = false
  end
  end
  
  if (MAPi.controller.rawStickX > 50 or MAPi.controller.buttonDown & R_JPAD ~= 0) and debounce == 0 then
  debounce = 5
  LevelIndex = LevelIndex + 1
  if LevelIndex == #mapTable + 1 then
    LevelIndex = 1
  end
  play_sound(SOUND_MENU_CAMERA_TURN, m.marioObj.header.gfx.cameraToObject)
  PIC_INTENDED_ROT = math.random(-MAX_TILT, MAX_TILT)
elseif (MAPi.controller.rawStickX < -50 or MAPi.controller.buttonDown & L_JPAD ~= 0) and debounce == 0 then
  debounce = 5
 LevelIndex = LevelIndex - 1
  if LevelIndex == 0 then
    LevelIndex = #mapTable
  end
  play_sound(SOUND_MENU_CAMERA_TURN, m.marioObj.header.gfx.cameraToObject)
  PIC_INTENDED_ROT = math.random(-MAX_TILT, MAX_TILT)
end
  
  if (MAPi.controller.buttonPressed & L_CBUTTONS ~= 0 or MAPi.controller.buttonPressed & L_TRIG ~= 0) then
LevelAct = LevelAct - 1
if LevelAct < 1 then
  LevelAct = 6
end
play_sound(SOUND_MENU_PINCH_MARIO_FACE, m.marioObj.header.gfx.cameraToObject)
elseif (MAPi.controller.buttonPressed & R_CBUTTONS ~= 0 or MAPi.controller.buttonPressed & R_TRIG ~= 0) then
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
  
  if is_game_paused() and djui_hud_is_pause_menu_created() == false and SETTING_LTRIG == true then
    djui_hud_set_font(djui_menu_get_font())
djui_hud_print_text("L Button - MAPi Menu", 20, 16, 1)
end
  
  djui_hud_set_resolution(RESOLUTION_N64)
  djuiwidth = djui_hud_get_screen_width()
  djuiheight = djui_hud_get_screen_height()
  halfwidth = djuiwidth * 0.5
  halfheight = djuiheight * 0.5
  quarterwidth = djuiwidth * 0.25
  actplayers = _G.MAPi.check_players_hangout_per_act(LevelIndex)
  SETTINGS_POS_HIDDEN = djuiwidth + 100
  SETTINGS_POS_SHOW = djuiwidth - 100

  curMap = mapTable[LevelIndex]
  prevScaleY = (halfheight/curMap.prev.height)
  prevScaleX = (halfwidth/curMap.prev.width)
  
  if posX ~= (65 * LevelIndex) then
   posX = lerp(posX, (65 * LevelIndex), 0.15)
  end
  
  picRot = lerp(picRot, PIC_INTENDED_ROT, 0.2)
  
  selectedTilt = lerp(selectedTilt, intendedSelectedTilt, 0.05)
  
  if math.abs(selectedTilt - intendedSelectedTilt) < 0x300 then
    intendedSelectedTilt = -intendedSelectedTilt
    end
  
  settingsPos = lerp(settingsPos, settings == true and SETTINGS_POS_SHOW or SETTINGS_POS_HIDDEN, 0.2)
  
  if Menu == true then
    fadeout = lerp(fadeout, 1.1, 0.3)
    else
    fadeout = lerp(fadeout, 0, 0.3)
  end

if Menu == true then

  djui_hud_set_color(0, 0, 0, 200*fadeout)
  djui_hud_render_rect(-20, -20, djuiwidth + 40, djuiheight + 20)
  djui_hud_set_color(255, 255, 255, 225*fadeout)
  
  if mapTable[LevelIndex].textColor ~= nil and type(mapTable[LevelIndex].textColor) == "table" then
    mapTextColor = mapTable[LevelIndex].textColor
    
    approach_color_to_color(menuTextColor, mapTextColor)
    else
      approach_color_to_color(menuTextColor, {r = 255, g = 255, b = 255, a = 255})
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
  
  if diff == 0 then
    djui_hud_set_rotation(selectedTilt, 0.5, 0.5)
    end
 
  djui_hud_render_rect( (((65 * i) - posX) + halfwidth - 20) - 2, djuiheight - 40 - 2 - intendedY, 256*0.2 + 4, 128*0.2 + 8)
  
  djui_hud_render_texture(preview ~= nil and preview or prevNone, ((65 * i) - posX) + halfwidth - 20, djuiheight - 40 - intendedY, previewScaleX*0.2, previewScaleY*0.2)
  
  
  djui_hud_print_text(players ~= 0 and tostring(players) or "", ((65 * i) - posX) + halfwidth, djuiheight - 65 - intendedY, 0.5)
  
  djui_hud_set_rotation(0x0, 0, 0)
  
end

local UPPER_OFFSET = djuiheight/8
local LEFT_OFFSET = 12

--Preview photo
djui_hud_set_rotation(picRot, 0.5, 0.5)
djui_hud_render_rect(LEFT_OFFSET, UPPER_OFFSET, (halfwidth)*0.8 + 8, halfheight*0.8 + 24)

djui_hud_set_rotation(picRot, 0.5, 0.6)
djui_hud_render_texture(curMap.prev ~= nil and curMap.prev or prevNone, LEFT_OFFSET + 4, UPPER_OFFSET + 6, prevScaleX*0.8, prevScaleY*0.8)

djui_hud_set_rotation(0, 0.5, 0.5)

djui_hud_set_font(FONT_RECOLOR_HUD)
djui_hud_set_color(menuTextColor.r, menuTextColor.g, menuTextColor.b, menuTextColor.a)

local nameScale = (halfwidth/djui_hud_measure_text(mapTable[LevelIndex].name))*0.75

local intendedScale = nameScale < 1.35 and nameScale or 1.35

scale = lerp(scale, intendedScale, 0.2)

djui_hud_print_text(mapTable[LevelIndex].name, halfwidth + 8, UPPER_OFFSET, scale)

djui_hud_set_color(255, 255, 255, 255)

djui_hud_set_font(FONT_ALIASED)


djui_hud_print_text("By: "..tostring(mapTable[LevelIndex].credit), halfwidth + 8, 28 + UPPER_OFFSET*scale - 10, 0.5)

djui_hud_render_texture(actselect, halfwidth + 8 + djui_hud_measure_text(tostring(mapTable[LevelIndex].credit))/2 + 20, 28 + UPPER_OFFSET*scale - 10, 1, 1)
  djui_hud_render_texture(selectedact, halfwidth + 8 + 11*LevelAct + djui_hud_measure_text(tostring(mapTable[LevelIndex].credit))/2 + 5, 34 + UPPER_OFFSET*scale - 10, 0.5, 0.5)
  
  for i, num in pairs(actplayers) do
  djui_hud_print_text(num > 0 and tostring(num) or "", (11*i) + halfwidth + 18 + djui_hud_measure_text(tostring(mapTable[LevelIndex].credit))/2, 20 + UPPER_OFFSET*scale, 0.4)
  end
  
  for i, line in pairs(mapTable[LevelIndex].description) do
    djui_hud_print_text(line, halfwidth + 10, (10*i) + 32 + UPPER_OFFSET*scale, 0.4)
    end

    local curSett = mapiSettings[curSetting]
    local visValue = curSett.val == true and curSett.visTrue or curSett.visFalse
  
  djui_hud_render_rect(settingsPos, halfheight - 16, settingsPos + 8, halfheight + 16)
  
  djui_hud_set_color(0, 0, 0, 255)
  for i, set in pairs(mapiSettings) do
    if set.host == true then
      if network_is_server() == false then
        djui_hud_set_color(127, 127, 127, 255)
      else
        djui_hud_set_color(0,0,0,255)
      end
    end
    djui_hud_print_text(set.name, settingsPos + 24, halfheight - 10 + 14*i, 0.45)
    end
     djui_hud_set_color(0,0,0,255)

    djui_hud_print_text(visValue, settingsPos + 16, halfheight - 14, 0.50)

  djui_hud_set_color(255, 255, 255, 255)
  
  djui_hud_render_texture(hudcursor, settingsPos + 2, halfheight - 10 + 14*curSetting, 0.5, 0.5)

end
end
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
