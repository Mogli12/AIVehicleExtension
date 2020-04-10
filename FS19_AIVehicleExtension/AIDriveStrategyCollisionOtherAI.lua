--
-- AIDriveStrategyCollisionOtherAI
--  drive strategy to stop vehicle on collision (aiTrafficCollision trigger)
--
-- Copyright (C) GIANTS Software GmbH, Confidential, All Rights Reserved.

AIDriveStrategyCollisionOtherAI = {}
local AIDriveStrategyCollisionOtherAI_mt = Class(AIDriveStrategyCollisionOtherAI, AIDriveStrategy)

function AIDriveStrategyCollisionOtherAI:new(customMt)
	if customMt == nil then
		customMt = AIDriveStrategyCollisionOtherAI_mt
	end

	local self = AIDriveStrategy:new(customMt)
	
	self.collisionTime = 0
	self.otherAIs      = {}
	
	return self
end

function AIDriveStrategyCollisionOtherAI:delete()
	AIDriveStrategyCollisionOtherAI:superClass().delete(self)
end

function AIDriveStrategyCollisionOtherAI:setAIVehicle(vehicle)
	self.mogliText = "AIDriveStrategyCollisionOtherAI"
	AIDriveStrategyCollisionOtherAI:superClass().setAIVehicle(self, vehicle)
end

function AIDriveStrategyCollisionOtherAI:addDebugText( s )
--if self.vehicle ~= nil and type( self.vehicle.aiveAddDebugText ) == "function" then
--	self.vehicle:aiveAddDebugText( s ) 
--end
	if AIVEGlobals.devFeatures > 0 then 
		print( s ) 
	end 
end

function AIDriveStrategyCollisionOtherAI:getDriveData(dt, vX,vY,vZ)
	-- we do not check collisions at the back, at least currently
	self.vehicle.aiveMaxCollisionSpeed = nil
	self.vehicle.aiveCollisionDistance = nil
	
	if self.vehicle.movingDirection < 0 and self.vehicle:getLastSpeed(true) > 2 then
		return nil, nil, nil, nil, nil
	end
	
	local triggerId 
	if     self.vehicle.acParameters == nil 
			or self.vehicle.acParameters.upNDown 
			or not self.vehicle.acParameters.collision 
			or self.vehicle.acCollidingVehicles == nil then
		return nil, nil, nil, nil, nil			
	elseif self.vehicle.acParameters.rightAreaActive then
		triggerId = self.vehicle.acOtherCombineCollisionTriggerR
	else
		triggerId = self.vehicle.acOtherCombineCollisionTriggerL
	end
	
	local tX, tZ = nil, nil
	
	for otherAI,bool in pairs(self.otherAIs) do 
		if      bool
				and otherAI.acRefNode     ~= nil
				and otherAI.aiveIsStarted
				and otherAI.acTurnStage   ~= 0 then 
			self.otherAIs[otherAI] = true  
		else 
			self.otherAIs[otherAI] = nil 
		end 
	end 
		
	
	if triggerId ~= nil and self.vehicle.acCollidingVehicles[triggerId] ~= nil then
		for otherAI,bool in pairs(self.vehicle.acCollidingVehicles[triggerId]) do
			if      bool 
					and otherAI.spec_aiVehicle.isActive 
					-- don't brake for AutoDrive and Courseplay
					and ( otherAI.ad == nil or not ( otherAI.ad.isActive  ) )
					and ( otherAI.cp == nil or not ( otherAI.cp.isDriving ) )
					then 
				self.otherAIs[otherAI] = true 
			end 
		end 
	end 
	
	for otherAI,bool in pairs(self.otherAIs) do 
		if bool then 
			local blocked   = true
			
			if tX == nil or tZ == nil or dirX == nil or dirZ == nil then 
				tX,_,tZ     = localToWorld(self.vehicle.acRefNode, 0,0,1) 
				dirX,_,dirZ = localDirectionToWorld(self.vehicle.acRefNode, 0,0,1) 
			end 
			
			if      g_currentMission.time < self.collisionTime + 2000 then
			
				self:addDebugText("AIDriveStrategyCollisionOtherAI :: STOP due to collision 1")
				return tX, tZ, true, 0, math.huge
				
			elseif  otherAI.acRefNode         ~= nil
					and otherAI.aiveIsStarted
					and otherAI.acTurnStage       == 0 then 
			-- other vehicle is using AIVE and not turning
				local angle   = AutoSteeringEngine.getRelativeYRotation( otherAI.acRefNode, self.vehicle.acRefNode )
				if      math.abs( angle ) < 0.1667 * math.pi
						and otherAI.spec_motorized ~= nil
						and otherAI.spec_motorized.motor ~= nil
						and otherAI.spec_motorized.motor.speedLimit ~= nil then 
					local s = otherAI.spec_motorized.motor.speedLimit * math.cos( angle )
					if     self.vehicle.aiveMaxCollisionSpeed == nil
							or self.vehicle.aiveMaxCollisionSpeed  > s then
						self.vehicle.aiveMaxCollisionSpeed = s
					end 
				end 
				
				local wx1, _, wz1 = getWorldTranslation( otherAI.acRefNode )
				local wx2, _, wz2 = getWorldTranslation( self.vehicle.acRefNode )
				local dX = math.abs( ( wx1 - wx2 ) * dirZ - ( wz1 - wz2 ) * dirX )
				local dZ = math.abs( ( wx1 - wx2 ) * dirX + ( wz1 - wz2 ) * dirZ )
				local d2 = math.max( 20, dZ )
				if     self.vehicle.aiveCollisionDistance == nil
						or self.vehicle.aiveCollisionDistance  > d2 then
					self.vehicle.aiveCollisionDistance = d2
				end
				if dX > self.vehicle.acDimensions.distance + 1 or dZ > 30 then 
					self:addDebugText(string.format("Not blocked: %5.2fm,  %5.2fm", dX, dZ))
					blocked = false 
				end 
			end
			
			if blocked then
				self:addDebugText("AIDriveStrategyCollisionOtherAI : STOP due to collision 2")

				self.collisionTime = g_currentMission.time 

				if not self.stopNotificationShown then
					self.stopNotificationShown = true
					g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_CRITICAL, string.format(g_i18n:getText(AIVehicle.REASON_TEXT_MAPPING[AIVehicle.STOP_REASON_BLOCKED_BY_OBJECT]), self.vehicle:getCurrentHelper().name))
					self.vehicle:setBeaconLightsVisibility(true, false)
				end

				return tX, tZ, true, 0, math.huge
			end
		end 
	end

	if self.stopNotificationShown then
		self.stopNotificationShown = false
		self.vehicle:setBeaconLightsVisibility(false, false)
	end

--self:addDebugText("AIDriveStrategyCollisionOtherAI :: no collision ")
	return nil, nil, nil, nil, nil
end

function AIDriveStrategyCollisionOtherAI:updateDriving(dt)
end


