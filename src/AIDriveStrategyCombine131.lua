AIDriveStrategyCombine131 = {}
local AIDriveStrategyCombine131_mt = Class(AIDriveStrategyCombine131, AIDriveStrategy)

function AIDriveStrategyCombine131:new(customMt)
	if customMt == nil then
		customMt = AIDriveStrategyCombine131_mt
	end
	local self = AIDriveStrategy:new(customMt)
	self.combines = {}
	self.notificationFullGrainTankShown = false
	self.notificationGrainTankWarningShown = false
	self.beaconLightsActive = false
	self.slowDownFillLevel = 200
	self.slowDownStartSpeed = 20
	self.forageHarvesterFoundTimer = 0
	return self
end

function AIDriveStrategyCombine131:setAIVehicle(vehicle)
	AIDriveStrategyCombine131:superClass().setAIVehicle(self, vehicle)
	if SpecializationUtil.hasSpecialization(Combine, self.vehicle.specializations) then
		table.insert(self.combines, self.vehicle)
	end
	for _,implement in pairs(self.vehicle:getAttachedAIImplements()) do
		if SpecializationUtil.hasSpecialization(Combine, implement.object.specializations) then
			table.insert(self.combines, implement.object)
		end
	end
end

function AIDriveStrategyCombine131:update(dt)
end


function AIDriveStrategyCombine131:addDebugText( s )
	if self.vehicle ~= nil and type( self.vehicle.aiveAddDebugText ) == "function" then
		self.vehicle:aiveAddDebugText( s ) 
	end
end

