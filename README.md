### _G.MAPi.hangout_map_add()
Adds a map to the map selection menu
| Param | Description | Example |
| ----- | ----------- | ------- |
| LevelNum | The levelnum of a level. | `level_register()` \| `LEVEL_BOB` |
| Name | The name that will appear in the menu. | "My awesome level!" |
| Description | A short description for your map | { "My map is very awesome", "and cool" }
| Credit | The creator of the map | "John Cool"
Preview | The image that will appear on the menu along your map, use 256x128 | `get_texture_info("prev_cool")`
Entry Sound | A short sound that plays when the player warps into the level, place `nil` to skip | `audio_sample_load("cool_enter.ogg")`
BGM | Custom background music for your level! If you want different music per area you can use a table here with the audio files | `audio_stream_load("Cool BGM")` \| { [1] = bgm1, [2] = bgm2 }


### _G.MAPi.hangout_map_edit()
Edits the properties of the given MapID
Param | Description | Example
----- | ----------- | --------
MapID | The number returned from hangout_map_add() and position on the menu | hangout_coolness = `_G.MAPi.hangout_map_add()` \| `_G.MAPi.hangout_map_edit(hangout_coolness)`|
| LevelNum | The levelnum of a level. | `level_register()` \| `LEVEL_BOB` |
| Name | The name that will appear in the menu. | "My awesome level!" |
| Description | A short description for your map | { "My map is very awesome", "and cool" }
| Credit | The creator of the map | "John Cool"
Preview | The image that will appear on the menu along your map, use 256x128 | `get_texture_info("prev_cool")`
Entry Sound | A short sound that plays when the player warps into the level, place `nil` to skip | `audio_sample_load("cool_enter.ogg")`
BGM | Custom background music for your level! If you want different music per area you can use a table here with the audio files | `audio_stream_load("Cool BGM")` \| { [1] = bgm1, [2] = bgm2 }


### _G.MAPi.hangout_add_skybox()
Adds a custom skybox to the level using flipflopbell's skybox template
Param | Description | Example
----- | ----------- | --------
MapID | The number returned from hangout_map_add() and position on the menu | hangout_coolness = `_G.MAPi.hangout_map_add()` \| `_G.MAPi.hangout_add_skybox(hangout_coolness)`|
Skybox | A table with the images, in skytype, specify "box" to use 6 images or "ico" to use only 1 image (the one specified as front) | { skytype = "box", up = skybox_up, down = skybox_dn, front = skybox_ft, back = skybox_bk, left = skybox_lf, right = skybox_rt}


### _G.MAPi.hangout_edit_skybox()
Edits the custom skybox of the specified MapID and area
Param | Description | Example
----- | ----------- | --------
MapID | The number returned from hangout_map_add() and position on the menu | hangout_coolness = `_G.MAPi.hangout_map_add()` \| `_G.MAPi.hangout_edit_skybox(hangout_coolness)`|
Area | The area index of the skybox you wanna change, normally 1 | 1 \| 2 \| 4
Skybox | A table with the images, in skytype, specify "box" to use 6 images or "ico" to use only 1 image (the one specified as front) | { skytype = "box", up = skybox_up, down = skybox_dn, front = skybox_ft, back = skybox_bk, left = skybox_lf, right = skybox_rt}


### _G.MAPi.hangout_add_env_tint()
Adds an environment tint to the given hangout MapID
Param | Description | Example
----- | ----------- | --------
MapID | The number returned from hangout_map_add() and position on the menu | hangout_coolness = `_G.MAPi.hangout_map_add()` \| `_G.MAPi.hangout_add_env_tint(hangout_coolness)`|
Color | The color in {r, g, b} for the map | `{r = 255, g = 220, b = 127}`
Direction | The direction light is coming from | `{x = -1, y = 1, z = 0}`


### _G.MAPi.hangout_edit_env_tint()
edits the environment tint of the given area of the hangout MapID
Param | Description | Example
----- | ----------- | --------
MapID | The number returned from hangout_map_add() and position on the menu | hangout_coolness = `_G.MAPi.hangout_map_add()` \| `_G.MAPi.hangout_add_env_tint(hangout_coolness)`|
Area | The area index of the environment tint you wanna change, normally 1 | 1 \| 2 \| 4
Color | The color in {r, g, b} for the map | `{r = 255, g = 220, b = 127}`
Direction | The direction light is coming from | `{x = -1, y = 1, z = 0}`


### _G.MAPi.get_cur_hangout()
Returns the current or last MapID of a hangout you have been in


### _G.MAPi.get_levelnum_from_hangout()
Returns the levelnum of a MapID
Param | Description | Example
----- | ----------- | --------
MapID | The number returned from hangout_map_add() and position on the menu | hangout_coolness = `_G.MAPi.hangout_map_add()` \| `_G.MAPi.get_levenum_from_hangout(hangout_coolness)`|


### _G.MAPi.get_hangout_from_levelnum()
If it exists, returns the MapID of the given levelnum, or else returns nil
Param | Description | Example
----- | ----------- | --------
| LevelNum | The levelnum of a level. | `level_register()` \| `LEVEL_BOB` |


### _G.MAPi.is_menu_open()
Returns true if the MAPi Menu is open


### _G.MAPi.menu_get_cur_selected()
Returns the selected MapID on the menu
