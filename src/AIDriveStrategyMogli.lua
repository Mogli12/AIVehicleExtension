--
-- AIDriveStrategyMogli
--

-- AIDriveStrategy.new is a function
-- AIDriveStrategy.isa is a function
-- AIDriveStrategy.getDistanceToEndOfField is a function
-- AIDriveStrategy.getDriveData is a function
-- AIDriveStrategy.delete is a function
-- AIDriveStrategy.draw is a function
-- AIDriveStrategy.superClass is a function
-- AIDriveStrategy.updateDriving is a function
-- AIDriveStrategy.class is a function
-- AIDriveStrategy.setAIVehicle is a function
-- AIDriveStrategy.update is a function
-- AIDriveStrategy.copy is a function

source(Utils.getFilename("AITurnStrategyMogli.lua", g_currentModDirectory));
source(Utils.getFilename("AITurnStrategyMogliDefault.lua", g_currentModDirectory));
source(Utils.getFilename("AITurnStrategyMogli_C_R.lua", g_currentModDirectory));


AIDriveStrategyMogli = {}

AIDriveStrategyMogli.searchStart  = 3 
AIDriveStrategyMogli.searchUTurn  = 2
AIDriveStrategyMogli.searchCircle = 1

local AIDriveStrategyMogli_mt = Class(AIDriveStrategyMogli, AIDriveStrategy)

function AIDriveStrategyMogli:new(customMt)
	if customMt == nil then
		customMt = AIDriveStrategyMogli_mt
	end
	local self = AIDriveStrategy:new(customMt)
	return self
end

function AIDriveStrategyMogli:setAIVehicle(vehicle)
	AIDriveStrategyMogli:superClass().setAIVehicle(self, vehicle)
	
--==============================================================				
--==============================================================					
	AutoSteeringEngine.invalidateField( vehicle )		
	AutoSteeringEngine.checkTools1( vehicle, true )
	AutoSteeringEngine.saveDirection( vehicle, false, true )

	vehicle.acClearTraceAfterTurn = true
	AIVehicleExtension.resetAIMarker( vehicle )	
	AIVehicleExtension.initMogliHud(vehicle)
	
	self.vehicle.aiToolReverserDirectionNode = AIVehicleUtil.getAIToolReverserDirectionNode(self.vehicle);
	
	if not ( vehicle.acSpeedFactorVerified ) then
		vehicle.acSpeedFactorVerified = true
		local maxSpeed = 3.6 * AutoSteeringEngine.getToolsSpeedLimit( vehicle )
		local cs = math.min( math.floor( 0.5 + maxSpeed * vehicle.acParameters.speedFactor ), 3.6 * AIVEGlobals.maxSpeed )
		vehicle.acParameters.speedFactor = cs / maxSpeed
	end
		
	vehicle.acCCSpeed				 = vehicle.cruiseControl.speed

	AutoSteeringEngine.invalidateField( vehicle )
	
		AutoSteeringEngine.checkTools1( vehicle, true )
	
		AutoSteeringEngine.setToolsAreTurnedOn( vehicle, true, false )
	
	AIVehicleExtension.roueInitWheels( vehicle );
	
	vehicle.acDimensions	= nil;
	AIVehicleExtension.checkState( vehicle )
	
    self.turnDataIsStable = false;
    self.turnDataIsStableCounter = 0;

    self.lastLookAheadDistance = 5; -- 30;
	self:updateTurnData()
	self.turnData.stage = -3
	
	vehicle.turnTimer		 = vehicle.acDeltaTimeoutWait;
	vehicle.aiRescueTimer = vehicle.acDeltaTimeoutStop;
	vehicle.waitForTurnTime = 0;
	vehicle.acLastAcc			 = 0;
	vehicle.acLastWantedSpeed = 0;
	
	AIVehicleExtension.setInt32Value( vehicle, "speed2Level", 2 )
	
	if AIVehicleUtil.invertsMarkerOnTurn( vehicle, vehicle.acParameters.leftAreaActive ) then
		if vehicle.acParameters.leftAreaActive then
			AIVehicle.aiRotateLeft(vehicle);
		else
			AIVehicle.aiRotateRight(vehicle);
		end			
	end
	
	AIVehicleExtension.sendParameters(vehicle);
	
	vehicle.acStat = nil		
--==============================================================				
--==============================================================				
		
	
	
	self.turnLeft = not ( self.vehicle.acParameters.rightAreaActive )
	self.turnStrategies = { }
	
	self.turnStrategies[1] = AITurnStrategyMogliDefault:new()
	
	self.ts_C_R = table.getn( self.turnStrategies ) + 1
	self.turnStrategies[self.ts_C_R] = AITurnStrategyMogli_C_R:new()
		
--self.ts_U_O = table.getn( self.turnStrategies ) + 1
--self.turnStrategies[self.ts_U_O] = AITurnStrategyMogli_U_O:new()
		
	for _,turnStrategy in pairs(self.turnStrategies) do
		turnStrategy:setAIVehicle(self.vehicle);
	end
	self.activeTurnStrategy = nil

	self.search     = AIDriveStrategyMogli.searchStart 
	AIVehicleExtension.setAIImplementsMoveDown(self.vehicle,true)
