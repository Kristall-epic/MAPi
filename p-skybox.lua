--Custom skybox by flipflopbell

E_MODEL_SKYBOX_CUSTOM_BOX = smlua_model_util_get_id("3DSkyboxCube_geo")
E_MODEL_SKYBOX_CUSTOM_ICO = smlua_model_util_get_id("3DSkyboxIco_geo")
-- Behavior
local l = gLakituState

function bhv_mapiskybox_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.header.gfx.skipInViewCheck = true
    obj_scale(o, 10)
end

function bhv_mapiskybox_loop(o)
    o.oPosX = l.pos.x
    o.oPosY = l.pos.y
    o.oPosZ = l.pos.z
   -- o.oFaceAngleYaw = lerp(o.oFaceAngleYaw, s16(l.yaw), 0.8)
   -- o.oFaceAnglePitch = lerp(o.oFaceAnglePitch, s16(l.roll), 0.8)
 --  obj_set_billboard(o)
end

function bhv_mapiskyboxvanilla_loop(o)
    o.oPosX = l.pos.x
    o.oPosY = l.pos.y
    o.oPosZ = l.pos.z
   o.oFaceAngleYaw = approach_s16_asymptotic(o.oFaceAngleYaw, l.yaw, 64)
   -- o.oFaceAnglePitch = lerp(o.oFaceAnglePitch, s16(l.roll), 0.8)
--obj_set_cylboard(o)
end

id_bhvmapiskybox = hook_behavior(bhvmapiskybox, OBJ_LIST_LEVEL, false, bhv_mapiskybox_init, bhv_mapiskybox_loop)

id_bhvmapiskyboxvanilla = hook_behavior(bhvmapiskyboxvanilla, OBJ_LIST_LEVEL, false, bhv_mapiskybox_init, bhv_mapiskyboxvanilla_loop)
