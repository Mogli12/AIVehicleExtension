--***************************************************************
--
-- AIVehicleExtension
-- 
-- version 0.100 by mogli (biedens)
-- created at 2016/11/03
-- changed at 2016/11/03
--
--***************************************************************

local AIVehicleExtensionVersion=0.100

-- allow modders to include this source file together with mogliBase.lua in their mods
if AIVehicleExtension == nil or AIVehicleExtension.version == nil or AIVehicleExtension.version < AIVehicleExtensionVersion then

--***************************************************************
source(Utils.getFilename("mogliBase.lua", g_currentModDirectory))
source(Utils.getFilename("AIDriveStrategyMogli.lua", g_currentModDirectory))
--source(Utils.getFilename(".lua", g_currentModDirectory))
--source(Utils.getFilename(".lua", g_currentModDirectory))

_G[g_currentModName..".mogliBase"].newClass( "AIVehicleExtension", "aiveStateState" )
--***************************************************************

AIVehicleExtension.version              = AIVehicleExtensionVersion


function AIVehicleExtension:load(saveGame)
	self.aiveState = {}
	
	self.aiveSetState       = AIVehicleExtension.mbSetState
	self.aiveGetVehicleData = AIVehicleExtension.aiveGetVehicleData
	self.aiveAddDebugText   = AIVehicleExtension.aiveAddDebugText
	self.aiveAddDebugStart  = AIVehicleExtension.aiveAddDebugStart
	self.aiveAddDebugEnd    = AIVehicleExtension.aiveAddDebugEnd
	self.aiveDriveStrategy  = nil
	
	AIVehicleExtension.registerState( self, "enabled",  false )
	AIVehicleExtension.registerState( self, "turnLeft", false )
	AIVehicleExtension.registerState( self, "uTurn",    false )	
end

function AIVehicleExtension:aiveAddDebugText( s )
	if AIVehicle.aiDebugRendering and self.debugTexts ~= nil then
		table.insert(self.debugTexts, s)
	end
end

function AIVehicleExtension:aiveAddDebugStart( m )
	self:aiveAddDebugText( "---> AIVehicleExtension:"..m )
end

function AIVehicleExtension:aiveAddDebugEnd( m )
	self:aiveAddDebugText( "<--- AIVehicleExtension:"..m )
end

function AIVehicleExtension:afterSetDriveStrategies()
	if self.aiveState.enabled then
		local i = table.getn( self.driveStrategies )

		self:aiveAddDebugStart( "afterSetDriveStrategies" )
		
		self:aiveGetVehicleData()
		
		self.aiveDriveStrategy = AIDriveStrategyMogli:new();
		self.aiveDriveStrategy:setAIVehicle(self);		
		table.insert( self.driveStrategies, i, self.aiveDriveStrategy )
		
		self:aiveAddDebugEnd( "afterSetDriveStrategies" )
	end
end

function AIVehicleExtension:aiveGetVehicleData()
	self:aiveAddDebugStart( "aiveGetVehicleData" )
	
	
	
	
	self:aiveAddDebugEnd( "aiveGetVehicleData" )
end

function AIVehicleExtension:onStopAiVehicle()
	self:aiveAddDebugStart( "onStopAiVehicle" )
	
	self.aiveDriveStrategy  = nil
	
	self:aiveAddDebugEnd( "onStopAiVehicle" )
end

function AIVehicleExtension.consoleCommandParseArg( v )
	if     v == nil then
		return 
	elseif tonumber( v ) ~= nil then
		return tonumber( v )
	elseif string.sub( v, 1, 1 ) == "'" and string.sub( v, -1 ) == "'" then
		return string.sub( string.sub( v, 2 ), -1 )
	elseif v == "true" then
		return true
	elseif v == "false" then
		return false
	end
	return v
end


function AIVehicleExtension.consoleCommandSetState( name, input )
	if g_currentMission.controlledVehicle ~= nil and g_currentMission.controlledVehicle.aiveSetState ~= nil then
		print("Invalid vehicle")
		return 
	end
	self = g_currentMission.controlledVehicle
	if name == nil or self.aiveState[name] == nil then
		print("Invalid state name: "..tostring(name))
		return 
	end
	if input == nil then
		print("Invalid state name: nil")
		return 
	end
	local value = AIVehicleExtension.consoleCommandParseArg( input )	
	if type( value ) ~= type( self.aiveState[name] ) then
		print("Invalid paramter type: '"..tostring(value).."' ("..type(value)..")")
		return 
	end
	
	self:aiveSetState( name, value )
end

addConsoleCommand("aiveSetState", "Set state <name> <value>", "consoleCommandSetState", AIVehicleExtension)


end