end

function AIDriveStrategyMogli:delete()
		
--==============================================================				
--==============================================================				
	local veh = self.vehicle 
	
	veh.aiveIsStarted = false
	
	if veh.acStat ~= nil then
		for n,s in pairs(veh.acStat) do 
			print(string.format("%s: %.0f (%.0f / %.0f)", n, s.t/s.n, s.t, s.n))
		end
	end
	AutoSteeringEngine.invalidateField( veh )		
	AIVehicleExtension.roueReset( veh )
	if veh.acCCSpeed ~= nil then
		veh:setCruiseControlMaxSpeed( veh.acCCSpeed )
	end
	
	AIVehicleExtension.resetAIMarker( veh )
	veh.acImplementsMoveDown = false
--==============================================================				
--==============================================================				
		
	AIDriveStrategyMogli:superClass().delete(self);

	self.vehicle:aiTurnOff();
	for _,implement in pairs(self.vehicle.aiImplementList) do
		if implement.object ~= nil then
			implement.object:aiTurnOff();
			implement.object:aiRaise();
		end
	end
end

function AIDriveStrategyMogli:update(dt)
	for _,turnStrategy in pairs(self.turnStrategies) do
		turnStrategy:update(dt)
	end
	self.turnLeft = not ( self.vehicle.acParameters.rightAreaActive )
end

function AIDriveStrategyMogli:draw()
end

function AIDriveStrategyMogli:addDebugText( s )
	if self.vehicle ~= nil and type( self.vehicle.aiveAddDebugText ) == "function" then
		self.vehicle:aiveAddDebugText( s ) 
	end
end

function AIDriveStrategyMogli:printReturnInfo( tX, vY, tZ, moveForwards, maxSpeed, distanceToStop )
	local vehicle = self.vehicle
	local x,y,z
	if tX ~= nil and vY ~= nil and tZ ~= nil and vehicle.aiVehicleDirectionNode ~= nil then
		x,y,z = worldToLocal( vehicle.aiVehicleDirectionNode, tX, vY, tZ )
	end
	
	local turnStage = "???"
	if self.activeTurnStrategy ~= nil then
		turnStage = tostring(self.turnData.stage)
	elseif self.search == nil then
		turnStage = " 0"
	else
		turnStage = "-"..self.search
	end
	
	vehicle.aiveReturnInfo = turnStage..": "..AutoSteeringEngine.posToString(x).." "..AutoSteeringEngine.posToString(z).." "..tostring(moveForwards).." "..AutoSteeringEngine.posToString(maxSpeed).." "..AutoSteeringEngine.posToString(distanceToStop)
end

function AIDriveStrategyMogli:updateTurnData()
	AIDriveStrategyStraight.updateTurnData( self )

	self.turnData.driveStrategy = self
end

function AIDriveStrategy:adjustPosition( eX, eZ, moveForwards, distanceToStop, inverse )
	local vehicle = self.vehicle
	local mF2     = moveForwards
	if vehicle.acParameters.inverted then
		mF2 = not moveForwards
	end
	
	if vehicle.aiveChain == nil or vehicle.aiveChain.refNode == nil then
		return eX, eZ, mF2
	end
	
	local refNode = vehicle.aiveChain.refNode
	
	if      not ( moveForwards ) 
			and vehicle.articulatedAxis ~= nil 
      and vehicle.articulatedAxis.aiRevereserNode ~= nil then
		refNode = vehicle.aiVehicleDirectionNode
	elseif  vehicle.aiVehicleDirectionNode ~= nil then
		refNode = vehicle.aiVehicleDirectionNode
	end
	
	local nIn  = vehicle.aiveChain.refNode
	local nOut = refNode
	
	if inverse then
		nIn  = refNode
		nOut = vehicle.aiveChain.refNode
	end
	
	local eY       = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, eX, 1, eZ) 
	
	local lX,lY,lZ = worldToLocal( nIn,  eX, eY, eZ )
	
--if not inverse and distanceToStop ~= nil then
--	local d = math.max( 1, math.min( 6, distanceToStop ) )
--	local l = Utils.vector3Length( lX,lY,lZ )
--	
--	
--	if 0.1 < math.abs( l ) and math.abs( 1.2 * l ) < d then
--		local f = d / l
--		lX = lX * f
--		lY = lY * f
--		lZ = lZ * f
--	end
--end
	
	local tX,_,tZ  = localToWorld( nOut, lX, lY, lZ )
	
--print(string.format("%5.2f %5.2f => %5.2f %5.2f => %5.2f %5.2f", eX, eZ, lX, lZ, tX, tZ ))
	
	return tX, tZ, mF2
end

function AIDriveStrategyMogli:gotoNextStage()
	if self.activeTurnStrategy ~= nil then
		self.activeTurnStrategy:gotoNextStage(self.turnData)
	else
		self.search = nil
	end
end

