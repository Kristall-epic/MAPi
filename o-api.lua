
--[[Adds a level as a selectable hangout in the menu
SourceMap:the level_register() of the level you want
Name:the name that will appear in the menu
Description:{"a short description of your",
"hangout map, should look",
  "something like this"}
Preview:The image that will appear in the menu representing your level
Sound:An optional short sound that will play when the player warps into the level, put nil to skip
Bgm:The background music that will play, put nil to skip and just have the default bgm you chose in blender play, use a table to set music for multiple areas within the level
]]
local function hangout_map_add(sourceMap, Name, Description, Credit, Preview, Sound, Bgm)
  
  if _G.MAPi.get_hangout_from_levelnum(sourceMap) ~= nil then
    return djui_popup_create(tostring(Name).. " has the same level num than another hangout!", 2)
    end
  
  local mapID = #mapTable + 1
  table.insert(mapTable, {
      source = sourceMap,
      name = type(Name) == "string" and Name or "???",
      description = type(Description) == "table" and Description or {"No description provided."},
      credit = type(Credit) == "string" and Credit or "???",
      prev = Preview ~= nil and Preview or prevNone,
      sound = Sound,
      bgm = Bgm,
      skybox = {nil},
  }
    )
  return mapID
end


--edits the properties of the given hangout id
local function hangout_map_edit(mapID, sourceMap, Name, Description, Credit, Preview, Sound, Bgm)
  
  map = mapTable[mapID]

   mapTable[mapID] = 
   {
      source = sourceMap ~= nil and sourceMap or map.source,
      name = Name ~= nil and Name or map.name,
      description = Description ~= nil and Description or map.description,
      credit = Credit ~= nil and Credit or map.credit,
      prev = Preview ~= nil and Preview or map.prev,
      sound = Sound ~= nil and Sound or map.sound,
      bgm = Bgm ~= nil and Bgm or map.bgm,
      skybox = mapTable[mapID].skybox
  }
  
  if _G.MAPi.get_cur_hangout() == mapID then
    if Bgm ~= nil then
    if curBGM ~= nil then
      audio_stream_stop(curBGM)
      curBGM = nil
    end
    audio_stream_play(Bgm, false, 1)
    audio_stream_set_looping(Bgm, true)
    curBGM = Bgm
    end
    end

  return mapID
end

--adds a custom skybox to a hangout, it bases off flipflopbell's custom skybox thing, you can choose either using one single image (the one you define as front) with skytype = "sphere" or use 6 images with skytype = "box"

--you can add skyboxes to subareas by adding another function with same mapID, it goes in order, the first one will be added to area 1, the second to area 2 and so on
local function hangout_add_skybox(mapID, Skybox)
  table.insert(mapTable[mapID].skybox,
    {skytype = Skybox.skytype,
    up = Skybox.up,
    down = Skybox.down,
    front = Skybox.front,
    back = Skybox.back,
    left = Skybox.left,
    right = Skybox.right,
  })
end


local function hangout_edit_skybox(mapID, area, Skybox)
  local sky = mapTable[mapID].skybox[area]
  
  if sky == nil or Skybox == nil then
    return
    end
  
   sky.skytype = Skybox.skytype or sky.skytype
   sky.up = Skybox.up or sky.up
   sky.down = Skybox.down or sky.down
   sky.front = Skybox.front or sky.front
   sky.back = Skybox.back or sky.back
   sky.left = Skybox.left or sky.left
   sky.right = Skybox.right or sky.right
   
   if _G.MAPi.get_cur_hangout() == mapID then
     replace_skybox(mapTable[mapID].skybox, gNetworkPlayers[0])
     end
  
  end

--gets the current or last level with a hangoutID a player was in
local function get_cur_hangout()
  if gNetworkPlayers[0] then
    return curLevel
    end
end

--gets the LevelNum of a hangout
local function get_levelnum_from_hangout(id)
  return mapTable[id].source
end

--if it exists, gets the hangout id of a LevelNum
local function get_hangout_from_levelnum(levelnum)
for _, map in pairs(mapTable) do
    if map.source == levelnum then
      return _
      end
end

return nil
end

--checks if the selecting menu is open
local function is_menu_open()
  return Menu == true and true or false
end

--gets the current hangout a player is viewing in the menu
local function menu_get_cur_selected()
  return LevelIndex
end

_G.MAPi = {
  hangout_map_add = hangout_map_add,
  hangout_map_edit = hangout_map_edit,
  get_cur_hangout = get_cur_hangout,
  get_levelnum_from_hangout = get_levelnum_from_hangout,
  get_hangout_from_levelnum = get_hangout_from_levelnum,
  hangout_add_skybox = hangout_add_skybox,
  hangout_edit_skybox = hangout_edit_skybox,
  is_menu_open = is_menu_open,
  menu_get_cur_selected = menu_get_cur_selected,
}