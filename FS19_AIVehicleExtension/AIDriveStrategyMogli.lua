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

AIDriveStrategyMogli.searchOutside = 4
AIDriveStrategyMogli.searchStart   = 3 
AIDriveStrategyMogli.searchUTurn   = 2
AIDriveStrategyMogli.searchCircle  = 1

local AIDriveStrategyMogli_mt = Class(AIDriveStrategyMogli, AIDriveStrategy)

function AIDriveStrategyMogli:new(customMt)
	if customMt == nil then
		customMt = AIDriveStrategyMogli_mt
	end
	local self = AIDriveStrategy:new(customMt)
	return self
end

function AIDriveStrategyMogli:setAIVehicle(vehicle)
	self.mogliText = "AIDriveStrategyMogli"
	
	AIDriveStrategyMogli:superClass().setAIVehicle(self, vehicle)
--==============================================================			
--==============================================================					
	AutoSteeringEngine.saveDirection( vehicle )

	vehicle.acClearTraceAfterTurn = true
	AIVehicleExtension.resetAIMarker( vehicle )	
	AIVehicleExtension.initMogliHud(vehicle)
	
	self.vehicle.aiToolReverserDirectionNode = AIVehicleUtil.getAIToolReverserDirectionNode(self.vehicle);
	
	AutoSteeringEngine.invalidateField( vehicle )
	
	AutoSteeringEngine.checkTools1( vehicle, true )
	
	AutoSteeringEngine.setToolsAreTurnedOn( vehicle, true, false )
	
	vehicle.acDimensions	= nil;
	AIVehicleExtension.checkState( vehicle )
	
  self.turnDataIsStable = false;
  self.turnDataIsStableCounter = 0;

  self.lastLookAheadDistance = 5; -- 30;
	self:updateTurnData()
	self.turnData.stage = -3
	self.aiveTurnTimer		    = vehicle.acDeltaTimeoutWait;
	
	vehicle.aiRescueTimer     = vehicle.acDeltaTimeoutStop;
	vehicle.waitForTurnTime   = 0;
	vehicle.acLastAcc			    = 0;
	vehicle.acLastWantedSpeed = 0;
	
	AIVehicleExtension.setInt32Value( vehicle, "speed2Level", 2 )
	
--if AIVehicleUtil.invertsMarkerOnTurn( vehicle, vehicle.acParameters.leftAreaActive ) then
--	if vehicle.acParameters.leftAreaActive then
--		AIVehicle.aiRotateLeft(vehicle);
--	else
--		AIVehicle.aiRotateRight(vehicle);
--	end			
--end
	
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
	self.currentTurnStrategy = nil

	self.search     = AIDriveStrategyMogli.searchStart 
	AIVehicleExtension.setAIImplementsMoveDown(self.vehicle,true)
	self.isAtEndTimer = self.vehicle.acDeltaTimeoutWait
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
	AIVehicleExtension.resetAIMarker( veh )
	veh.acImplementsMoveDown = false
	AIVehicleExtension.setStatus( veh, 0 )
	veh.acTurnStage = 0
--==============================================================				
--==============================================================				
		
	AIDriveStrategyMogli:superClass().delete(self);

  for _, implement in ipairs(self.vehicle:getAttachedAIImplements()) do
    implement.object:aiImplementEndLine()
    local rootVehicle = implement.object:getRootVehicle()
    rootVehicle:raiseStateChange(Vehicle.STATE_CHANGE_AI_END_LINE)
  end
end

function AIDriveStrategyMogli:update(dt)
	for _,turnStrategy in pairs(self.turnStrategies) do
		turnStrategy:update(dt)
	end
	self.turnLeft = not ( self.vehicle.acParameters.rightAreaActive )
end

function AIDriveStrategyMogli:draw()
	if self.vehicle ~= nil and self.vehicle.aiveIsStarted then
		self.vehicle.aiveToolAngleInfo = AutoSteeringEngine.radToString(AutoSteeringEngine.getToolAngle(self.vehicle))
	end
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
	if self.currentTurnStrategy ~= nil then
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
	