function AIDriveStrategyMogli:getDriveData(dt, vX2,vY2,vZ2)
	local veh = self.vehicle 
	
	if veh.acPause then
		veh.isHirableBlocked = true		
		AIVehicleExtension.setStatus( veh, 0 )
		return vX2, vZ2, moveForwards, 0, 0
	end
		
	local vX, vY, vZ
	if veh.aiveChain == nil or veh.aiveChain.refNode == nil then
		vX = vX2
		vY = vY2
		vZ = vZ2
	else
		vX,vY,vZ = getWorldTranslation( veh.aiveChain.refNode )
	end

--veh.acAiPos = { vX, vY, vZ }
	AutoSteeringEngine.setAiWorldPosition( veh, vX, vY, vZ )
	
	if veh.turnTimer == nil then 
		veh:acDebugPrint("turnTimer is nil: "..tostring(self.search).." / "..tostring(self.turnData.stage))
		veh.turnTimer = 0
	end
		
	veh.aiSteeringSpeed = veh.acSteeringSpeed
	
	local resetState = false 
	if self.activeTurnStrategy ~= nil then
		local tX, tZ, moveForwards, maxSpeed, distanceToStop = self.activeTurnStrategy:getDriveData(dt, vX,vY,vZ, self.turnData)
		if tX == nil then
			for _,turnStrategy in pairs(self.turnStrategies) do
				turnStrategy:onEndTurn(self.turnLeft)
			end
			self.activeTurnStrategy = nil
			veh.turnTimer		   = veh.acDeltaTimeoutRun
			veh.aiRescueTimer  = math.max( veh.aiRescueTimer, veh.acDeltaTimeoutStop )
			
			if self.search == nil then
				self.search = AIDriveStrategyMogli.searchCircle
			end			
			veh.acLastAbsAngle = nil
			resetState         = true
		else
			local tX2, tZ2, mF2 = self:adjustPosition( tX, tZ, moveForwards, distanceToStop )
			self.lastDirection = { tX2, tZ2 }
			self:printReturnInfo( tX2, vY, tZ2, mF2, maxSpeed, distanceToStop )
			
			if maxSpeed == 0 then
				veh.acLastWantedSpeed = nil
			end
			
			AIVehicleExtension.statEvent( veh, "tT", dt )
			return tX2, tZ2, mF2, maxSpeed, distanceToStop
		end		
	end
	
	if self.search == nil then
		veh.acTurnStage = 0
	else
		veh.acTurnStage = -self.search 
	end
		
	local tX, tZ, maxSpeed, distanceToStop = nil, nil, 0, 0			

	AIVehicleExtension.statEvent( veh, "t0", dt )

	AIVehicleExtension.checkState( veh, resetState )
	if not AutoSteeringEngine.hasTools( veh ) then
		veh:stopAIVehicle(AIVehicle.STOP_REASON_UNKOWN)
		return;
	end
	
	local allowedToDrive =  AutoSteeringEngine.checkAllowedToDrive( veh, not ( veh.acParameters.isHired  ) )
		
	self.noSneak	   = false
	self.isAnimPlaying = false
	if self.search ~= nil or AIVEGlobals.raiseNoFruits > 0 then
		local isPlaying, noSneak = AutoSteeringEngine.checkIsAnimPlaying( veh, veh.acImplementsMoveDown )
		
		if isPlaying then
			if	self.animWaitTimer == nil then
				self.animWaitTimer = veh.acDeltaTimeoutWait
				self.isAnimPlaying = true
			elseif self.animWaitTimer > 0 then
				self.animWaitTimer = self.animWaitTimer - dt
				self.isAnimPlaying = true
			end
		else
			self.animWaitTimer = nil
			noSneak			= false
		end
		
		if noSneak then
			if	self.noSneakTimer == nil then
				self.noSneakTimer = veh.acDeltaTimeoutWait
				self.noSneak = true
			elseif self.noSneakTimer > 0 then
				self.noSneakTimer = self.noSneakTimer - dt
				self.noSneak = true
			end
		else
			self.noSneakTimer = nil
		end
		
		if	  allowedToDrive 
				and self.noSneak then
			AIVehicleExtension.setStatus( veh, 3 )
			allowedToDrive = false
		end
	else
		self.animWaitTimer = nil
		self.noSneakTimer  = nil
	end
	
	local fruitsDetected, fruitsAll = AutoSteeringEngine.hasFruits( veh, 0.9 )
	
	if      allowedToDrive
			and ( fruitsDetected 
				or ( self.search == nil and AIVEGlobals.raiseNoFruits <= 0 )
				or self.acImplementsMoveDown )
			and not AutoSteeringEngine.getIsAIReadyForWork( veh ) then
		allowedToDrive = false
	end
	
	local speedLevel = 4
	if self.search == nil then
		speedLevel = 2
	end
