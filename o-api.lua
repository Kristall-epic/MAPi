
--[[Adds a level as a selectable hangout in the menu
SourceMap:the level_register() of the level you want
Name:the name that will appear in the menu
Description:{"a short description of your",
"hangout map, should look",
  "something like this"}
Preview:The image that will appear in the menu representing your level
Bgm:The background music that will play, put nil to skip and just have the default bgm you chose in blender play, use a table to set music for multiple areas within the level
]]
local function hangout_map_add(sourceMap, Name, Description, Credit, Preview, Bgm)
  
  local mapID = #mapTable + 1
  table.insert(mapTable, {
      source = sourceMap,
      name = type(Name) == "string" and Name or "???",
      description = type(Description) == "table" and Description or {"No description provided."},
      credit = type(Credit) == "string" and Credit or "???",
      prev = Preview ~= nil and Preview or prevNone,
      entrysnd = nil,
      bgm = Bgm,
      skybox = {nil},
      envtint = {nil},
      textColor = {r = 255, g = 255, b = 255, a = 255}
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
      entrysnd = Sound ~= nil and Sound or map.entrysnd,
      bgm = Bgm ~= nil and Bgm or map.bgm,
      skybox = mapTable[mapID].skybox,
      envtint = mapTable[mapID].envtint
  }
  
  if _G.MAPi.get_cur_hangout() == mapID and Bgm ~= nil then
    
    if curBGM ~= nil then
    audio_stream_stop(curBGM)
    end
    
  if type(Bgm) == "table" then
    stop_background_music(get_current_background_music())
    
    for i, bgm in pairs(Bgm) do
    if i == gNetworkPlayers[0].currAreaIndex then
    stop_background_music(get_current_background_music())
    curBGM = bgm
    end
    end
    
    else
    audio_stream_play(Bgm, false, 1)
    audio_stream_set_looping(Bgm, true)
    curBGM = Bgm
    end
   -- djui_chat_message_create(tostring(gNetworkPlayers[0].currAreaIndex)
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
   
   if _G.MAPi.get_cur_hangout() == mapID and gNetworkPlayers[0].currAreaIndex == area then
     replace_skybox(mapTable[mapID].skybox, gNetworkPlayers[0])
     end
  
end

--adds an environment tint to the given hangout map
local function hangout_add_env_tint(mapID, Color, Dir)
  table.insert(mapTable[mapID].envtint,
    {color = Color, dir = Dir})
end

local function hangout_edit_env_tint(mapID, area, Color, Dir)
  if mapTable[mapID].envtint[area] ~= nil then
  tint = mapTable[mapID].envtint[area]
  else
    return
  end
  
tint.color = Color or tint.color
tint.dir = Dir or tint.dir

if (gNetworkPlayers[0].currLevelNum == _G.MAPi.get_levelnum_from_hangout(mapID)) and gNetworkPlayers[0].currAreaIndex == area then
     set_env_tint(tint.color, tint.dir)
     end
  
end

--Edits the bgm of the given hangout to src, if your map uses a table, use area to specify which are src goes to
function hangout_edit_bgm(mapID, area, src)
  
  if _G.MAPi.get_cur_hangout() ~= mapID then
    return end
  
  if curBGM ~= nil then
    audio_stream_stop(curBGM)
  end
  
  stop_background_music(get_current_background_music())
  
  if type(mapTable[mapID].bgm) == "table" then
   local bgm = mapTable[mapID].bgm
    
    bgm[area] = src or bgm[area]
    
    for i, mus in pairs(bgm) do
    if i == gNetworkPlayers[0].currAreaIndex then
    stop_background_music(get_current_background_music())
    curBGM = mus
    end
    end
    
    
    return mapID
    end
  
  mapTable[mapID].bgm = src or mapTable[mapID].bgm
    curBGM = mapTable[mapID].bgm
  
  end


--gets the current mapID of the level the player is in, if the current level is not in MAPi, returns nil
local function get_cur_hangout()
  if gNetworkPlayers[0] then
    return gNetworkPlayers[0].currLevelNum == _G.MAPi.get_levelnum_from_hangout(curLevel) and curLevel or nil
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

--Return the amount of players in the given hangout
local function check_players_in_hangout(mapID)
    local level = mapTable[mapID].source
    local plr = 0

    for _, player in pairs(gNetworkPlayers) do
        if player.connected and player.currLevelNum == level then
            plr = plr + 1
        end
    end

    return plr
end

--Returns a table with the number of players in the 6 acts of the given hangout
local function check_players_hangout_per_act(mapID)
  local level = mapTable[mapID].source
  local plr = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
  }
  
  for _, player in pairs(gNetworkPlayers) do
        if player.connected and player.currLevelNum == level and player.currActNum > 0 then
              plr[player.currActNum] = plr[player.currActNum] + 1
        end
  end
  
  return plr
end

local function hangout_add_entry_sound(mapID, sound)
if mapTable[mapID] ~= nil then
  mapTable[mapID].entrysnd = sound
  end

end

local function hangout_edit_text_color(mapID, color)
  
  for i, col in pairs(color) do
    if col > 255 then
      color[i] = 255
    end
    if col < 0 then
      color[i] = 0
      end
    end
  
  mapTable[mapID].textColor = color
  end

_G.MAPi = {
  controller = {
    buttonDown = 0,
    buttonPressed = 0,
    extStickX = 0,
    extStickY = 0,
    rawStickX = 0,
    rawStickY = 0,
    stickMag = 0,
    stickX = 0,
    stickY = 0
    
  },
  hangout_map_add = hangout_map_add,
  hangout_map_edit = hangout_map_edit,
  hangout_edit_bgm = hangout_edit_bgm,
  get_cur_hangout = get_cur_hangout,
  get_levelnum_from_hangout = get_levelnum_from_hangout,
  get_hangout_from_levelnum = get_hangout_from_levelnum,
  hangout_add_skybox = hangout_add_skybox,
  hangout_edit_skybox = hangout_edit_skybox,
  hangout_add_env_tint = hangout_add_env_tint,
  hangout_edit_env_tint = hangout_edit_env_tint,
  is_menu_open = is_menu_open,
  menu_get_cur_selected = menu_get_cur_selected,
  check_players_in_hangout = check_players_in_hangout,
  check_players_hangout_per_act = check_players_hangout_per_act,
  hangout_add_entry_sound = hangout_add_entry_sound,
  hangout_edit_text_color = hangout_edit_text_color
}
