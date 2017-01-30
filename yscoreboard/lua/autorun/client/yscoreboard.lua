AddCSLuaFile() 
 
local scrW, scrH = ScrW(), ScrH()
local resolutionScale = math.Min(scrW/1600 , scrH/900)
local mainMenuSize = {
    w = scrW * .60,
    h = scrH * .85
}

hook.Add("PreRender", "ScoreboardCheckResolutionChange", function()
    if (ScrW() != scrW or ScrH() != scrH) then
        scrW, scrH = ScrW(), ScrH()
        mainMenuSize.w = mainMenuSize.w / resolutionScale
        mainMenuSize.h = mainMenuSize.h / resolutionScale
        resolutionScale = math.Min(scrW/1600 , scrH/900 )
        mainMenuSize.w = mainMenuSize.w * resolutionScale
        mainMenuSize.h = mainMenuSize.h * resolutionScale
    end
end)
 
 
 
surface.CreateFont( "InfoFont", {
    font      = "DermaDefault",
    size      = 21,
    weight    = 1000,
    blursize  = 0,
    scanlines = 0,
    antialias = true,
    shadow    = true,
    additive  = true,
    outline   = true,
} )

surface.CreateFont( "Sfont", {
    font      = "DermaDefault",
    size      = 15,
    weight    = 1000,
    blursize  = 0,
    scanlines = 0,
    antialias = true,
    shadow    = true,
    additive  = true,
    outline   = true,
} )

surface.CreateFont( "ScoreboardDefaultTitle", {
    font    = "DermaDefault",
    size    = 32,
    weight  = 800,
    shadow  = true,
    outline = true
} )
 
local function formatTime (time)
  local ttime = time or 0
  ttime = math.floor(ttime / 60)
  local m = ttime % 60
  ttime = math.floor(ttime / 60)
  local h = ttime % 24
  ttime = math.floor( ttime / 24 )
  local d = ttime % 7
  local w = math.floor(ttime / 7)
  local str = ""
  str = (w>0 and w.."w " or "")..(d>0 and d.."d " or "")
 
  return string.format( str.."%02ih %02im", h, m )
end
 
local function cinputs( command, mode )

--[[
Result in LocalPlayer:ConCommand( command..(Vars from selected modes) )
 
Modes:
1 - Number
2 - Text
 
Example:
Text and Number input:
    Mode = 3 (1+2)
Number only input:
    Mode = 1
--]]
 
    local main = vgui.Create("DFrame")
        main:SetSize(300,150)
        main:SetPos(ScrW()/2-main:GetWide()/2,ScrH()/2-main:GetTall()/2)
        main:SetTitle("Menu")
        main:SetVisible(true)
        main:SetDraggable(true)
        main:ShowCloseButton(true)
        main:SetVisible(true)
        main:MakePopup()
        main.OnClose = function()
            main:SetVisible(false)
        end
       
    local textentry = vgui.Create("DTextEntry",main)
        
        textentry:SetText("reason")
        textentry:SetPos(main:GetWide()/20,main:GetTall()/2.75)
        textentry:SetSize(main:GetWide()/2,22)
        
        if math.floor( mode / 2 ) == 0 then textentry:SetVisible( false ) end
       
    local wang = vgui.Create("DNumberWang",main)
        
        wang:SetMinMax( 0, 99999 )
        wang:SetDecimals( 0 )
        wang:SetPos(main:GetWide()/1.625,main:GetTall()/2.75)
        wang:SetSize(main:GetWide()/3,22)
        
        if mode % 2 == 0 then wang:SetVisible( false ) end
       
    local button = vgui.Create("DButton",main)
        button:SetText("Go")
        button:SetPos(main:GetWide()/4,main:GetTall()/1.35)
        button:SetSize(main:GetWide()/2-8,22)
        button.DoClick = function()
            if mode % 2 != 0 and math.floor( mode / 1 ) != 0 then command = command..[[ "]]..wang:GetValue()..[[" ]] end
            if mode % 4 != 0 and math.floor( mode / 2 ) != 0 then command = command..[[ "]]..textentry:GetValue()..[[" ]] end
           
            LocalPlayer():ConCommand(command)
            main:Remove()
        end
   
end
 
