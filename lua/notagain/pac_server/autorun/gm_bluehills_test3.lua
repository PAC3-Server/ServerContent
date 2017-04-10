 if game.GetMap() ~= "gm_bluehills_test3" then return end

local easylua = requirex("easylua")

easylua.StartEntity("bluehill_theater_screen")
	ENT.PrintName = "Bluehill Theater Screen"

	ENT.Type = "anim"

	ENT.Base = "mediaplayer_base"

	ENT.RenderGroup = RENDERGROUP_OPAQUE

	ENT.PlayerConfig = {
		offset	= Vector(0,-.2,0),
		angle	= Angle(0,180,90),
		width = 704,
		height = 352
	}

	function ENT:Initialize()
		if SERVER then
			self:InstallMediaPlayer( "entity" )

			local mp = self:GetMediaPlayer()

			function mp:UpdateListeners()
				local listeners = {}
				for k, v in pairs( ents.FindInBox( Vector( 343, 1191, 436 ), Vector( 1216, 91, -63 ) ) ) do
					if v:IsPlayer() then
						table.insert(listeners, v)
					end
				end
				self:SetListeners(listeners)
			end
		end
	end

	if CLIENT then
		function ENT:Draw()
		end
	end
easylua.EndEntity()

if SERVER then
	hook.Add("InitPostEntity", "SpawnTheaterScreen", function()
		local remove_these = {
			trigger_soundscape = true,
			env_soundscape_triggerable = true,
		}

		for _, ent in pairs(ents.GetAll()) do
			local class = ent:GetClass()

			if remove_these[ent:GetClass()] then
				ent:Remove()
			end
		end

		local screen = ents.Create( "bluehill_theater_screen" )
		screen:SetPos(Vector(416,1176,352))
		screen:SetAngles(Angle(0,180,0))
		screen:Spawn()
	end)
else
	--This is a very ugly way to do it
	hook.Add("OnContextMenuOpen", "CinemaMediaplayer", function()
		local ent = ents.FindByClass("bluehill_theater_screen")[1]
		if IsValid(ent) then
			mp = MediaPlayer.GetByObject( ent )
			if IsValid( mp ) then
				MediaPlayer.ShowSidebar( mp )
			end
		end
	end)
end