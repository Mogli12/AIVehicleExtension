--***************************************************************
source(Utils.getFilename("mogliScreen.lua", g_currentModDirectory))
_G[g_currentModName..".mogliScreen"].newClass( "AIVEScreen", "AIVehicleExtension", "aiveUI", "aiveUI" )
--***************************************************************

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