--if veh.speed2Level ~= nil and 0 <= veh.speed2Level and veh.speed2Level <= 4 then
--	speedLevel = veh.speed2Level;
--end
	-- 20 km/h => lastSpeed = 5.555E-3 => speedLevelFactor = 234 * 5.555E-3 = 1.3
	-- 10 km/h =>						 speedLevelFactor				  = 0.7
	local speedLevelFactor = math.min( veh.lastSpeed * 234, 0.5 ) 

	if not allowedToDrive or speedLevel == 0 then
		AIVehicleExtension.statEvent( veh, "tS", dt )
		veh.isHirableBlocked = true		
		
		if self.lastDirection == nil then
			self.lastDirection = { AutoSteeringEngine.getWorldTargetFromSteeringAngle( veh, 0 ) }
		end
		
		return self.lastDirection[1], self.lastDirection[2], not veh.acParameters.inverted, AutoSteeringEngine.getMaxSpeed( veh, dt, 1, false, true, 0, false, 0.7 ), 0
	end
	
	if veh.isHirableBlocked then
		veh.isHirableBlocked = false
	--AIVehicleExtension.setAIImplementsMoveDown(veh,true,true)
	end
	
	if self.lastDriveData ~= nil and g_currentMission.time < self.lastDriveDataTime then
		self.lastDriveDataDt = self.lastDriveDataDt + dt
		return unpack( self.lastDriveData )
	end
	
	self.lastDriveData = nil
	if self.lastDriveDataDt ~= nil and self.lastDriveDataDt > 0 then
		dt = dt + self.lastDriveDataDt
	end
	
	local offsetOutside = 0;
	if	 veh.acParameters.rightAreaActive then
		offsetOutside = -1;
	elseif veh.acParameters.leftAreaActive then
		offsetOutside = 1;
	end;
	
	veh.turnTimer		  = veh.turnTimer - dt;
	veh.acTurnOutsideTimer = veh.acTurnOutsideTimer - dt;

--==============================================================				
	
	if	 self.search ~= nil then
		veh.aiRescueTimer = veh.aiRescueTimer - dt;
	else
		veh.aiRescueTimer = math.max( veh.aiRescueTimer, veh.acDeltaTimeoutStop )
	end
	
	if veh.aiRescueTimer < 0 then
		veh:stopAIVehicle(AIVehicle.STOP_REASON_BLOCKED_BY_OBJECT)
		return
	end
		
--==============================================================				
	local angle, angle2 = nil, nil
	local angleMax = veh.acDimensions.maxLookingAngle;
	local detected = false;
	local border   = 0;
	local angleFactor;
	local offsetOutside;
	local noReverseIndex = 0;
	local angleOffset = 6;
	local angleOffsetStrict = 4;
	local stoppingDist = 0.5;
	local turn2Outside = veh.acTurn2Outside;
--==============================================================		
--==============================================================		
	local turnAngle2 = AutoSteeringEngine.getTurnAngle(veh)
	local turnAngle  = math.deg(turnAngle2)

	if veh.acParameters.leftAreaActive then
		turnAngle = -turnAngle;
	end;

	if fruitsDetected and self.search ~= nil then
		if veh.acFruitAllTimer == nil then
			veh.acFruitAllTimer = veh.acDeltaTimeoutStart
		elseif veh.acFruitAllTimer > 0 then
			veh.acFruitAllTimer = veh.acFruitAllTimer - dt
		else
			fruitsAll = true
		end
	else
		veh.acFruitAllTimer = nil
	end	
	
	noReverseIndex  = AutoSteeringEngine.getNoReverseIndex( veh );
	