local ScoreEntries = {}
 
local PLAYER_LINE = {
    Init = function( self )
 
        local textColor = Color( 255, 255, 255, 255 )
       
        self.Friend = self:Add( "DLabel" )
        self.Friend:SetText("●")
        self.Friend:Dock( LEFT )
        self.Friend:SetFont( "Sfont" )
        self.Friend:DockMargin( 15, 0, 0, 0 )
        self.Friend:SetWidth( 20 )
       
       
        self.AvatarButton = self:Add( "DButton" )
        self.AvatarButton:Dock( LEFT )
        self.AvatarButton:SetSize( 30, 30 )
        self.AvatarButton.DoClick = function() self.Player:ShowProfile() end
 
        self.Avatar = vgui.Create( "AvatarImage", self.AvatarButton )
        self.Avatar:SetSize( 30, 30 )
        self.Avatar:SetMouseInputEnabled( false )
 
        self.Name = self:Add( "DLabel" )
        self.Name:Dock( LEFT )
        self.Name:SetFont( "Sfont" )
        self.Name:SetTextColor( Color( 255, 255, 255 ) )
        self.Name:DockMargin( 8, 0, 0, 0 )
        self.Name:SetWidth( 200 )
 
        self.Mute = self:Add( "DImageButton" )
        self.Mute:SetSize( 30, 30 )
        self.Mute:Dock( RIGHT )
 
        self.Ping = self:Add( "DLabel" )
        self.Ping:Dock( RIGHT )
        self.Ping:SetWidth( 80 )
        self.Ping:SetFont( "Sfont" )
        self.Ping:SetTextColor( Color( 255, 255, 255 ) )
        self.Ping:SetContentAlignment( 5 )
 
        self:Dock( TOP )
        self:DockPadding( 3, 3, 3, 3 )
        self:SetHeight( 35 )
        self:DockMargin( 2, 0, 2, 2 )
       
    end,
 
    Setup = function( self, pl )
 
        self.Player = pl
        self.Avatar:SetPlayer( pl )
 
        self:Think( self )
 
    end,
 
    Think = function( self )
        local x, y = self:GetPos()
        self:DockMargin( 30, 0, 25, 2 )
       
        if ( !IsValid( self.Player ) ) then
            self:SetZPos( 9999 ) -- Causes a rebuild
            self:Remove()
            return
        end
 
        if ( self.PName == nil || self.PName != self.Player:Nick() ) then
            self.PName = self.Player:Nick()
            self.Name:SetText( self.PName )
        end
 
        if ( self.NumPing == nil || self.NumPing != self.Player:Ping() ) then
            self.NumPing = self.Player:Ping()
            self.Ping:SetText( self.NumPing )
        end
       
        if self.Player:GetFriendStatus() == "friend" or self.Player==LocalPlayer() then
            self.Friend:SetTextColor( Color(0,255,0,255) )
        else
            self.Friend:SetTextColor( Color(255,0,0,255) )
        end
 
        if ( self.Muted == nil || self.Muted != self.Player:IsMuted() ) then
 
            self.Muted = self.Player:IsMuted()
            if ( self.Muted ) then
                self.Mute:SetImage( "icon32/muted.png" )
            else
                self.Mute:SetImage( "icon32/unmuted.png" )
            end
 
            self.Mute.DoClick = function() self.Player:SetMuted( !self.Muted ) end
 
        end
       
        self:SetZPos( self.Player:EntIndex() + self.Player:Team()*50 ) --Sort by Ranks

    end,
 
    Paint = function( self, w, h )
        if ( !IsValid( self.Player ) ) then
            return
        end
       
        surface.SetDrawColor( 0, 0, 0, 200 )
        draw.NoTexture()
        surface.DrawRect(0,0,w,h)

        if self:IsHovered() then
            surface.SetDrawColor(255,255,255)
            surface.DrawOutlinedRect(0,0,w,h)
        end
 
    end,
   
    OnMousePressed = function( self, num )
        if num == MOUSE_RIGHT then
            
            self.Menu = self:Add( "DMenu" )
            self.Menu:SetAutoDelete( true )

            if aowl ~= nil then
                local SubAdmin = self.Menu:AddSubMenu("Staff")
               
                SubAdmin:AddOption( "Bring",function() RunConsoleCommand("aowl","bring",self.Player:Nick() ) end)
                SubAdmin:AddOption( "Kick",function() cinputs( "aowl kick "..self.Player:Nick(),2 ) end)
                SubAdmin:AddOption( "Ban",function() cinputs( "aowl ban "..self.Player:Nick(),3 ) end)
                SubAdmin:AddOption( "Reconnect",function() RunConsoleCommand("aowl","cexec",self.Player:Nick(),"retry") end)
           
                self.Menu:AddSpacer()  
            end  
           
            if pac ~= nil and pace ~= nil then
                local SubPac = self.Menu:AddSubMenu("PAC3")
                
                SubPac:AddOption( "Ignore",function() pac.IgnoreEntity(self.Player) end)
                SubPac:AddOption( "Unignore",function() pac.UnIgnoreEntity(self.Player) end)
                   
                self.Menu:AddSpacer()
            end
           
            local SubUtility = self.Menu:AddSubMenu("Utilities")
                
            if aowl ~= nil then
                SubUtility:AddOption( "Goto",function() RunConsoleCommand("aowl","goto",self.Player:Nick()) end)
            end
            
            SubUtility:AddOption( "Copy SteamID",function() SetClipboardText(self.Player:SteamID()) chat.AddText(Color(255,255,255,255),"You copied "..self.Player:Nick().."'s SteamID") end)

            RegisterDermaMenuForClose( self.Menu )
            self.Menu:Open()
        
        elseif num == MOUSE_LEFT then
            
            RunConsoleCommand("aowl","goto",self.Player:Nick())
        
        end
       
    end
}
 
