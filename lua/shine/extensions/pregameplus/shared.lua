local Plugin = {}

local Shine = Shine
local SetupClassHook = Shine.Hook.SetupClassHook
local SetupGlobalHook = Shine.Hook.SetupGlobalHook

function Plugin:SetupDataTable()
	self:AddDTVar( "boolean", "Enabled", false )
	self:AddDTVar( "boolean", "AllowOnosExo", false )
	self:AddDTVar( "boolean", "AllowMines", false )
	self:AddDTVar( "integer (1 to 12)", "BioLevel", 9 )
	self:AddDTVar( "integer (0 to 3)", "UpgradeLevel", 3 )
end

local function SetupHooks()
	SetupClassHook( "AlienTeamInfo", "OnUpdate", "AlienTeamInfoUpdate", "PassivePost" )
	SetupClassHook( "Player", "GetGameStarted", "GetGameStarted", "ActivePre" )
	SetupClassHook( "Player", "GetIsPlaying", "GetIsPlaying", "ActivePre" )
	SetupGlobalHook( "LookupTechData", "LookupTechData", "ActivePre" )
end

function Plugin:Initialise()
	self.Enabled = true
	self:SimpleTimer( 1, function() SetupHooks() end)
	return true
end

function Plugin:LookupTechData(techId, fieldName, default)
	if self.dt.Enabled and ( fieldName == kTechDataUpgradeCost or fieldName == kTechDataCostKey ) then         
		if not self.dt.AllowOnosExo and ( techId == kTechId.Onos or techId == kTechId.Exosuit ) then
			return 999
		end
		
		if not self.dt.AllowMines and techId == kTechId.Mine then return 999 end
		
		return 0
	end
end

function Plugin:GetGameStarted()
	if self.dt.Enabled then return true end
end

function Plugin:GetIsPlaying( Player )
	return Player:GetGameStarted() and Player:GetIsOnPlayingTeam()
end

function Plugin:AlienTeamInfoUpdate( AlienTeamInfo )
	if not self.dt.Enabled then return end
	AlienTeamInfo.bioMassLevel = self.dt.BioLevel
	AlienTeamInfo.numHives = 3
	AlienTeamInfo.veilLevel = self.dt.UpgradeLevel
	AlienTeamInfo.spurLevel = self.dt.UpgradeLevel
	AlienTeamInfo.shellLevel = self.dt.UpgradeLevel
end

Shine:RegisterExtension( "pregameplus", Plugin )