--Custom skybox by flipflopbell

E_MODEL_SKYBOX_CUSTOM_BOX = smlua_model_util_get_id("MAPi_Skybox_Cube_geo")
E_MODEL_SKYBOX_CUSTOM_ICO = smlua_model_util_get_id("MAPi_Icosphere_geo")

local l = gLakituState

function bhv_mapiskybox_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oFaceAngleYaw = 0x0
    o.header.gfx.skipInViewCheck = true
    obj_scale(o, 101)
    set_override_far(200000)
end

function bhv_mapiskybox_loop(o)
    o.oPosX = l.pos.x
    o.oPosY = l.pos.y
    o.oPosZ = l.pos.z
    
    if MAPi.get_cur_hangout() then
    local turnRate = mapTable[curLevel].skybox[gNetworkPlayers[0].currAreaIndex].spin
    
    if turnRate then
      o.oFaceAngleYaw = o.oFaceAngleYaw + turnRate
    end
    end
    
end

id_bhvmapiskybox = hook_behavior(bhvmapiskybox, OBJ_LIST_LEVEL, false, bhv_mapiskybox_init, bhv_mapiskybox_loop)
