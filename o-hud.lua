LevelIndex = 2
Menu = false
local fadeout = 0
local LevelAct = 1
local posX = 0
local debounce = 0

prevNone = get_texture_info("prev_unk")
local playerhud = get_texture_info("hud_players")
local actselect = get_texture_info("hud_actselect")
local selectedact = get_texture_info("hud_selectedact")

local function mario_update(m)
 
 if m.playerIndex == 0 then
if is_game_paused() and djui_hud_is_pause_menu_created() == false then

if m.controller.buttonPressed & L_TRIG ~= 0 and debounce == 0 then
  debounce = 15
  Menu = true
  set_mario_action(m, ACT_MAPI_MENU, 0)
  m.controller.buttonPressed = m.controller.buttonPressed | START_BUTTON
  play_sound(SOUND_MENU_LET_GO_MARIO_FACE, m.marioObj.header.gfx.cameraToObject)
end
end

if debounce > 0 then
  debounce = debounce - 1
  end

end

end

hook_event(HOOK_MARIO_UPDATE, mario_update)


local function on_hud_render(m)
  
  if is_game_paused() and djui_hud_is_pause_menu_created() == false then
    djui_hud_set_font(djui_menu_get_font())
djui_hud_print_text("L Button - MAPi Menu", 20, 16, 1)
end
  
  djui_hud_set_resolution(RESOLUTION_N64)
  djuiwidth = djui_hud_get_screen_width()
  djuiheight = djui_hud_get_screen_height()
  halfwidth = djuiwidth * 0.5
  quarterwidth = djuiwidth * 0.25
  actplayers = check_players_hangout_per_act(LevelIndex)
  
  if posX ~= (250 * LevelIndex) then
   posX = lerp(posX, (250 * LevelIndex), 0.2)
  end
  
  if Menu == true then
    fadeout = lerp(fadeout, 1.1, 0.3)
    else
    fadeout = lerp(fadeout, 0, 0.3)
  end

if gMarioStates[0].action == ACT_MAPI_MENU and Menu == true then

  djui_hud_set_color(0, 0, 0, 200*fadeout)
  djui_hud_render_rect(0, 0, djuiwidth, djuiheight)
  djui_hud_set_color(255, 255, 255, 225*fadeout)
  
for i, map in pairs(mapTable) do
  djui_hud_set_font(FONT_RECOLOR_HUD)
  djui_hud_print_text(mapTable[i].name, ((250 * i) - posX) +(djui_hud_get_screen_width()/2 - djui_hud_measure_text(mapTable[i].name)/2), 24, 1)
  djui_hud_set_font(FONT_ALIASED)
  djui_hud_render_texture(mapTable[i].prev ~= nil and mapTable[i].prev or prevNone, ((250 * i) - posX) +(djui_hud_get_screen_width()/2 - 72.5), 54, 0.6, 0.6)
  
    
    for i, num in pairs(actplayers) do
  djui_hud_print_text(num > 0 and tostring(num) or "", (10*i) + djui_hud_get_screen_width()/2 + 4, djuiheight/2 + 28, 0.4)
  
end

  djui_hud_print_text("By: "..tostring(mapTable[LevelIndex].credit), djui_hud_get_screen_width()/2 - 72.5, djuiheight/2 + 12, 0.5)
  
  for i, line in pairs(mapTable[LevelIndex].description) do
    djui_hud_print_text(line, djui_hud_get_screen_width()/2 - 72.5, (10*i) + djuiheight/2 + 35, 0.4)
    end
  
  djui_hud_render_texture(actselect, djui_hud_get_screen_width()/2 + 14, djuiheight/2 + 14, 1, 1)
  djui_hud_render_texture(selectedact, djui_hud_get_screen_width()/2 + 11*LevelAct, djuiheight/2 + 18, 0.5, 0.5)
  
end

end
end
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)


ACT_MAPI_MENU = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_STATIONARY)

local function mapi_menu(m)

if m.pos.y > m.floorHeight then perform_air_step(m, 1)
  else stationary_ground_step(m)
    end
set_mario_animation(m, CHAR_ANIM_IDLE_HEAD_CENTER)
if m.playerIndex == 0 then

if m.controller.buttonPressed & START_BUTTON ~= 0 then
  m.controller.buttonPressed = m.controller.buttonPressed & ~START_BUTTON
end

if Menu == true then
if (m.controller.rawStickX > 50 or m.controller.buttonPressed & D_JPAD ~= 0) and debounce == 0 then
  debounce = 5
  LevelIndex = LevelIndex + 1
  if LevelIndex == #mapTable + 1 then
    LevelIndex = 1
  end
  play_sound(SOUND_MENU_CAMERA_TURN, m.marioObj.header.gfx.cameraToObject)
elseif (m.controller.rawStickX < -50 or m.controller.buttonPressed & U_JPAD ~= 0) and debounce == 0 then
  debounce = 5
 LevelIndex = LevelIndex - 1
  if LevelIndex == 0 then
    LevelIndex = #mapTable
  end
  play_sound(SOUND_MENU_CAMERA_TURN, m.marioObj.header.gfx.cameraToObject)
end

if (m.controller.buttonPressed & L_CBUTTONS ~= 0 or m.controller.buttonPressed & L_JPAD ~= 0) then
  m.controller.buttonPressed = m.controller.buttonPressed & ~L_CBUTTONS
LevelAct = LevelAct - 1
if LevelAct < 1 then
  LevelAct = 6
end
play_sound(SOUND_MENU_PINCH_MARIO_FACE, m.marioObj.header.gfx.cameraToObject)
elseif (m.controller.buttonPressed & R_CBUTTONS ~= 0 or m.controller.buttonPressed & R_JPAD ~= 0) then
LevelAct = LevelAct + 1
if LevelAct > 6 then
  LevelAct = 1
end
play_sound(SOUND_MENU_PINCH_MARIO_FACE, m.marioObj.header.gfx.cameraToObject)
end
  
if m.controller.buttonPressed & A_BUTTON ~= 0 then
  if network_is_server() or gGlobalSyncTable.canWarp == true then
warp_to_hangout(LevelIndex, LevelAct, (LevelIndex == 2 and 0x20 or LevelIndex == 1 and 0xFF) or 0x0A)
else
  djui_popup_create("Warping is disabled by host!", 2)
end
end

if m.controller.buttonPressed & B_BUTTON ~= 0 then
Menu = false
set_mario_action(m, ACT_IDLE, 0)

end

end
end
end

hook_mario_action(ACT_MAPI_MENU, mapi_menu)