function AIDriveStrategyCombine131:getDriveData(dt, vX,vY,vZ)
	local isTurning = self.vehicle:getRootVehicle():getAIIsTurning()
	local allowedToDrive = true
	local waitForStraw = false
	local maxSpeed = math.huge
	for _, combine in pairs(self.combines) do
		if not combine:getIsThreshingAllowed() then
			self.vehicle:stopAIVehicle(AIVehicle.STOP_REASON_REGULAR)
			self:debugPrint("Stopping AIVehicle - combine not allowed to thresh")
			return nil, nil, nil, nil, nil
		end
		if combine.spec_pipe ~= nil then
			local fillLevel = 0
			local capacity = 0
			local trailerInTrigger = false
			local dischargeNode = combine:getCurrentDischargeNode()
			if dischargeNode ~= nil then
				fillLevel = combine:getFillUnitFillLevel(dischargeNode.fillUnitIndex)
				capacity = combine:getFillUnitCapacity(dischargeNode.fillUnitIndex)
			end
			local trailer = NetworkUtil.getObject(combine.spec_pipe.nearestObjectInTriggers.objectId)
			local trailerFillUnitIndex = combine.spec_pipe.nearestObjectInTriggers.fillUnitIndex
			if trailer ~= nil then
				trailerInTrigger = true
			end
			local currentPipeTargetState = combine.spec_pipe.targetState
			if capacity == math.huge then
				-- forage harvesters
				if currentPipeTargetState ~= 2 then
					combine:setPipeState(2)
				end
				if not isTurning then
					if trailerInTrigger then
						local fillType = combine:getDischargeFillType(dischargeNode)
						if fillType == FillType.UNKNOWN then
							-- if nothing is in combine fillUnit we just check if we're targetting the trailer with the trailers first fill type or the current fill type if something is loaded
							fillType = trailer:getFillUnitFillType(trailerFillUnitIndex)
							if fillType == FillType.UNKNOWN then
								fillType = trailer:getFillUnitFirstSupportedFillType(trailerFillUnitIndex)
							end
							combine:setForcedFillTypeIndex(fillType)
						else
							-- otherwise we check if the fill type of the combine is supported on the trailer
							combine:setForcedFillTypeIndex(nil)
						end
					end
					local targetObject, _ = combine:getDischargeTargetObject(dischargeNode)
					allowedToDrive = trailerInTrigger and targetObject ~= nil
					if not trailerInTrigger then
						self:addDebugText("COMBINE -> Waiting for trailer enter the trigger")
					elseif trailerInTrigger and targetObject == nil then
						self:addDebugText("COMBINE -> Waiting for pipe hitting the trailer")
					end
				end
			else
				-- combine harvesters
				local pipeState = currentPipeTargetState
				if fillLevel > (0.8*capacity) then
					if not self.beaconLightsActive then
						self.vehicle:setAIMapHotspotBlinking(true)
						self.vehicle:setBeaconLightsVisibility(true)
						self.beaconLightsActive = true
					end
					if not self.notificationGrainTankWarningShown then
						g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_CRITICAL, string.format(g_i18n:getText("ingameNotification_aiVehicleReasonGrainTankIsNearlyFull"), self.vehicle:getCurrentHelper().name) )
						self.notificationGrainTankWarningShown = true
					end
				else
					if self.beaconLightsActive then
						self.vehicle:setAIMapHotspotBlinking(false)
						self.vehicle:setBeaconLightsVisibility(false)
						self.beaconLightsActive = false
					end
					self.notificationGrainTankWarningShown = false
				end
				if fillLevel == capacity then
					pipeState = 2
					self.wasCompletelyFull = true
					if self.notificationFullGrainTankShown ~= true then
						g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_CRITICAL, string.format(g_i18n:getText(AIVehicle.REASON_TEXT_MAPPING[AIVehicle.STOP_REASON_GRAINTANK_IS_FULL]), self.vehicle:getCurrentHelper().name) )
						self.notificationFullGrainTankShown = true
					end
				else
					self.notificationFullGrainTankShown = false
				end
				
				if     fillLevel <= 0 then
					self.wasEmpty = true
				elseif fillLevel >= 0.1 * capacity then
					self.wasEmpty = false
				elseif self.wasEmpty == nil then
					self.wasEmpty = false
				end
								
				if trailerInTrigger then
					pipeState = 2
				end
				if not trailerInTrigger then
					if fillLevel < capacity * 0.8 then
						self.wasCompletelyFull = false
						if not combine:getIsTurnedOn() then
							combine:setIsTurnedOn(true)
						end
					end
				end
				if not trailerInTrigger and fillLevel < capacity then
					pipeState = 1
				end
				if fillLevel < 0.1 then
					if not combine.spec_pipe.aiFoldedPipeUsesTrailerSpace then
						if not trailerInTrigger then
							pipeState = 1
						end
						if not combine:getIsTurnedOn() then
							combine:setIsTurnedOn(true)
						end
					end
					self.wasCompletelyFull = false
				end
				if currentPipeTargetState ~= pipeState then
					combine:setPipeState(pipeState)
				end
				allowedToDrive = fillLevel < capacity
			--if pipeState == 2 and self.wasCompletelyFull then
			--	allowedToDrive = false
			--	self:addDebugText("COMBINE -> Waiting for trailer to unload")
			--end
			
				if trailerInTrigger and not self.wasEmpty then 
					if self.vehicle.acParameters.waitForPipe then 
						allowedToDrive = false
						self:addDebugText("COMBINE -> Waiting for trailer to unload")
					elseif isTurning and combine:getCanDischargeToObject(dischargeNode) then 
						allowedToDrive = false 
						self:addDebugText("COMBINE -> Unload to trailer on headland")
					end 
				end
				local freeFillLevel = capacity - fillLevel
				if freeFillLevel < self.slowDownFillLevel then
					-- we want to drive at least 2 km/h to avoid combine stops too early
					maxSpeed = 2 + (freeFillLevel / self.slowDownFillLevel) * self.slowDownStartSpeed
					self:addDebugText(string.format("COMBINE -> Slow down because nearly full: %.2f", maxSpeed))
				end
			end
			if not trailerInTrigger then
				if combine.spec_combine.isSwathActive then
					if combine.spec_combine.strawPSenabled then
						waitForStraw = true
					end
				end
			end
		end
	end
	--if isTurning and waitForStraw then
	--self:addDebugText("COMBINE -> Waiting for straw to drop")
	--local h = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, self.vehicle.aiDriveTarget[1],0,self.vehicle.aiDriveTarget[2])
	--local x,_,z = worldToLocal(self.vehicle:getAIVehicleDirectionNode(), self.vehicle.aiDriveTarget[1],h,self.vehicle.aiDriveTarget[2])
	--local dist = MathUtil.vector2Length(vX-x, vZ-z)
	--return x, z, false, 10, dist
	if not allowedToDrive then
		return 0, 1, true, 0, math.huge
	else
		return nil, nil, nil, maxSpeed, nil
	end
end

function AIDriveStrategyCombine131:updateDriving(dt)
end