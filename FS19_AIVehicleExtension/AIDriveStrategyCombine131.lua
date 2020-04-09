AIDriveStrategyCombine131 = {}
AIDriveStrategyCombine131.REVERSE_DISTANCE_AFTER_STOPPED = 0.25
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
	self.allowedToDriveTimer = 0 
	self.blockedReason = 0
	return self
end

function AIDriveStrategyCombine131:setAIVehicle(vehicle)
	self.mogliText = "AIDriveStrategyCombine131"
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
--if self.vehicle ~= nil and type( self.vehicle.aiveAddDebugText ) == "function" then
--	self.vehicle:aiveAddDebugText( s ) 
--end
	if AIVEGlobals.devFeatures > 0 then 
		print( s ) 
	end 
end

function AIDriveStrategyCombine131:getDriveData(dt, vX,vY,vZ)
	local isTurning = self.vehicle:getRootVehicle():getAIIsTurning()
	local allowedToDrive = true
	local waitForStraw = false
	local maxSpeed = math.huge
	
	local blockedReason = 0
	
	for _, combine in pairs(self.combines) do
		if not combine:getIsThreshingAllowed() then
			self.vehicle:stopAIVehicle(AIVehicle.STOP_REASON_REGULAR)
			self:addDebugText("Stopping AIVehicle - combine not allowed to thresh")
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
						blockedReason = 1
					elseif trailerInTrigger and targetObject == nil then
						blockedReason = 2
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
				
				if     fillLevel < 0.1 then
					self.wasEmpty = true
				elseif fillLevel > 0.2 * capacity then
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
					end
					self.wasCompletelyFull = false
				end
				if currentPipeTargetState ~= pipeState then
					combine:setPipeState(pipeState)
				end
				allowedToDrive = fillLevel < capacity
			
				if trailerInTrigger and not self.wasEmpty then 
					if self.vehicle.acParameters.waitForPipe then 
						allowedToDrive = false
						blockedReason = 3 
					elseif isTurning and combine:getCanDischargeToObject(dischargeNode) then 
						allowedToDrive = false 
						blockedReason = 4
					end 
				end
				local freeFillLevel = capacity - fillLevel
			--if freeFillLevel < self.slowDownFillLevel then
			--	-- we want to drive at least 2 km/h to avoid combine stops too early
			--	maxSpeed = 2 + (freeFillLevel / self.slowDownFillLevel) * self.slowDownStartSpeed
			--	blockedReason = 5
			--end
			end
		end
	end 
	
	if not allowedToDrive and blockedReason == 0 then 
		blockedReason = 6 
	end 
	
	if self.blockedReason ~= blockedReason then 
		self.blockedReason = blockedReason 
		if     blockedReason == 1 then 
			self:addDebugText("COMBINE -> Waiting for trailer enter the trigger")
		elseif blockedReason == 2 then 
			self:addDebugText("COMBINE -> Waiting for pipe hitting the trailer")
		elseif blockedReason == 3 then 
			self:addDebugText("COMBINE -> Waiting for trailer to unload")
		elseif blockedReason == 4 then 
			self:addDebugText("COMBINE -> Unload to trailer on headland")
		elseif blockedReason == 5 then 
			self:addDebugText(string.format("COMBINE -> Slow down because nearly full: %.2f", maxSpeed))
		elseif blockedReason == 6 then 
			self:addDebugText("COMBINE is not allowed to drive")
		end
	end
	
	if not allowedToDrive then
		local refNode = self.vehicle:getAIVehicleDirectionNode()
		local wx,_,wz = getWorldTranslation( refNode )
		self.restartPointX2 = wx 		
		self.restartPointZ2 = wz
		if self.restartPointX == nil then 
			self.restartPointX = wx 		
			self.restartPointZ = wz
			self.restartPoint2 = 0
			self.restartDirX,_,self.restartDirZ = localToWorld( refNode, 0, 0, 5 ) 
		else 
			self.restartPoint2 = ( wx - self.restartPointX  )^2 + ( wz - self.restartPointZ  )^2
		end 
	--self.allowedToDriveTimer = 2000
		return 0, 1, true, 0, math.huge
	end 
	
	if self.restartPointX ~= nil then 
		for _, combine in pairs(self.combines) do
			 if not combine:getIsTurnedOn() then
				combine:setIsTurnedOn(true)
			end
		end
		
		local refNode   = self.vehicle:getAIVehicleDirectionNode()
		local wx, _, wz = getWorldTranslation( refNode )
		local l1        = ( wx - self.restartPointX  )^2 + ( wz - self.restartPointZ  )^2
		local l2        = ( wx - self.restartPointX2 )^2 + ( wz - self.restartPointZ2 )^2
		local dts       = math.max(AIDriveStrategyCombine131.REVERSE_DISTANCE_AFTER_STOPPED - l1, AIDriveStrategyCombine131.REVERSE_DISTANCE_AFTER_STOPPED - self.restartPoint2 - l2)
		if dts > 0 then
			-- closer than 'AIDriveStrategyCombine131.REVERSE_DISTANCE_AFTER_STOPPED' to the 1st stop point or closer than that plus distance between stop points
			--self:addDebugText("Reverse")
			return self.restartDirX, self.restartDirZ, self.vehicle.acParameters.inverted, 7, dts
		end 
		
		self.restartPointX  = nil 
		self.restartPointZ  = nil 
		self.restartPointX2 = nil 
		self.restartPointZ2 = nil 
		self.restartPoint2  = nil
		self.restartDirX    = nil 
		self.restartDirZ    = nil 
	end 
	
--if self.allowedToDriveTimer > 0 then 
--	for _, combine in pairs(self.combines) do
--		 if not combine:getIsTurnedOn() then
--			combine:setIsTurnedOn(true)
--		end
--	end
--	maxSpeed = math.min( maxSpeed, math.max( ( 2000 - self.allowedToDriveTimer ) * 0.005, 2 ) )		
--	self.allowedToDriveTimer = self.allowedToDriveTimer - dt 
--	
--	if self.allowedToDriveTimer > 2000 then 
--		local tX,_,tZ  = localToWorld( self.vehicle:getAIVehicleDirectionNode(), 0, 0, 1 )
--	end 
--end
	
--self:addDebugText("COMBINE may drive")
	return nil, nil, nil, maxSpeed, nil
end

function AIDriveStrategyCombine131:updateDriving(dt)
end