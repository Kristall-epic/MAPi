if not MAPi then return end
hooked_hangouts = {}

function hangout_events()
  for i = 0, HOOK_MAX - 1 do
    
    local func = function(...)
      local hook = i
      local hangout = hooked_hangouts[MAPi.get_cur_hangout()]
      
      if not hangout or not hangout[hook] then return end
      
      hangout[hook](...)
    end
    
    hook_event(i, func)
  end
end

hook_event(HOOK_ON_MODS_LOADED, hangout_events)