--local refNode = vehicle.aiveChain.refNode
--
--if      not ( moveForwards ) 
--		and AutoSteeringEngine.hasArticulatedAxis( vehicle )
--    and vehicle.spec_articulatedAxis.aiRevereserNode ~= nil then
--	refNode = vehicle.aiVehicleDirectionNode
--elseif  vehicle.aiVehicleDirectionNode ~= nil then
--	refNode = vehicle.aiVehicleDirectionNode
--end

	local refNode = vehicle:getAIVehicleDirectionNode()
	
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
--	local l = AIVEUtils.vector3Length( lX,lY,lZ )
--	
--	
--	if 0.1 < math.abs( l ) and math.abs( 1.2 * l ) < d then
--		local f = d / l
--		lX = lX * f
--		lY = lY * f
--		lZ = lZ * f
--	end
--end
	
	if vehicle.acParameters.inverted then
		lX = -lX
	end
	
	local tX,_,tZ  = localToWorld( nOut, lX, lY, lZ )
	
--print(string.format("%5.2f %5.2f => %5.2f %5.2f => %5.2f %5.2f", eX, eZ, lX, lZ, tX, tZ ))
	
	return tX, tZ, mF2
end

function AIDriveStrategyMogli:gotoNextStage()
	if self.currentTurnStrategy ~= nil then
		self.currentTurnStrategy:gotoNextStage(self.turnData)
	else
		self.search = nil
	end
end

function AIDriveStrategyMogli:getDriveData(dt, vX2,vY2,vZ2)
	local veh = self.vehicle 
		
	if veh.acIsCPStopped then
		veh.acIsCPStopped = false
		veh.isHirableBlocked = true		
		AIVehicleExtension.setStatus( veh, 0 )
		return vX2, vZ2, moveForwards, 0, 0
	end
	
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
	
	if self.aiveTurnTimer == nil then 
		veh:acDebugPrint("turnTimer is nil: "..tostring(self.search).." / "..tostring(self.turnData.stage))
		self.aiveTurnTimer = 0
	end
		
	veh.spec_aiVehicle.aiSteeringSpeed = veh.acSteeringSpeed
	self.activeTurnStrategy = nil
	
	local resetState = false 
	if self.currentTurnStrategy ~= nil then
		local tX, tZ, moveForwards, maxSpeed, distanceToStop = self.currentTurnStrategy:getDriveData(dt, vX,vY,vZ, self.turnData)
		
	--if AIVEGlobals.devFeatures > 0 then
	--	self:addDebugText("truning: "..tostring(tX)
	--												..", "..tostring(tZ)
	--												..", "..tostring(moveForwards)
	--												..", "..tostring(maxSpeed)
	--												..", "..tostring(distanceToStop)
	--												..", "..tostring(self.turnData)) 
	--end
		
		if tX == nil then
			veh:aiTurnProgress( 1, veh.acParameters.leftAreaActive )
			for _,turnStrategy in pairs(self.turnStrategies) do
				turnStrategy:onEndTurn(self.turnLeft)
			end
			self.currentTurnStrategy = nil
			self.aiveTurnTimer		   = veh.acDeltaTimeoutRun
			veh.aiRescueTimer  = math.max( veh.aiRescueTimer, veh.acDeltaTimeoutStop )
			
			if self.search == nil then
				self.search = AIDriveStrategyMogli.searchCircle
			end			
			veh.acLastAbsAngle = nil
			resetState         = true
			veh:aiEndTurn( veh.acParameters.leftAreaActive )
		else
			local tX2, tZ2, mF2 = self:adjustPosition( tX, tZ, moveForwards, distanceToStop )
			self.lastDirection = { tX2, tZ2 }
			self:printReturnInfo( tX2, vY, tZ2, mF2, maxSpeed, distanceToStop )
			
			if maxSpeed == 0 then
				veh.acLastWantedSpeed = nil
			end
			
			if veh.acTurnStage > 0 then
				self.activeTurnStrategy = self.currentTurnStrategy
				AIVehicleExtension.stopCoursePlayMode2( veh, false )
			end
			
			AIVehicleExtension.statEvent( veh, "tT", dt )
			return tX2, tZ2, mF2, maxSpeed, distanceToStop
		end		
	end

