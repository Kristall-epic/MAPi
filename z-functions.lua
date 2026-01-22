lerp = math.lerp

function replace_skybox(sky, p)
  if sky[p.currAreaIndex] == nil then
    return end
  
texture_override_set("MAPi_Icosphere_mapi_skybox_unk_rgba16", sky[p.currAreaIndex].front or prevNone)
        if sky[p.currAreaIndex].skytype == "box" then
        texture_override_set("MAPi_Skybox_Cube_skyast_up_rgba16", sky[p.currAreaIndex].up or prevNone)
        texture_override_set("MAPi_Skybox_Cube_skyast_lf_rgba16", sky[p.currAreaIndex].left or prevNone)
        texture_override_set("MAPi_Skybox_Cube_skyast_dn_rgba16", sky[p.currAreaIndex].down or prevNone)
        texture_override_set("MAPi_Skybox_Cube_skyast_rt_rgba16", sky[p.currAreaIndex].right or prevNone)
        texture_override_set("MAPi_Skybox_Cube_skyast_bk_rgba16", sky[p.currAreaIndex].back or prevNone)
        texture_override_set("MAPi_Skybox_Cube_skyast_ft_rgba16", sky[p.currAreaIndex].front or prevNone)
        end
        
end

function approach_color_to_color(color1, color2)

  color1.r = approach_s16_asymptotic(color1.r, color2.r or 255, 4)
    color1.g = approach_s16_asymptotic(color1.g, color2.g or 255, 4)
    color1.b = approach_s16_asymptotic(
      color1.b, color2.b or 255, 4)
    color1.a = approach_s16_asymptotic(color1.a, color2.a or 255, 4)
  
  end
  
  
  --from environment tint by agent x 
function set_env_tint(color, lightingDir)
  if color == {nil} then
    return end
  if lightingDir == {nil} then
    return end
    set_lighting_color(0, color.r)
    set_lighting_color(1, color.g)
    set_lighting_color(2, color.b)
    set_vertex_color(0, color.r)
    set_vertex_color(1, color.g)
    set_vertex_color(2, color.b)
    set_fog_color(0, color.r)
    set_fog_color(1, color.g)
    set_fog_color(2, color.b)
    set_lighting_dir(0, lightingDir.x)
    set_lighting_dir(1, lightingDir.y)
    set_lighting_dir(2, lightingDir.z)
end

--from CS by Squishy
function nullify_inputs(m)
    local c = m.controller
    _G.MAPi.controller = {
        buttonDown = c.buttonDown,
        buttonPressed = c.buttonPressed & ~_G.MAPi.controller.buttonDown,
        extStickX = c.extStickX,
        extStickY = c.extStickY,
        rawStickX = c.rawStickX,
        rawStickY = c.rawStickY,
        stickMag = c.stickMag,
        stickX = c.stickX,
        stickY = c.stickY
    }
    c.buttonDown = 0
    c.buttonPressed = 0
    c.extStickX = 0
    c.extStickY = 0
    c.rawStickX = 0
    c.rawStickY = 0
    c.stickMag = 0
    c.stickX = 0
    c.stickY = 0
end

function open_mapi_menu()
  debounce = 15
  game_unpause()
  Menu = true
  RANDOM_TOP_TEXT = math.random(1, #random_text)
  end
