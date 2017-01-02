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
source(Utils.getFilename("AITurnStrategyMogli_C_R.lua", g_currentModDirectory));
source(Utils.getFilename("AITurnStrategyMogliDefault.lua", g_currentModDirectory));



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
		
	self.dtSum					 = 0
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
--local x,y,z
--if tX ~= nil and vY ~= nil and tZ ~= nil and self.vehicle.aiveChain ~= nil then
--	x,y,z = worldToLocal( self.vehicle.aiveChain.refNode, tX, vY, tZ )
--end
--
--local turnStage = "???"
--if self.activeTurnStrategy ~= nil then
--	turnStage = tostring(self.turnData.stage)
--elseif self.search == nil then
--	turnStage = " 0"
--else
--	turnStage = "-"..self.search
--end
--
--print(turnStage..": "..tostring(x).." "..tostring(z).." "..tostring(moveForwards).." "..tostring(maxSpeed).." "..tostring(distanceToStop))
end

function AIDriveStrategyMogli:updateTurnData()
	AIDriveStrategyStraight.updateTurnData( self )

	self.turnData.driveStrategy = self
end

function AIDriveStrategyMogli:getDriveData(dt, vX,vY,vZ)
	local veh = self.vehicle 
	
	if veh.acPause then
		AIVehicleExtension.setStatus( veh, 0 )
		return vX, vZ, moveForwards, 0, 0
	end
		
	self.dtSum = self.dtSum + dt
	
	if self.lastDriveData ~= nil then
	end
	
	local doit = false
	
	if	 self.lastDriveData == nil then
		doit = true
	elseif AIVEGlobals.maxDtSum <= 0 then
		doit = true
	elseif self.dtSum > AIVEGlobals.maxDtSum then 
		doit = true
	elseif Utils.vector2LengthSq( veh.acAiPos[1] - vX, veh.acAiPos[3] - vZ ) > AIVEGlobals.maxDtDist then
		doit = true
	end 
	
	veh.acAiPos = { vX,vY,vZ }
	dt = self.dtSum 
	self.dtSum = 0
	
	if self.activeTurnStrategy ~= nil then
		local tX, tZ, moveForwards, maxSpeed, distanceToStop = self.activeTurnStrategy:getDriveData(dt, vX,vY,vZ, self.turnData)
		if tX == nil then
			for _,turnStrategy in pairs(self.turnStrategies) do
				turnStrategy:onEndTurn(self.turnLeft)
			end
			self.activeTurnStrategy = nil
			veh.turnTimer		   = veh.acDeltaTimeoutNoTurn
			
			if self.search == nil then
				self.search = AIDriveStrategyMogli.searchCircle
			end			
		else
			self.lastDirection = { tX, tZ }
			self:printReturnInfo( tX, vY, tZ, moveForwards, maxSpeed, distanceToStop )
			return tX, tZ, moveForwards, maxSpeed, distanceToStop
		end		
	end
	
		
	local tX, tZ, maxSpeed, distanceToStop = nil, nil, 0, 0			

	AIVehicleExtension.statEvent( veh, "t0", dt )

	AIVehicleExtension.checkState( veh )
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
	
	local speedLevel = 2;
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
		
		return self.lastDirection[1], self.lastDirection[2], true, 0, 0
	end
	
	veh.isHirableBlocked = false
	
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

	local fruitsDetected, fruitsAll, distToStop = AutoSteeringEngine.hasFruits( veh, 0.9 )
	
	if self.search == nil then
		distanceToStop = distToStop
	end
	
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

	detected, angle2, border, tX, _, tZ = AutoSteeringEngine.processChain( veh, smooth, true, self.search == nil )
	
