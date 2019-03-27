AIVEImplement = {}

function AIVEImplement.prerequisitesPresent(specializations)
	return true
end

function AIVEImplement:load(saveGame)
end

function AIVEImplement:delete()
end

function AIVEImplement:readStream(streamId, connection)
end

function AIVEImplement:writeStream(streamId, connection)
end

function AIVEImplement:mouseEvent(posX, posY, isDown, isUp, button)
end

function AIVEImplement:keyEvent(unicode, sym, modifier, isDown)
end

function AIVEImplement:update(dt)
end

function AIVEImplement:updateTick(dt)
end

function AIVEImplement:draw()
end

function AIVEImplement:onSetLowered(lowered)
	local root = self:getRootAttacherVehicle()
	if root ~= nil then
		AIVehicleExtension.onChangeLowered( root, lowered )
	end
end
function AIVEImplement:onLowerAll(doLowering)
	local root = self:getRootAttacherVehicle()
	if root ~= nil then
		AIVehicleExtension.onChangeLowered( root, doLowering )
	end
end
function AIVEImplement:onTurnedOn()
	local root = self:getRootAttacherVehicle()
	if root ~= nil then
		AIVehicleExtension.onChangeLowered( root, true )
	end
end
function AIVEImplement:onTurnedOff()
	local root = self:getRootAttacherVehicle()
	if root ~= nil then
		AIVehicleExtension.onChangeLowered( root, false )
	end
end
function AIVEImplement:setFoldState(direction, moveToMiddle)
	local root = self:getRootAttacherVehicle()
	if root ~= nil then
		AIVehicleExtension.onChangeLowered( root, not ( moveToMiddle ) )
	end
end