--Custom skybox by flipflopbell

E_MODEL_SKYBOX_CUSTOM_BOX = smlua_model_util_get_id("MAPi_Skybox_Cube_geo")
E_MODEL_SKYBOX_CUSTOM_ICO = smlua_model_util_get_id("MAPi_Icosphere_geo")

local l = gLakituState

function bhv_mapiskybox_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.header.gfx.skipInViewCheck = true
    obj_scale(o, 9.9)
end

function bhv_mapiskybox_loop(o)
    o.oPosX = l.pos.x
    o.oPosY = l.pos.y
    o.oPosZ = l.pos.z
end

id_bhvmapiskybox = hook_behavior(bhvmapiskybox, OBJ_LIST_LEVEL, false, bhv_mapiskybox_init, bhv_mapiskybox_loop)
