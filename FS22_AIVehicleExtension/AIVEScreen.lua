--***************************************************************
source(Utils.getFilename("mogliScreen.lua", g_currentModDirectory))
_G[g_currentModName..".mogliScreen"].newClass( "AIVEScreen", "AIVehicleExtension", "aiveUI", "aiveUI" )
--***************************************************************

function AIVEScreen:mogliScreenOnClose()
	if self.vehicle ~= nil then
		AIVehicleExtension.sendParameters( self.vehicle )
	end
end

function AIVEScreen:onClickMagic()
	if self.vehicle ~= nil then
		AIVehicleExtension.onMagic( self.vehicle )
	end
end

function AIVEScreen:onClickNext()
	if self.vehicle ~= nil then
		AIVehicleExtension.nextTurnStage( self.vehicle )
	end
end

function AIVEScreen:onClickDefaults()
	if self.vehicle ~= nil then
		self.vehicle.acParameters = AIVehicleExtension.getParameterDefaults( )
	end
end
