--[[
    Shine No Rookies - Server
]]
local Shine = Shine
local InfoHub = Shine.PlayerInfoHub
local Plugin = Plugin

Plugin.Version = "1.5"
Plugin.HasConfig = true

Plugin.ConfigName = "norookies.json"
Plugin.DefaultConfig =
{
    UseSteamTime = true,
    MinPlayer = 0,
    DisableAfterRoundtime = 0,
    MinPlaytime = 8,
    MinComPlaytime = 8,
    ShowInform = true,
    InformMessage = "This server is not rookie friendly",
    BlockTeams = true,
    ShowSwitchAtBlock = false,
    BlockCC = true,
    AllowSpectating = false,
    BlockMessage = "This server is not rookie friendly",
    Kick = true,
    Kicktime = 20,
    KickMessage = "You will be kicked in %s seconds",
    WaitMessage = "Please wait while your data is retrieved",
}
Plugin.CheckConfig = true
Plugin.CheckConfigTypes = true

Plugin.Name = "No Rookies"
Plugin.DisconnectReason = "You didn't fit to the required playtime"
local Enabled = true

function Plugin:Initialise()
    local Gamemode = Shine.GetGamemode()
    if Gamemode ~= "ns2" then
        return false, string.format( "The norookie plugin does not work with %s.", Gamemode )
    end

    if self.Config.UseSteamTime or self.Config.ForceSteamTime then
        InfoHub:Request( self.Name, "STEAMPLAYTIME")
    end

    self.BlockMessage = self.Config.BlockMessage
	self.Enabled = true

	return true
end

function Plugin:SetGameState( _, NewState )
    if NewState == kGameState.Started and self.Config.DisableAfterRoundtime and self.Config.DisableAfterRoundtime > 0 then        
        self:CreateTimer( "Disable", self.Config.DisableAfterRoundtime * 60 , 1, function() Enabled = false end )
    end
end

function Plugin:EndGame()
    self:DestroyTimer( "Disable" )
    Enabled = true
end

function Plugin:CheckCommLogin( _, Player )
    if not self.Config.BlockCC or not Player or not Player.GetClient or Shine.GetHumanPlayerCount() < self.Config.MinPlayer then return end

    return self:Check( Player, true )
end

function Plugin:CheckValues( Playerdata, SteamId, ComCheck )
    PROFILE("NoRookies:CheckValues()")
    if not Enabled then return true end

    local Playtime = Playerdata.playTime
    --check if Player fits to the PlayTime

    if self.Config.UseSteamTime then
	    local SteamTime = InfoHub:GetSteamData( SteamId ).PlayTime
	    if SteamTime and SteamTime > Playtime then
		    Playtime = SteamTime
	    end
    end

	local Min = ComCheck and self.Config.MinComPlaytime or self.Config.MinPlaytime
    local Max = ComCheck and self.Config.MaxComPlaytime or self.Config.MaxPlaytime

    if Playtime < Min * 3600 or
		    (Max > 0 and Playtime > Max * 3600) then
	    return false
    end

	return true
end