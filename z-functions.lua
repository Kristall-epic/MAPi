
function lerp(a, b, t)
    return a * (1 - t) + b * t
end

function replace_skybox(sky, p)
  if sky[p.currAreaIndex] == nil then
    return end
  
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