--==============================================================				
	if	  self.search    == nil
			and border			 <= 0
			and math.abs( angle2 ) <  AIVEGlobals.maxDtAngle * veh.acDimensions.maxLookingAngle then
		veh.acHighPrec = false
	elseif border			  <= 0 then
		veh.acHighPrec = false
	else
		veh.acHighPrec = true
	end
	
	local oldFullAngle = veh.acFullAngle
	veh.acFullAngle = false
	
	if	 border > 0 then
		detected		 = false
		veh.acFullAngle = true
	elseif oldFullAngle then
		if math.abs( angle2 ) > veh.acDimensions.maxLookingAngle then
			veh.acFullAngle = true
		end
	end
--==============================================================				
		
	if border > 0 then
		turn2Outside = true
		speedLevel = 4
		if AutoSteeringEngine.hasLeftFruits( veh ) then
			detected = false
		else
			detected = true
		end
	else
		turn2Outside		   = false
		veh.acTurnInTheMiddle = nil
	end		
	
			
	if	  self.search == nil
			and AutoSteeringEngine.getIsAtEnd( veh ) 
			and AutoSteeringEngine.getTraceLength(veh) > 5 then
		
		speedLevel = 4
		
		local ta = math.min( math.max( math.rad( 0.5 * turnAngle ), -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle )
		
		if noReverseIndex <= 0 then
			ta = 0
		end
		
		if veh.acParameters.leftAreaActive then
			angle = angle2 
		else
			angle = -angle2		
		end	
		angle   = math.max( angle, ta )
		
		angle2	= nil
	elseif  detected then
	-- everything is ok
	elseif  self.search == AIDriveStrategyMogli.searchStart then
	-- start of hired worker
		if turn2Outside then
			angle =  veh.acDimensions.maxSteeringAngle
		else
			angle = 0
		end
	elseif  turn2Outside
			and self.search ~= nil
			and fruitsDetected then
	-- retry after failed turn
		if	 veh.acTurnMode == "C" 
				or veh.acTurnMode == "8" 
				or veh.acTurnMode == "O" then
			if self.turnData.stage == -2 or self.turnData.stage == -12 or self.turnData.stage == -22 then
				AutoSteeringEngine.shiftTurnVector( veh, 0.5 )
				self.turnData.stage = 105
			end
		else
			if self.turnData.stage == -2 or self.turnData.stage == -12 or self.turnData.stage == -22 then
				AutoSteeringEngine.shiftTurnVector( veh, 0.5 )
				self.turnData.stage = 110
			else
				AutoSteeringEngine.shiftTurnVector( veh, 0.5 )
				self.turnData.stage = 115
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
				if veh.acParameters.leftAreaActive then
					angle = a
				else
					angle = -a
				end	
			end
		else
			angle = math.min( math.max( math.rad( 0.5 * turnAngle ), -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle )
		end
	end
	
	
--==============================================================				
--==============================================================				
-- threshing...					
	if	 self.search == nil then		
		
		local doTurn = false;
		local uTurn  = false;
		
		local turnTimer = veh.turnTimer
	--if fruitsDetected and turn2Outside then
	--	turnTime = veh.acTurnOutsideTimer 
	--end
		
		if	 detected and ( fruitsDetected or turn2Outside ) then
			doTurn = false
			veh.turnTimer   		  = math.max(veh.turnTimer,veh.acDeltaTimeoutRun);
			veh.acTurnOutsideTimer = math.max( veh.acTurnOutsideTimer, veh.acDeltaTimeoutNoTurn );
		elseif turn2Outside then
			if fruitsDetected and turnTimer < 0 then
				doTurn = true
				uTurn  = false
				veh.acClearTraceAfterTurn = true -- false
			end
		elseif fruitsDetected then		
			doTurn = false
		elseif turnTimer < 0 then 
			doTurn = true
			if	 detected then
				doTurn					 = false
				self.search = AIDriveStrategyMogli.searchCircle
				veh.aiRescueTimer		 = 3 * veh.acDeltaTimeoutStop;
				angle					  = 0			
				veh.acClearTraceAfterTurn = false
				veh.turnTimer			 = veh.acDeltaTimeoutWait;
				AutoSteeringEngine.initTurnVector( veh, false, true )
				
				if AIVEGlobals.raiseNoFruits > 0 and not veh.aiveHas.combine then
					AIVehicleExtension.setAIImplementsMoveDown(veh,false);
					AutoSteeringEngine.ensureToolIsLowered( veh, false )
					AIVehicleExtension.setAIImplementsMoveDown(veh,true);
				end
				
			elseif AutoSteeringEngine.getTraceLength(veh) < 10 then		
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
				local dist	= math.floor( 2.5 * math.max( 10, veh.acDimensions.distance ) )
				local wx,_,wz = AutoSteeringEngine.getAiWorldPosition( veh )
				local stop	= true
				local lx,lz
				for i=0,dist do
					for j=0,dist do
						for k=1,4 do
							if	 k==1 then 
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
							if	  AutoSteeringEngine.isChainPointOnField( veh, lx-0.5, lz-0.5 ) 
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
			elseif turn2Outside then
				veh.acTurn2Outside = true
		-- turn to outside because we are in the middle of the field
				if	 veh.acTurnMode == "C" 
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
				--if not veh.acParameters.upNDown
				--		or AutoSteeringEngine.getTraceLength(veh) < 10 then
					veh.acTurn2Outside = false
				--else
				--	veh.acTurn2Outside = true
				--	veh.acParameters.leftAreaActive  = not veh.acParameters.leftAreaActive;
				--	veh.acParameters.rightAreaActive = not veh.acParameters.rightAreaActive;
				--	AIVehicleExtension.sendParameters(veh);
				--end
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
			
		elseif detected or fruitsDetected then
			AutoSteeringEngine.saveDirection( veh, true, not turn2Outside );
		end
		
--==============================================================				
-- searching...
	else
	
		if      fruitsAll 
				and detected 
				and veh.acTurnInTheMiddle == nil
				and not ( veh.acFullAngle ) then
			if veh.acClearTraceAfterTurn then
				AutoSteeringEngine.clearTrace( veh );
				AutoSteeringEngine.saveDirection( veh, false, not turn2Outside );
				if not ( AIVEGlobals.raiseNoFruits > 0 ) then
					AutoSteeringEngine.ensureToolIsLowered( veh, true )	
				end
			end
			self.search = nil
			veh.acTurn2Outside	 = false;
			veh.turnTimer		  = veh.acDeltaTimeoutNoTurn;
			veh.acTurnOutsideTimer = math.max( veh.turnTimer, veh.acDeltaTimeoutNoTurn );
			veh.aiRescueTimer	  = veh.acDeltaTimeoutStop;
		end;
		
		
--==============================================================				
--==============================================================				
	end
	
	distanceToStop = math.huge
	
	if angle ~= nil then
		if not veh.acParameters.leftAreaActive then
			angle = -angle 
		end
		tX,tZ = AutoSteeringEngine.getWorldTargetFromSteeringAngle( veh, angle )
	elseif tX == nil and angle2 ~= nil then
		tX,tZ = AutoSteeringEngine.getWorldTargetFromSteeringAngle( veh, angle2 )
--else
--	l = Utils.vector2Length( tX - vX, tZ - vZ )
--	if l > 0.1 then
--		tX = vX + ( tX - vX ) / l
--		tZ = vZ + ( tZ - vZ ) / l
--	end
	end

	maxSpeed = AutoSteeringEngine.getMaxSpeed( veh, dt, 1, true, true, speedLevel, false, 0.7 )
			
--print("normal: "..tostring(tX).." "..tostring(tZ).." "..tostring(speedLevel).." "..tostring(maxSpeed))
	
	if detected then
		self.lastDriveData = { tX, tZ, true, maxSpeed, distanceToStop }
	else
		self.lastDriveData = nil
	end
	
	if self.search ~= nil and self.search == AIDriveStrategyMogli.searchStart then
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
	return tX, tZ, true, maxSpeed, distanceToStop
end