local SCORE_BOARD = {
    Init = function( self ) 
        self.Header = self:Add( "Panel" )
        self.Header:Dock( TOP )
        self.Header:SetHeight( 70 )
        self.Header.Paint = function()
            surface.SetDrawColor(0, 0, 0, 200)
            draw.NoTexture()
            surface.DrawRect(mainMenuSize.w * 0.05, 5, mainMenuSize.w * 0.9, 40)
        end
 
        self.Name = self.Header:Add( "DLabel" )
        self.Name:SetFont( "ScoreboardDefaultTitle" )
        self.Name:SetTextColor( Color( 255, 255, 255, 255 ) )
        self.Name:Dock( TOP )
        self.Name:SetHeight( 50 )
        self.Name:SetContentAlignment( 5 )
       
        self.Labels = self.Header:Add( "Panel" )
        self.Labels:Dock( BOTTOM )
        self.Labels:SetHeight( 20 )
       
        self.Labels.Name = self.Labels:Add( "DLabel" )
        self.Labels.Name:SetFont( "InfoFont" )
        self.Labels.Name:SetTextColor( Color( 255, 255, 255, 255 ) )
        self.Labels.Name:Dock( LEFT )
        self.Labels.Name:DockMargin( 70, 0, 0, 0 )
        self.Labels.Name:SetWidth( 150 )
        self.Labels.Name:SetText( "Name:" )
        self.Labels.Name:SetContentAlignment( 1 )
       
        self.Labels.Ping = self.Labels:Add( "DLabel" )
        self.Labels.Ping:SetFont( "InfoFont" )
        self.Labels.Ping:SetTextColor( Color( 255, 255, 255, 255 ) )
        self.Labels.Ping:Dock( RIGHT )
        self.Labels.Ping:DockMargin( 0, 0, 75, 0 )
        self.Labels.Ping:SetWidth( 70 )
        self.Labels.Ping:SetText( "Ping:" )
        self.Labels.Ping:SetContentAlignment( 3 )
       
        self.Footer = self:Add( "Panel" )
        self.Footer:Dock( BOTTOM )
        self.Footer:SetHeight( 30 )
       
        self.Footer.Fps = self.Footer:Add( "DLabel" )
        self.Footer.Fps:SetFont( "Sfont" )
        self.Footer.Fps:SetTextColor( Color( 255, 255, 255, 255 ) )
        self.Footer.Fps:Dock( RIGHT )
        self.Footer.Fps:DockMargin( 0, 0, 120, 0 )
        self.Footer.Fps:SetWidth( 25 )
        self.Footer.Fps:SetContentAlignment( 3 )
       
        self.Footer.FpsName = self.Footer:Add( "DLabel" )
        self.Footer.FpsName:SetFont( "Sfont" )
        self.Footer.FpsName:SetTextColor( Color( 255, 255, 255, 255 ) )
        self.Footer.FpsName:Dock( RIGHT )
        self.Footer.FpsName:DockMargin( 0, 0, 0, 0 )
        self.Footer.FpsName:SetWidth( 30 )
        self.Footer.FpsName:SetText( "FPS: " )
        self.Footer.FpsName:SetContentAlignment( 3 )
       
        self.Footer.Time = self.Footer:Add( "DLabel" )
        self.Footer.Time:SetFont( "Sfont" )
        self.Footer.Time:SetTextColor( Color( 255, 255, 255, 255 ) )
        self.Footer.Time:Dock( RIGHT )
        self.Footer.Time:DockMargin( 0, 0, 20, 0 )
        self.Footer.Time:SetWidth( 60 )
        self.Footer.Time:SetContentAlignment( 3 )
       
        self.Footer.TimeName = self.Footer:Add( "DLabel" )
        self.Footer.TimeName:SetFont( "Sfont" )
        self.Footer.TimeName:SetTextColor( Color( 255, 255, 255, 255 ) )
        self.Footer.TimeName:Dock( RIGHT )
        self.Footer.TimeName:DockMargin( 0, 0, 0, 0 )
        self.Footer.TimeName:SetWidth( 90 )
        self.Footer.TimeName:SetText( "Current time: " )
        self.Footer.TimeName:SetContentAlignment( 3 )
       
       
 
        self.Scores = self:Add( "DScrollPanel" )
        self.Scores:Dock( FILL )
 
    end,
   
    PerformLayout = function( self )
 
        self:SetSize( mainMenuSize.w, mainMenuSize.h )
        self:Center()
 
    end,
 
    Paint = function( self, w, h )
        if self:IsMouseInputEnabled() then Derma_DrawBackgroundBlur( self,  SysTime()/4 ) end
    end,
 
    Think = function( self, w, h )
       
        self.Footer.Time:SetText( os.date("%X") )
        self.Footer.Fps:SetText( math.Round( 1/FrameTime() ) )
        self.Name:SetText( GetHostName() )
       
        for id, pl in pairs( player.GetAll() ) do
            
            if ( IsValid( ScoreEntries[pl:EntIndex()] ) ) then continue end
            
            ScoreEntries[pl:EntIndex()] = vgui.CreateFromTable( PLAYER_LINE )
            ScoreEntries[pl:EntIndex()]:Setup( pl )
           
            self.Scores:AddItem( ScoreEntries[pl:EntIndex()] )
        end
 
    end
}

