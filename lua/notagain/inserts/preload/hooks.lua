local Hooks     = hook.GetTable() or {} -- so hooks called before get registered
local Faileds   = Faileds or {}

local HookRunNetString = "__NW__HOOKS__RUN__"

local old_hookadd    = hook.Add 
local old_hookremove = hook.Remove

hook.Add = function(hk,hkname,callback)
	Hooks[hk] = Hooks[hk] or {}
	Hooks[hk][hkname] = callback 
	old_hookadd(hk,hkname,callback)
end

hook.Remove = function(hk,hkname)
	if Hooks[k] and Hooks[hk][hkname] then
		Hooks[hk][hkname] = nil 
	end
	old_hookremove(hk,hkname)
end

hook.GetAll = function() -- less intensive way to get all hooks
	return Hooks 
end

hook.Find = function(hk)
	local found = {}
	local hk = string.lower(hk)
	for type,_ in pairs(Hooks) do
		for name,callback in pairs(Hooks[type]) do
			if string.match(string.lower(tostring(name)),string.PatternSafe(hk),1) then
				found[type] = found[type] or {}
				found[type][name] = callback
			end
		end
	end
	return found
end

if SERVER then

	util.AddNetworkString(HookRunNetString)

	hook.RunNW = function(name,...)
		local tbl = {
			Name = name,
			Args = { ... },
		}

		hook.Run(name,...)

		net.Start(HookRunNetString)
		net.WriteTable(tbl)
		net.Broadcast()
	end

	net.Receive(HookRunNetString,function()
		local tbl = net.ReadTable()
		hook.Run(tbl.Name,unpack(tbl.Args))
	end)

end

	
if CLIENT then

	hook.RunNW = function(name,...)
		local tbl = {
			Name = name,
			Args = { ... },
		}

		hook.Run(name,...)

		net.Start(HookRunNetString)
		net.WriteTable(tbl)
		net.SendToServer()
	end

	net.Receive(HookRunNetString,function()
		local tbl = net.ReadTable()
		hook.Run(tbl.Name,unpack(tbl.Args))
	end)

end

local cachehookerr = function(name,err)
	if #Faileds >= 30 then
		table.remove(Faileds,1)
	end 
	local add = true
	local tbl = {
		File = name,
		Line = string.match(err,"(%>%:(%d*)%:){1}"),
		Error = err,
	}
	for k,v in pairs(Faileds) do
		if v == tbl then
			add = false 
			break 
		end
	end
	
	if add then
		table.insert(Faileds,tbl)
	end
end

--dont look at this its an attempt to catch failed hooks
hook.Add("OnLuaError","__HOOKS__FAILED__",function(err,_,name,_)
	local hookerr = string.match(err,"(lua%/includes%/modules%/hook)")
	if hookerr then
		cachehookerr(name,err)
	end
end)

hook.GetFailed = function()
	return Faileds 
end