--==============================================================				
	local smooth	   = 0
	
	if  self.search ~= nil or veh.acTraceSmoothOffset == nil or not fruitsDetected then
		veh.acTraceSmoothOffset = AutoSteeringEngine.getTraceLength(veh) + 1
	elseif AIVEGlobals.smoothFactor > 0 and AIVEGlobals.smoothMax > 0 and AutoSteeringEngine.getTraceLength(veh) > 3 then --and fruitsDetected then
		smooth = Utils.clamp( AIVEGlobals.smoothFactor * ( AutoSteeringEngine.getTraceLength(veh) - veh.acTraceSmoothOffset ), 0, AIVEGlobals.smoothMax ) * Utils.clamp( speedLevelFactor, 0.7, 1.3 ) 
	end

	local offsetAngle = 0
	if     self.search == nil then
		local tl = AutoSteeringEngine.getTraceLength(veh)
		if     tl > 5 then
			offsetAngle = -turnAngle2
		elseif tl < 3 then
			offsetAngle = 0
		else
			offsetAngle = -0.5 * ( tl - 3 ) * turnAngle2
		end
	elseif self.search == AIDriveStrategyMogli.searchCircle then
		if veh.acParameters.leftAreaActive then
			offsetAngle = -turnAngle2 - 0.5 * math.pi
		else
			offsetAngle = -turnAngle2 + 0.5 * math.pi
		end
	--print(tostring(veh.acParameters.leftAreaActive).." L: "..AutoSteeringEngine.radToString(-turnAngle2 - 0.5 * math.pi).." R: "..AutoSteeringEngine.radToString(-turnAngle2 + 0.5 * math.pi))
	elseif self.search == AIDriveStrategyMogli.searchUTurn  then
		offsetAngle = math.pi - turnAngle2 
	end
	
	local isInField = false
	if self.search == nil then
		isInField = true
	elseif fruitsAll then
		isInField = true
	end
	
	if math.abs( veh.acAxisSide ) > 0.1 then
		detected   = false
		border     = 0
		angle2     = 0
		tX         = nil
		tZ         = nil
		dist       = math.huge
		speedLevel = 4
		
		veh.turnTimer = veh.turnTimer + dt;
		veh.waitForTurnTime = veh.waitForTurnTime + dt;
		if veh.acTurnStage <= 0 then
			veh.aiRescueTimer = veh.aiRescueTimer + dt;
		end			
	else
		local ta = nil
		
		if	    self.search    == nil
				and ( veh.turnTimer < 0 
					 or AutoSteeringEngine.processIsAtEnd( veh ) )
				then
			ta = math.min( math.max( math.rad( 0.5 * turnAngle ), -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle )
		
			if noReverseIndex <= 0 then
				ta = math.max( ta, 0 )
			end
			if not veh.acParameters.leftAreaActive then
				ta = -ta
			end
		end
		
		detected, angle2, border, tX, _, tZ, dist = AutoSteeringEngine.processChain( veh, isInField, ta )
	end
	
	local absAngle = angle2 
	if not veh.acParameters.leftAreaActive then
		absAngle = -angle2 
	end
	
	if dist == nil then
		dist = math.huge
	end
	
--==============================================================				
	turn2Outside       = false
	
	if	 border > 0 then
		turn2Outside    = true
		if AutoSteeringEngine.hasLeftFruits( veh ) then
			detected = false
		else
			detected = true
		end
	end
	
--==============================================================				
		
	local minDistanceToStop = 3 * veh.turnTimer / veh.acDeltaTimeoutRun
	if self.search == nil and AutoSteeringEngine.getIsAtEnd( veh ) then
		distanceToStop = minDistanceToStop
		self.lastDistancePos = nil
	else
		if self.search ~= nil then
			distanceToStop = math.huge 
			self.lastDistancePos = nil
		else
			if     self.lastDistancePos    == nil
					or self.lastDistancePos[4] ~= dist then
				self.lastDistancePos = { vX, vY, vZ, distanceToStop }
				distanceToStop = math.max( minDistanceToStop, dist )
			else
				distanceToStop = math.max( minDistanceToStop, self.lastDistancePos[4] - Utils.vector2Length( vX - self.lastDistancePos[1], vZ - self.lastDistancePos[3] ) )
			end
		end
	end		
	
	if not detected then
		speedLevel = 4
	end
	
	if veh.acDebugRetry and fruitsDetected then
		print("Starting debug 1xx...: "..tostring(self.search))
		veh.acDebugRetry = nil
		veh.turnTimer    = -1
		border           = 99
		turn2Outside     = true
		detected         = false
		AutoSteeringEngine.shiftTurnVector( veh, -1 )
	end
	
--if	    self.search    == nil
	if false
			and border         <= 0
			and ( veh.turnTimer < 0 
				 or AutoSteeringEngine.getIsAtEnd( veh ) 
				 or ( AutoSteeringEngine.getTraceLength(veh) > 5 and not detected ) )
			then
		
	--speedLevel = 4
	--detected   = detected and fruitsDetected
		
		local ta = math.min( math.max( math.rad( 0.5 * turnAngle ), -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle )
		
		if noReverseIndex <= 0 then
			ta = 0
		end
		
		if detected then
			angle = math.max( absAngle, ta )
		else
			angle = ta
		end
		
	--print("@end: "..AutoSteeringEngine.radToString( angle ).." = max( "..AutoSteeringEngine.radToString( absAngle )..", "..AutoSteeringEngine.radToString( ta ).." )" )
		
		angle2	= nil
	elseif  detected then
	-- everything is ok
--elseif  self.search == nil and border <= 0 and fruitsDetected then
--	angle = -veh.acDimensions.maxLookingAngle
	elseif  self.search == AIDriveStrategyMogli.searchCircle and border <= 0 then -- and fruitsDetected then
		angle = -veh.acDimensions.maxSteeringAngle
	elseif  self.search == AIDriveStrategyMogli.searchStart then
	-- start of hired worker
		if     turn2Outside then
			angle =  veh.acDimensions.maxSteeringAngle
		elseif fruitsDetected then
			angle = -veh.acDimensions.maxLookingAngle
		elseif AutoSteeringEngine.getIsAtEnd( veh ) then
			angle = 0
		else
			angle = -veh.acDimensions.maxLookingAngle
		end
	elseif  turn2Outside
			and self.search ~= nil
			and fruitsDetected then
	-- retry after failed turn
	
	--print(AutoSteeringEngine.radToString(angle2).."; "..tostring(self.search).."; "..tostring(border).."; "..tostring(vehicle.aiveChain.lastBest.border).."; "..tostring(veh.turnTimer))
	
		if	   veh.acTurnMode == "C" 
				or veh.acTurnMode == "8" 
				or veh.acTurnMode == "O" then
			if self.search == AIDriveStrategyMogli.searchUTurn then
				AutoSteeringEngine.shiftTurnVector( veh, 0.5 )
				self.turnData.stage = 105
				self.activeTurnStrategy = self.turnStrategies[1]		
				self.activeTurnStrategy:startTurn( self.turnData )			
				return self.activeTurnStrategy:getDriveData( dt, vX,vY,vZ, self.turnData )
			end
		else
			if self.search == AIDriveStrategyMogli.searchUTurn then
				AutoSteeringEngine.shiftTurnVector( veh, 0.5 )
				self.turnData.stage = 110
				self.activeTurnStrategy = self.turnStrategies[1]		
				self.activeTurnStrategy:startTurn( self.turnData )			
				return self.activeTurnStrategy:getDriveData( dt, vX,vY,vZ, self.turnData )
			else
				AutoSteeringEngine.shiftTurnVector( veh, 0.5 )
				self.turnData.stage = 115
				self.activeTurnStrategy = self.turnStrategies[1]		
				self.activeTurnStrategy:startTurn( self.turnData )			
				return self.activeTurnStrategy:getDriveData( dt, vX,vY,vZ, self.turnData )
			end
		end
		veh.turnTimer = veh.acDeltaTimeoutWait;
	
	else
	-- we are still ahead of the field
		veh.acTraceSmoothOffset = nil
		
		if     self.search == AIDriveStrategyMogli.searchUTurn then
		-- after U-turn
			local a, o, tX, tZ = AutoSteeringEngine.navigateToSavePoint( veh, 3, AIVehicleExtension.navigationFallbackRetry )
			if not o then
				if turn2Outside then
					angle =  veh.acDimensions.maxSteeringAngle
				else
					angle = -veh.acDimensions.maxLookingAngle 
				end
			end	
		elseif turn2Outside then
	
			if	 self.search ~= nil then 
				angle = veh.acDimensions.maxSteeringAngle
			elseif noReverseIndex > 0 then 
				angle = veh.acDimensions.maxLookingAngle 
			else 
				angle = 0
			end 
		elseif self.search == AIDriveStrategyMogli.searchCircle then
		-- after 90° turn
			a, o, tX, tZ = AutoSteeringEngine.navigateToSavePoint( veh, 4, AIVehicleExtension.navigationFallbackRotateMinus )
			if not o then
			--if veh.acParameters.leftAreaActive then
			--	angle = a
			--else
			--	angle = -a
			--end	
				angle = -veh.acDimensions.maxLookingAngle
			end
		elseif self.search == nil then
			angle = math.min( math.max( math.rad( 0.5 * turnAngle ), -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle )
		else
			angle = -veh.acDimensions.maxLookingAngle
		end
	end
	
	
--==============================================================				
--==============================================================				
-- threshing...					
	if	 self.search == nil then		
		
		local doTurn = false;
		local uTurn  = false;
		
		if turn2Outside then
			if fruitsDetected and veh.turnTimer < 0 and not AutoSteeringEngine.getIsAtEnd( veh ) then
				doTurn = true
				uTurn  = false
				veh.acClearTraceAfterTurn = true -- false
			end
		elseif fruitsDetected or not AutoSteeringEngine.getIsAtEnd( veh ) then		
			if detected then
				veh.turnTimer   		   = math.max(veh.turnTimer,veh.acDeltaTimeoutRun);
				veh.acTurnOutsideTimer = math.max( veh.acTurnOutsideTimer, veh.acDeltaTimeoutNoTurn );
			end
		elseif veh.turnTimer < 0 then 
			doTurn = true
			if AutoSteeringEngine.getTraceLength(veh) < 3 and veh.acParameters.upNDown then		
				uTurn = false
				veh.acClearTraceAfterTurn = false
			else
				uTurn = veh.acParameters.upNDown
				veh.acClearTraceAfterTurn = true
			end
		end
		
		if doTurn then		
			
			AutoSteeringEngine.initTurnVector( veh, uTurn, turn2Outside )

			if not turn2Outside then 
				local dist	= math.floor( 4 * math.max( 10, veh.acDimensions.distance ) )
				local wx,_,wz = AutoSteeringEngine.getAiWorldPosition( veh )
				local stop	= true
				local lx,lz
				for i=0,dist do
					for j=0,dist do
						for k=1,4 do
							if     k==1 then 
								lx = wx + i
								lz = wz + j
							elseif k==2 then
								lx = wx - i
								lz = wz + j
							elseif k==3 then
								lx = wx + i
								lz = wz - j
							else
								lx = wx - i
								lz = wz - j
							end
							if	    AutoSteeringEngine.isChainPointOnField( veh, lx-0.5, lz-0.5 ) 
									and AutoSteeringEngine.isChainPointOnField( veh, lx-0.5, lz+0.5 ) 
									and AutoSteeringEngine.isChainPointOnField( veh, lx+0.5, lz-0.5 ) 
									and AutoSteeringEngine.isChainPointOnField( veh, lx+0.5, lz+0.5 ) 
									then
								local x = lx - 0.5
								local z1= lz - 0.5
								local z2= lz + 0.5
								if AutoSteeringEngine.hasFruitsSimple( veh, x,z1,x,z2, 1 ) then
									stop = false
									break
								end
							end
						end
					end
				end
						
				if stop then
					veh:stopAIVehicle(AIVehicle.STOP_REASON_REGULAR)
					return
				end
			end
			
			self:updateTurnData()
			
			veh.acTurn2Outside = false
			veh.aiRescueTimer  = 3 * veh.acDeltaTimeoutStop;
			angle			   = 0
			
			self.search = AIDriveStrategyMogli.searchCircle
			
			if	 uTurn			   then
		-- the U turn
				--invert turn angle because we will swap left/right in about 10 lines
				self.search = AIDriveStrategyMogli.searchUTurn
				
				
				turnAngle = -turnAngle;
				if	 veh.acTurnMode == "O" then				
					self.turnData.stage = 70				
				elseif veh.acTurnMode == "8" then
					self.turnData.stage = 80				
				elseif veh.acTurnMode == "A" then
					self.turnData.stage = 50;
				elseif veh.acTurnMode == "Y" then
					self.turnData.stage = 40;
				else--if veh.acTurnMode == "T" then
					self.turnData.stage = 20;
					
				--if noReverseIndex > 0 and AutoSteeringEngine.noTurnAtEnd( veh ) then
				--	veh.acTurn2Outside = true
				--end
				end
				veh.turnTimer = veh.acDeltaTimeoutWait;
				veh.waitForTurnTime = g_currentMission.time + veh.turnTimer;
				if self.turnData.stage == 20 and veh.acTurn2Outside then
				else
					veh.acParameters.leftAreaActive  = not veh.acParameters.leftAreaActive;
					veh.acParameters.rightAreaActive = not veh.acParameters.rightAreaActive;
					AIVehicleExtension.sendParameters(veh);
				end					
				AutoSteeringEngine.setChainStraight( veh );	
				
			--if veh.acTurnMode == "O" then
			--	self.activeTurnStrategy = self.turnStrategies[self.ts_U_O]
			--end
			elseif turn2Outside then
				veh.acTurn2Outside = true
		-- turn to outside because we are in the middle of the field
				if	   veh.acTurnMode == "C" 
						or veh.acTurnMode == "8" 
						or veh.acTurnMode == "O" then
					self.turnData.stage = 100
				else	
					self.turnData.stage = 120
				end
				veh.turnTimer = veh.acDeltaTimeoutWait;
			elseif veh.acTurnMode == "C" 
					or veh.acTurnMode == "8" 
					or veh.acTurnMode == "O" then
		-- 90° turn w/o reverse
				self.turnData.stage = 5;
				veh.turnTimer = veh.acDeltaTimeoutWait;
				veh.waitForTurnTime = g_currentMission.time + veh.turnTimer;
				veh.acTurn2Outside = false
			elseif veh.acTurnMode == "L" 
					or veh.acTurnMode == "A" 
					or veh.acTurnMode == "Y" then
		-- 90° turn with reverse
			--self.turnData.stage = 1;
			--veh.turnTimer = veh.acDeltaTimeoutWait;
				self.activeTurnStrategy = self.turnStrategies[self.ts_C_R]
			elseif veh.acTurnMode == "7" then 
		-- 90° new turn with reverse
				self.turnData.stage = 90;
				veh.turnTimer = veh.acDeltaTimeoutWait;
			else
		-- 90° turn with reverse
				self.turnData.stage = 30;
				veh.turnTimer = veh.acDeltaTimeoutWait;
			end
			
			if self.activeTurnStrategy == nil then
				self.activeTurnStrategy = self.turnStrategies[1]
			end
			
			self.activeTurnStrategy:startTurn( self.turnData )
			
			return self.activeTurnStrategy:getDriveData( dt, vX,vY,vZ, self.turnData )
			
	--elseif detected or fruitsDetected then
		else
			AutoSteeringEngine.saveDirection( veh, true, not turn2Outside, true );
		end
		
--==============================================================				
-- searching...
	else
			
		if not detected then
			veh.turnTimer = math.max( veh.turnTimer, veh.acDeltaTimeoutRun )
		elseif AutoSteeringEngine.getIsAtEnd( veh ) then
			veh.turnTimer = math.max( veh.turnTimer, veh.acDeltaTimeoutRun )
	--elseif not fruitsAll then
		elseif not fruitsDetected then
			veh.turnTimer = math.max( veh.turnTimer, veh.acDeltaTimeoutRun )
		elseif AutoSteeringEngine.isBeforeStartNode( veh ) then
			veh.turnTimer = math.max( veh.turnTimer, veh.acDeltaTimeoutRun )
		elseif veh.turnTimer < 0 then
			if veh.acClearTraceAfterTurn then
				AutoSteeringEngine.clearTrace( veh );
				AutoSteeringEngine.saveDirection( veh, false, not turn2Outside );
			end
			AutoSteeringEngine.ensureToolIsLowered( veh, true )	
			self.search            = nil
			veh.acTurn2Outside	   = false;
			veh.turnTimer		       = veh.acDeltaTimeoutNoTurn;
			veh.acTurnOutsideTimer = math.max( veh.turnTimer, veh.acDeltaTimeoutNoTurn );
			veh.aiRescueTimer	     = veh.acDeltaTimeoutStop;
		end		
		
--==============================================================				
--==============================================================				
	end
	
	local smooth = nil
	if math.abs( veh.acAxisSide ) > 0.1 then
		absAngle = veh.acLastAbsAngle
		local a  = 0
		
		if     veh.acAxisSide <= -0.999 then
			a =  veh.acDimensions.maxSteeringAngle
  		smooth = 0.05
		elseif veh.acAxisSide >=  0.999 then
			a = -veh.acDimensions.maxSteeringAngle
  		smooth = 0.05
		else
			local midAngle = veh.acLastAbsAngle
			if not veh.acParameters.leftAreaActive then
				midAngle = -midAngle
			end
			
			local f = -veh.acAxisSide
			local a = midAngle 
			
			if f < 0 then
				a = midAngle + f * ( veh.acDimensions.maxSteeringAngle + midAngle )
			else
				a = midAngle + f * ( veh.acDimensions.maxSteeringAngle - midAngle )
			end
		end
		
		tX,tZ  = AutoSteeringEngine.getWorldTargetFromSteeringAngle( veh, a )

	elseif angle ~= nil then
		if not veh.acParameters.leftAreaActive then
			angle = -angle 
		end
		tX,tZ  = AutoSteeringEngine.getWorldTargetFromSteeringAngle( veh, angle )
		smooth = 0.05
	elseif tX == nil and angle2 ~= nil then
		tX,tZ  = AutoSteeringEngine.getWorldTargetFromSteeringAngle( veh, angle2 )
		smooth = 0.05
	elseif true then
		veh.aiSteeringSpeed = 1
	elseif border > 0 then
		veh.aiSteeringSpeed = 1
	elseif veh.acLastAbsAngle == nil then
		veh.aiSteeringSpeed = veh.acSteeringSpeed
	else
		if     absAngle > veh.acLastAbsAngle then
			veh.aiSteeringSpeed = 2.0 * veh.acSteeringSpeed
		elseif absAngle < veh.acLastAbsAngle then
			veh.aiSteeringSpeed = 0.5 * veh.acSteeringSpeed
		else
			veh.aiSteeringSpeed =       veh.acSteeringSpeed
		end
		if     absAngle > 0 then
			veh.aiSteeringSpeed = 2.0 * veh.aiSteeringSpeed
		elseif absAngle < 0 then
			veh.aiSteeringSpeed = 0.5 * veh.aiSteeringSpeed
		end
	end	
	
	veh.aiSteeringSpeed = math.min( veh.aiSteeringSpeed, ( veh.maxRotTime - veh.minRotTime ) / 200 )
	veh.acLastAbsAngle  = absAngle
	
	local tX2 = tX
	local tZ2 = tZ
	
	tX, tZ = self:adjustPosition( tX2, tZ2, moveForwards, distanceToStop )

	if smooth ~= nil and self.lastDirection ~= nil then
		tX = self.lastDirection[1] + smooth * ( tX - self.lastDirection[1] )
		tZ = self.lastDirection[2] + smooth * ( tZ - self.lastDirection[2] )
	end
	
	local useReduceSpeed = false
	local slowFactor     = 1
	
	maxSpeed = AutoSteeringEngine.getMaxSpeed( veh, dt, 1, true, true, speedLevel, useReduceSpeed, slowFactor )
			
	if self.search == nil then
		if distanceToStop < 5 or maxSpeed < 8 then
			veh:acDebugPrint("Slow...: "..tostring(speedLevel).."; "..tostring(useReduceSpeed).."; "..tostring(distanceToStop).."; "..tostring(dist).."; "..tostring(slowFactor).."; "..tostring(border).."; "..tostring(detected).."; "..tostring(maxSpeed))
		end
	end
	
	if math.abs( veh.acAxisSide ) > 0.1 then
		AIVehicleExtension.setStatus( veh, 2 )
	elseif self.search ~= nil and self.search == AIDriveStrategyMogli.searchStart then
		if detected then
			AIVehicleExtension.setStatus( veh, 2 ) 
		else
			AIVehicleExtension.setStatus( veh, 0 )
		end
	elseif detected then
		AIVehicleExtension.setStatus( veh, 1 )
	else
		AIVehicleExtension.setStatus( veh, 2 )
	end	
	
	self.lastDirection = { tX, tZ }
	
	self:printReturnInfo( tX, vY, tZ, true, maxSpeed, distanceToStop )
	
	if border <= 0 and AIVEGlobals.maxDtSumD > 0 then
		self.lastDriveData     = { tX, tZ, not veh.acParameters.inverted, maxSpeed, distanceToStop }
		self.lastDriveDataTime = g_currentMission.time + AIVEGlobals.maxDtSumD
		self.lastDriveDataDt   = 0
	end
	
	return tX, tZ, not veh.acParameters.inverted, maxSpeed, distanceToStop
end