PLAYER_LINE = vgui.RegisterTable( PLAYER_LINE, "DPanel" )
SCORE_BOARD = vgui.RegisterTable( SCORE_BOARD, "EditablePanel" )

local ysc_convar = CreateClientConVar( "yscoreboad_show", "1", true, false )
ysc_convar:SetInt(1)

local w_Scoreboard = nil
  
local function YScoreboardShow()
    if ysc_convar:GetInt() == 1 then
        
        if ( !IsValid( w_Scoreboard ) ) then
            w_Scoreboard = vgui.CreateFromTable( SCORE_BOARD )
        end
     
        if ( IsValid( w_Scoreboard ) ) then
            w_Scoreboard:Show()
            w_Scoreboard:SetKeyboardInputEnabled( false )
            w_Scoreboard:SetMouseInputEnabled( false )
        end
       
        w_Scoreboard:MakePopup()
        w_Scoreboard:SetKeyboardInputEnabled( false )

        return false
    end
   
end

local function YScoreboardHide()
    if ysc_convar:GetInt() == 1 then
        if ( IsValid( w_Scoreboard ) ) then
            w_Scoreboard:SetMouseInputEnabled( false )
            w_Scoreboard:Hide() 
        end
        CloseDermaMenus()
    end
end

hook.Add("ScoreboardShow","YScoreboardShow",YScoreboardShow)
hook.Add("ScoreboardHide","YScoreboardHide",YScoreboardHide)