--if AIVEGlobals.devFeatures > 0 then
--	self:addDebugText("driving: "..tostring(self.search))
--end

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
	
	local allowedToDrive =  AutoSteeringEngine.checkAllowedToDrive( veh, false, self.search == AIDriveStrategyMogli.searchStart ) --not ( veh.acParameters.isHired  ) )
		
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
	
	local fruitsDetected, fruitsAll = AutoSteeringEngine.hasFruits( veh )
	
	if fruitsDetected and self.search ~= nil and self.searchStartPos == nil then 
		self.searchStartPos = { vX,vY,vZ }
	end 
	
	local slowFactorLowering = 1

	if      allowedToDrive
			and ( fruitsDetected or ( self.search == nil and AIVEGlobals.raiseNoFruits <= 0 ) )
			and not ( AutoSteeringEngine.getIsAIReadyForWork( veh ) and veh:getCanAIVehicleContinueWork() ) then
		local fruitsDistSq = 0
		local maxDistSq    = ( AIVEGlobals.ignoreDist + AIVEGlobals.fruitsAdvance )^2
		if self.searchStartPos ~= nil then 
			fruitsDistSq = AIVEUtils.vector2LengthSq( self.searchStartPos[1]-vX, self.searchStartPos[3]-vZ ) 
			if self.search == nil and fruitsDistSq >= maxDistSq then 
				fruitsDistSq = 0
				self.searchStartPos = nil 
			end 
		end 
		
	--if self.searchStartPos ~= nil then 
	--	print(string.format("Start position: (%6.2f, %6.2f), distance: %6.2f",
	--											self.searchStartPos[1],
	--											self.searchStartPos[3],
	--											math.sqrt( fruitsDistSq ) ) )
  --end 
	
		-- ignore fruits at the very beginning
		if self.searchStartPos == nil or fruitsDistSq >= maxDistSq then 
			allowedToDrive     = false
		elseif fruitsDistSq > 0 and maxDistSq > 0 then 
			slowFactorLowering = AIVEUtils.clamp( 1 - math.sqrt( fruitsDistSq / maxDistSq ), 0, 1 )
		end
	elseif self.searchStartPos ~= nil then 
		self.searchStartPos = nil 
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
		
		if self.lastDirection == nil then
			self.lastDirection = { AutoSteeringEngine.getWorldTargetFromSteeringAngle( veh, 0 ) }
		end
		
		return self.lastDirection[1], self.lastDirection[2], not veh.acParameters.inverted, AutoSteeringEngine.getMaxSpeed( veh, dt, 1, false, true, 0, false, 0.7 ), 0
	end
	
	if not veh:getAILastAllowedToDrive() then
		AIVehicleExtension.setAIImplementsMoveDown(veh,true,true)
	end
	
	local offsetOutside = 0;
	if	 veh.acParameters.rightAreaActive then
		offsetOutside = -1;
	elseif veh.acParameters.leftAreaActive then
		offsetOutside = 1;
	end;
	
	self.aiveTurnTimer		  = self.aiveTurnTimer - dt;
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
	local angleMax = veh.acDimensions.maxSteeringAngle;
	local detected = false;
	local border   = 0;
	local angleFactor;
	local offsetOutside;
	local noReverseIndex = 0;
	local angleOffset = 6;
	local angleOffsetStrict = 4;
	local stoppingDist = 0.5;
	local turn2Outside = false
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
	if self.search == AIDriveStrategyMogli.searchOutside and AutoSteeringEngine.getIsAtEnd( veh ) then
		AutoSteeringEngine.ensureToolIsLowered( veh, true )	
		self.search            = nil
		self.aiveTurnTimer		       = veh.acDeltaTimeoutNoTurn;
		veh.acTurnOutsideTimer = math.max( self.aiveTurnTimer, veh.acDeltaTimeoutNoTurn );
		veh.aiRescueTimer	     = veh.acDeltaTimeoutStop;		
	end
	
	local isInField = false
	if self.search == nil or veh.acParameters.straight then
		isInField = true
	end
	
	local straightAbsAngle = math.min( math.max( math.rad( 0.5 * turnAngle ), -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle )
	
	if math.abs( veh.acAxisSide ) > 0.1 then
		detected   = false
		border     = 0
		angle2     = 0
		tX         = nil
		tZ         = nil
		dist       = math.huge
		speedLevel = 1
		
		self.aiveTurnTimer = self.aiveTurnTimer + dt;
		veh.waitForTurnTime = veh.waitForTurnTime + dt;
		if veh.acTurnStage <= 0 then
			veh.aiRescueTimer = veh.aiRescueTimer + dt;
		end			
	else
		local ta, af, na
		
		if	    self.search    == nil
				and ( self.aiveTurnTimer < 0 
					 or AutoSteeringEngine.processIsAtEnd( veh ) )
				then
			ta = straightAbsAngle
		
			if noReverseIndex <= 0 and veh.acDimensions.zBack < 0 then
				ta = math.max( ta, 0 )
			end
			if not veh.acParameters.leftAreaActive then
				ta = -ta
			end
		end
		
		if     self.search == nil then
			af = veh.acParameters.angleFactor 
			na = "L"
		elseif self.search == AIDriveStrategyMogli.searchStart  then
			na = "M"
		elseif self.search == AIDriveStrategyMogli.searchUTurn  then
			na = "M"
		else
			na = "I"
		end
		
	--if      not AutoSteeringEngine.hasArticulatedAxis( vehicle ) and AIVEGlobals.staticRoot > 0
	--		and self.search == nil
	--		and ta == nil
	--		and self.lastChainResult ~= nil
	--		and g_currentMission.time - self.lastChainResult[1] < 500
	--		and self.lastChainResult[2]
	--		and self.lastChainResult[4] <= 0 then 
	--	detected = self.lastChainResult[2]
	--	angle2   = self.lastChainResult[3]
	--	border   = self.lastChainResult[4]
	--	tX       = self.lastChainResult[5]
	--	tZ       = self.lastChainResult[6]
	--	dist     = self.lastChainResult[7]
	--else 
			detected, angle2, border, tX, _, tZ, dist = AutoSteeringEngine.processChain( veh, isInField, ta, af, na )
	--	--                       1                      2         3       4       5   6   7
	--	self.lastChainResult = { g_currentMission.time, detected, angle2, border, tX, tZ, dist }
	--end 
	end
	
	local absAngle = angle2 
	if not veh.acParameters.leftAreaActive then
		absAngle = -angle2 
	end
	
	if dist == nil then
		dist = math.huge
	end
	
--==============================================================		
	local isAtEnd = false
	if self.search == nil then
		if self.isAtEndTimer < 0 then
			isAtEnd = true
		elseif AutoSteeringEngine.getIsAtEnd( veh ) then
			self.isAtEndTimer = self.isAtEndTimer - dt
			isAtEnd = true
		else 
			self.isAtEndTimer = veh.acDeltaTimeoutWait
		end
	else
		self.isAtEndTimer = veh.acDeltaTimeoutWait
	end
	
	local stopCP = false
		
	if self.search == nil and isAtEnd then
		veh.acMinDistanceToStop = math.max( 0.5, veh.acMinDistanceToStop - dt * veh.lastSpeed )
		distanceToStop = veh.acMinDistanceToStop
		
		if veh.acTurnMode == "7" and veh.acChopperWithCourseplay then
			AIVehicleExtension.stopCoursePlayMode2( veh, true )
		end
		
		if      not fruitsDetected	
				and not ( veh.acParameters.upNDown and veh.acParameters.headland and veh.acParameters.bigHeadland ) then 
		-- raise as early as possible but not with bigHeadland
			detected = false 
		end 
	else
		veh.acMinDistanceToStop = math.max( 1, veh.acDimensions.toolDistance - veh.acDimensions.zBack ) + AIVEGlobals.fruitsInFront
		if self.search ~= nil then
			distanceToStop = math.huge 
		else
			distanceToStop = math.max( veh.acMinDistanceToStop, dist )
		end
	end		
	
	if not ( detected or isAtEnd ) then
		speedLevel = 4
	end
	
	if veh.acDebugRetry and fruitsDetected then
		print("Starting debug 1xx...: "..tostring(self.search))
		veh.acDebugRetry = nil
		self.aiveTurnTimer    = -1
		border           = 99
		detected         = false
		AutoSteeringEngine.shiftTurnVector( veh, -1 )
	end
	
--==============================================================				
	turn2Outside = false
	
	if	    self.search    == nil
			and border         <= 0
			and ( self.aiveTurnTimer < 0 
				 or isAtEnd 
				 or ( AutoSteeringEngine.getTraceLength(veh) > AIVEGlobals.minTraceLen and not detected ) )
			then
		
		local ta = straightAbsAngle
		
	--if noReverseIndex <= 0 and veh.acDimensions.zBack < 0 then
	--	ta = 0 
	--end
	--print( AutoSteeringEngine.degToString( turnAngle )..", "..AutoSteeringEngine.radToString( ta )..", "..AutoSteeringEngine.radToString( absAngle ))
		
		if detected then
			if absAngle < ta - 0.01 then 
				angle = ta 
			end 
		else
			if math.abs( ta - absAngle ) > 0.01 then 
				angle = ta
			end 
		end
	elseif  detected then
	-- everything is ok
	elseif  border > 0 then
	-- border !!!
		turn2Outside = AutoSteeringEngine.hasLeftFruits( veh )	
		detected     = false
		speedLevel   = 4
		
		if     self.search == nil then
			local f = 1
			if veh.acDimensions.zBack < 0 then
			-- keep calm and don't move!!! Going to outside would just make it worse
				if AutoSteeringEngine.hasArticulatedAxis( vehicle ) then
					f = 0
				elseif noReverseIndex <= 0 then
					f = 0.1
				else
					f = 0.25
				end
			end
			angle  = math.min( math.min( 0, straightAbsAngle ) + f * veh.acDimensions.maxSteeringAngle, absAngle )
		elseif self.search == AIDriveStrategyMogli.searchStart then
			angle = veh.acDimensions.maxSteeringAngle
		elseif turn2Outside and fruitsDetected then
			if	   veh.acTurnMode == "C" 
					or veh.acTurnMode == "8" 
					or veh.acTurnMode == "O" then
				if self.search == AIDriveStrategyMogli.searchUTurn then
					AutoSteeringEngine.shiftTurnVector( veh, 0.5 )
					self.turnData.stage = 105
					self.currentTurnStrategy = self.turnStrategies[1]		
					self.currentTurnStrategy:startTurn( self.turnData )			
					return self.currentTurnStrategy:getDriveData( dt, vX,vY,vZ, self.turnData )
				end
			else
				if self.search == AIDriveStrategyMogli.searchUTurn then
					AutoSteeringEngine.shiftTurnVector( veh, 0.5 )
					self.turnData.stage = 110
					self.currentTurnStrategy = self.turnStrategies[1]		
					self.currentTurnStrategy:startTurn( self.turnData )			
					return self.currentTurnStrategy:getDriveData( dt, vX,vY,vZ, self.turnData )
				else
					AutoSteeringEngine.shiftTurnVector( veh, 0.5 )
					self.turnData.stage = 115
					self.currentTurnStrategy = self.turnStrategies[1]		
					self.currentTurnStrategy:startTurn( self.turnData )			
					return self.currentTurnStrategy:getDriveData( dt, vX,vY,vZ, self.turnData )
				end
			end
			self.aiveTurnTimer = veh.acDeltaTimeoutWait
		else
			angle = veh.acDimensions.maxSteeringAngle
		end
	elseif  self.search == AIDriveStrategyMogli.searchStart then
	-- start of hired worker
		angle = 0
	elseif     self.search == AIDriveStrategyMogli.searchUTurn then
	-- after U-turn
		local a, o, tX, tZ = AutoSteeringEngine.navigateToSavePoint( veh, 3, AIVehicleExtension.navigationFallbackRetry )
		if not o then
			angle = -veh.acDimensions.maxSteeringAngle 
		end
	elseif self.search == AIDriveStrategyMogli.searchOutside then
	-- after turn 2 outside 
		local a, o, tX, tZ = AutoSteeringEngine.navigateToSavePoint( veh, 3, AIVehicleExtension.navigationFallbackRetry )
		if not o then
			angle = veh.acDimensions.maxSteeringAngle
		end
	elseif self.search == AIDriveStrategyMogli.searchCircle then
	-- after 90° turn
		a, o, tX, tZ = AutoSteeringEngine.navigateToSavePoint( veh, 4, AIVehicleExtension.navigationFallbackRotateMinus )
		if not o then
			angle = -veh.acDimensions.maxSteeringAngle
		end
	else
		angle = -veh.acDimensions.maxSteeringAngle
	end
	
	
--==============================================================				
--==============================================================				
-- threshing...					
	if	 self.search == nil then		
		
		local doTurn = false;
		local uTurn  = false;
		
		if turn2Outside and not isAtEnd then
			if fruitsDetected and self.aiveTurnTimer < 0 then
				doTurn = true
				
				if AutoSteeringEngine.getTraceLength(veh) < AIVEGlobals.minTraceLen and veh.acParameters.upNDown then		
					uTurn = false
					veh.acClearTraceAfterTurn = false
				elseif veh.acParameters.upNDown then
					uTurn = true
					veh.acClearTraceAfterTurn = false
				else
					uTurn = false
					veh.acClearTraceAfterTurn = true
				end
			end
		elseif fruitsDetected or detected or not isAtEnd then		
			self.aiveTurnTimer   		   = math.max(self.aiveTurnTimer,veh.acDeltaTimeoutRun);
			veh.acTurnOutsideTimer = math.max( veh.acTurnOutsideTimer, veh.acDeltaTimeoutNoTurn );
		elseif self.aiveTurnTimer < 0 then 
			doTurn = true
			turn2Outside = false
			if veh.acParameters.straight then 
				uTurn = true 
				veh.acClearTraceAfterTurn = true
			elseif AutoSteeringEngine.getTraceLength(veh) < AIVEGlobals.minTraceLen and veh.acParameters.upNDown then		
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
				if veh.aiveChain ~= nil and veh.aiveChain.trace ~= nil and veh.aiveChain.trace.isUTurn ~= nil then 
					veh.aiDriveTarget = { veh.aiveChain.trace.ux, veh.aiveChain.trace.uz }
				end 
				
				veh.aiDriveDirection[1] = - veh.aiDriveDirection[1]
				veh.aiDriveDirection[2] = - veh.aiDriveDirection[2]
				
			--local dist	= math.floor( 4 * math.max( 10, veh.acDimensions.distance ) )
			--local wx,_,wz = AutoSteeringEngine.getAiWorldPosition( veh )
			--local stop	= true
			--local lx,lz
			--for i=0,dist do
			--	for j=0,dist do
			--		for k=1,4 do
			--			if     k==1 then 
			--				lx = wx + i
			--				lz = wz + j
			--			elseif k==2 then
			--				lx = wx - i
			--				lz = wz + j
			--			elseif k==3 then
			--				lx = wx + i
			--				lz = wz - j
			--			else
			--				lx = wx - i
			--				lz = wz - j
			--			end
			--			if	    AutoSteeringEngine.isChainPointOnField( veh, lx-0.5, lz-0.5 ) 
			--					and AutoSteeringEngine.isChainPointOnField( veh, lx-0.5, lz+0.5 ) 
			--					and AutoSteeringEngine.isChainPointOnField( veh, lx+0.5, lz-0.5 ) 
			--					and AutoSteeringEngine.isChainPointOnField( veh, lx+0.5, lz+0.5 ) 
			--					then
			--				local x = lx - 0.5
			--				local z1= lz - 0.5
			--				local z2= lz + 0.5
			--				if AutoSteeringEngine.hasFruitsSimple( veh, x,z1,x,z2, 1 ) then
			--					stop = false
			--					break
			--				end
			--			end
			--		end
			--	end
			--end
			--		
			--if stop then
				if not ( AutoSteeringEngine.hasFoundNext( veh ) ) then
					veh:stopAIVehicle(AIVehicle.STOP_REASON_REGULAR)
					return
				end
			end
			
			self:updateTurnData()
			
			veh.aiRescueTimer  = 3 * veh.acDeltaTimeoutStop;
			angle			   = 0
			
			self.search = AIDriveStrategyMogli.searchCircle
			
			if     turn2Outside then
				self.search = AIDriveStrategyMogli.searchOutside
		-- turn to outside because we are in the middle of the field
				if	   veh.acTurnMode == "C" 
						or veh.acTurnMode == "8" 
						or veh.acTurnMode == "O" then
					self.turnData.stage = 100
				else	
					self.turnData.stage = 120
				end
				self.aiveTurnTimer = veh.acDeltaTimeoutWait;
			elseif uTurn			   then
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
				end
				self.aiveTurnTimer = veh.acDeltaTimeoutWait;
				veh.waitForTurnTime = g_currentMission.time + self.aiveTurnTimer;
				veh.acParameters.leftAreaActive  = not veh.acParameters.leftAreaActive;
				veh.acParameters.rightAreaActive = not veh.acParameters.rightAreaActive;
				AIVehicleExtension.sendParameters(veh);
				AutoSteeringEngine.setChainStraight( veh );	
				
			--if veh.acTurnMode == "O" then
			--	self.currentTurnStrategy = self.turnStrategies[self.ts_U_O]
			--end
			elseif veh.acTurnMode == "C" 
					or veh.acTurnMode == "8" 
					or veh.acTurnMode == "O" then
		-- 90° turn w/o reverse
				self.turnData.stage = 10
				self.aiveTurnTimer = veh.acDeltaTimeoutWait;
				veh.waitForTurnTime = g_currentMission.time + self.aiveTurnTimer;
			elseif veh.acTurnMode == "L" 
					or veh.acTurnMode == "A" 
					or veh.acTurnMode == "Y" then
		-- 90° turn with reverse
			--self.turnData.stage = 1;
			--self.aiveTurnTimer = veh.acDeltaTimeoutWait;
				self.currentTurnStrategy = self.turnStrategies[self.ts_C_R]
			elseif veh.acTurnMode == "7" then 
		-- 90° new turn with reverse
				self.turnData.stage = 90;
				self.aiveTurnTimer = veh.acDeltaTimeoutWait;
			else
		-- 90° turn with reverse
				self.turnData.stage = 30;
				self.aiveTurnTimer = veh.acDeltaTimeoutWait;
			end
			
			if self.currentTurnStrategy == nil then
				self.currentTurnStrategy = self.turnStrategies[1]
			end
			
			veh:aiStartTurn( veh.acParameters.leftAreaActive )
			veh:aiTurnProgress( 0, veh.acParameters.leftAreaActive )
	
			self.currentTurnStrategy:startTurn( self.turnData )
			
			return self.currentTurnStrategy:getDriveData( dt, vX,vY,vZ, self.turnData )
			
	--elseif detected or fruitsDetected then
		else
			AutoSteeringEngine.saveDirection( veh, true, border > 0, true );
		end
		
--==============================================================				
-- searching...
	else
			
		if not detected then
			self.aiveTurnTimer = math.max( self.aiveTurnTimer, veh.acDeltaTimeoutRun )
		elseif isAtEnd then
			self.aiveTurnTimer = math.max( self.aiveTurnTimer, veh.acDeltaTimeoutRun )
	--elseif not fruitsAll then
		elseif not fruitsDetected then
			self.aiveTurnTimer = math.max( self.aiveTurnTimer, veh.acDeltaTimeoutRun )
		elseif AutoSteeringEngine.isBeforeStartNode( veh ) then
			self.aiveTurnTimer = math.max( self.aiveTurnTimer, veh.acDeltaTimeoutRun )
		elseif self.aiveTurnTimer < 0 then
			if veh.acClearTraceAfterTurn then
				AutoSteeringEngine.clearTrace( veh );
				AutoSteeringEngine.saveDirection( veh, false );
			end
			AutoSteeringEngine.ensureToolIsLowered( veh, true )	
			self.search            = nil
			self.aiveTurnTimer		 = veh.acDeltaTimeoutNoTurn;
			veh.acTurnOutsideTimer = math.max( self.aiveTurnTimer, veh.acDeltaTimeoutNoTurn );
			veh.aiRescueTimer	     = veh.acDeltaTimeoutStop;
		end		
		
--==============================================================				
--==============================================================				
	end
	
	local smooth = nil
	
	if veh.acAxisSideFactor == nil or veh.acLastAbsAngle == nil then
		veh.acAxisSideFactor = 1000
	elseif math.abs( veh.acAxisSide ) >= 0.1 then
		veh.acAxisSideFactor = math.max( veh.acAxisSideFactor - dt, 0 )
	elseif veh.acAxisSideFactor < 1000  then
		veh.acAxisSideFactor = math.min( veh.acAxisSideFactor + dt, 1000 )
	end
	
	local f = 0.001 * veh.acAxisSideFactor
	
	if f <= 0.999 then
		absAngle = veh.acLastAbsAngle
		local a  = 0
		
		if     veh.acAxisSide <= -0.999 then
			a =  veh.acDimensions.maxSteeringAngle
  		smooth = 0.03
		elseif veh.acAxisSide >=  0.999 then
			a = -veh.acDimensions.maxSteeringAngle
  		smooth = 0.03
		else
			local midAngle = veh.acLastAbsAngle
			if not veh.acParameters.leftAreaActive then
				midAngle = -midAngle
			end
			
			local g = (f-1)*veh.acAxisSide
			local a = f*midAngle 
			
			if f < 0 then
				a = midAngle + g * ( veh.acDimensions.maxSteeringAngle + midAngle )
			else
				a = midAngle + g * ( veh.acDimensions.maxSteeringAngle - midAngle )
			end
			smooth = 0.05
		end
		
		tX,tZ  = AutoSteeringEngine.getWorldTargetFromSteeringAngle( veh, a )

	elseif angle ~= nil then
		if not veh.acParameters.leftAreaActive then
			angle = -angle 
		end
		tX,tZ  = AutoSteeringEngine.getWorldTargetFromSteeringAngle( veh, angle )
	elseif tX == nil and angle2 ~= nil then
		tX,tZ  = AutoSteeringEngine.getWorldTargetFromSteeringAngle( veh, angle2 )
	elseif border > 0 then
		veh.spec_aiVehicle.aiSteeringSpeed = 1
	elseif not detected then 
		veh.spec_aiVehicle.aiSteeringSpeed = 2 * veh.acSteeringSpeed
	elseif veh.acLastAbsAngle == nil then
		veh.spec_aiVehicle.aiSteeringSpeed = veh.acSteeringSpeed
	else
		if     absAngle > veh.acLastAbsAngle then
			veh.spec_aiVehicle.aiSteeringSpeed = 2.0 * veh.acSteeringSpeed
		elseif absAngle < veh.acLastAbsAngle then
			veh.spec_aiVehicle.aiSteeringSpeed = 0.5 * veh.acSteeringSpeed
		else
			veh.spec_aiVehicle.aiSteeringSpeed =       veh.acSteeringSpeed
		end
		if     absAngle > 0 then
			veh.spec_aiVehicle.aiSteeringSpeed = 2.0 * veh.spec_aiVehicle.aiSteeringSpeed
		elseif absAngle < 0 then
			veh.spec_aiVehicle.aiSteeringSpeed = 0.5 * veh.spec_aiVehicle.aiSteeringSpeed
		end
	end	
	
	veh.spec_aiVehicle.aiSteeringSpeed = veh.spec_aiVehicle.aiSteeringSpeed * math.max( 1, veh.lastSpeed * 360 ) 
	veh.spec_aiVehicle.aiSteeringSpeed = math.min( veh.spec_aiVehicle.aiSteeringSpeed, ( veh.maxRotTime - veh.minRotTime ) / 100 )
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
	
	if      self.search == nil 
			and angle2 ~= nil 
			and math.abs( angle2+angle2 ) > veh.acDimensions.maxSteeringAngle then
		slowFactor = math.min( 1, AutoSteeringEngine.getWantedSpeed( veh, 4 ) / AutoSteeringEngine.getWantedSpeed( veh, 2 ) )
		if slowFactor < 1 and math.abs( angle2 ) < veh.acDimensions.maxSteeringAngle then
			slowFactor = slowFactor + ( 1 - slowFactor ) * 2 * ( 1 - math.abs( angle2 ) / veh.acDimensions.maxSteeringAngle ) 
		end
		speedLevel     = 2
		useReduceSpeed = true
	end
	
	if slowFactorLowering < 1 then 
		slowFactor     = math.min( slowFactor, slowFactorLowering )
		useReduceSpeed = true
		speedLevel     = 4
	end

	
	maxSpeed = AutoSteeringEngine.getMaxSpeed( veh, dt, 1, true, true, speedLevel, useReduceSpeed, slowFactor )
			
--if self.search == nil and ( distanceToStop < 5 or maxSpeed < 8 ) then
--	veh:acDebugPrint("Slow...: "..tostring(speedLevel).."; "..tostring(useReduceSpeed).."; "..tostring(distanceToStop).."; "..tostring(dist).."; "..tostring(slowFactor).."; "..tostring(border).."; "..tostring(detected).."; "..tostring(maxSpeed))
--end
	
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
	
	return tX, tZ, not veh.acParameters.inverted, maxSpeed, distanceToStop
end


