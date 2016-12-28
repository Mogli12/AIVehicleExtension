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


AIDriveStrategyMogli = {}
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
	
	self.turnLeft = not ( vehicle.acParameters.rightAreaActive )
	self.turnStrategies = { AITurnStrategyMogli:new() }
	
	for _,turnStrategy in pairs(self.turnStrategies) do
		turnStrategy:setAIVehicle(self.vehicle);
	end
	self.activeTurnStrategy = nil
end

function AIDriveStrategyMogli:update(dt)
	for _,turnStrategy in pairs(self.turnStrategies) do
		turnStrategy:update(dt)
	end
end

function AIDriveStrategyMogli:draw()
end

function AIDriveStrategyMogli:addDebugText( s )
	if self.vehicle ~= nil and type( self.vehicle.aiveAddDebugText ) == "function" then
		self.vehicle:aiveAddDebugText( s ) 
	end
end

function AIDriveStrategyMogli:getDriveData(dt, vX,vY,vZ)
	if not ( self.vehicle.aiveState.enabled ) then
		return nil, nil, nil, nil, nil
  end

	self.position = { vX,vY,vZ }
	
	if veh.acTurnStage <= 0 then
		self.activeTurnStrategy = self.turnStrategies[1]
		local tX, tZ, moveForwards, maxSpeed, distanceToStop = self.activeTurnStrategy:getDriveData(dt, vX,vY,vZ, self.turnData)
		if veh.acTurnStage > 0 then
			self:addDebugText( "===> distanceToStop = "..distanceToStop )
			return tX, tZ, moveForwards, maxSpeed, distanceToStop
		else
			for _,turnStrategy in pairs(self.turnStrategies) do
				turnStrategy:onEndTurn(self.activeTurnStrategy.turnLeft)
			end
			self.activeTurnStrategy = nil
		end
	end
	
		
	local tX, tZ, maxSpeed, distanceToStop = nil, nil, 0, 0		
		
	local veh = self.vehicle 
	
	
	local dt = veh.acDtSum

	AIVehicleExtension.statEvent( veh, "t0", dt )

	AIVehicleExtension.checkState( veh )
	if not AutoSteeringEngine.hasTools( veh ) then
		veh:stopAIVehicle()
		return;
	end
	
	if not AIVehicleExtension.checkIsCorrectField( veh ) then
		veh:stopAIVehicle()
		return;
	end
	
	local allowedToDrive =  AutoSteeringEngine.checkAllowedToDrive( veh, not ( veh.acParameters.isHired  ) )
	
	if veh.acPause then
		allowedToDrive = false
		AIVehicleExtension.setStatus( veh, 0 )
	end
	
	self.noSneak       = false
	self.isAnimPlaying = false
	if AIVehicleExtension.waitForAnimTurnStage( veh ) then
		local isPlaying, noSneak = AutoSteeringEngine.checkIsAnimPlaying( veh, veh.acImplementsMoveDown )
		
		if isPlaying then
			if    self.animWaitTimer == nil then
				self.animWaitTimer = veh.acDeltaTimeoutWait
				self.isAnimPlaying = true
			elseif self.animWaitTimer > 0 then
				self.animWaitTimer = self.animWaitTimer - dt
				self.isAnimPlaying = true
			end
		else
			self.animWaitTimer = nil
			noSneak            = false
		end
		
		if noSneak then
			if    self.noSneakTimer == nil then
				self.noSneakTimer = veh.acDeltaTimeoutWait
				self.noSneak = true
			elseif self.noSneakTimer > 0 then
				self.noSneakTimer = self.noSneakTimer - dt
				self.noSneak = true
			end
		else
			self.noSneakTimer = nil
		end
		
		if      allowedToDrive 
				and self.noSneak then
			AIVehicleExtension.setStatus( veh, 3 )
			allowedToDrive = false
		end
	else
		self.animWaitTimer = nil
		self.noSneakTimer  = nil
	end
	
	local speedLevel = 2;
	if veh.speed2Level ~= nil and 0 <= veh.speed2Level and veh.speed2Level <= 4 then
		speedLevel = veh.speed2Level;
	end
	-- 20 km/h => lastSpeed = 5.555E-3 => speedLevelFactor = 234 * 5.555E-3 = 1.3
	-- 10 km/h =>                         speedLevelFactor                  = 0.7
	local speedLevelFactor = math.min( veh.lastSpeed * 234, 0.5 ) 

	if not allowedToDrive or speedLevel == 0 then
		AIVehicleExtension.statEvent( veh, "tS", dt )
		veh.isHirableBlocked = true		
		return 0, 1, true, 0, 0
	end
	
	veh.isHirableBlocked = false
	
	local offsetOutside = 0;
	if     veh.acParameters.rightAreaActive then
		offsetOutside = -1;
	elseif veh.acParameters.leftAreaActive then
		offsetOutside = 1;
	end;
	
	self.turnOutsideTimer = self.turnOutsideTimer - dt;

--==============================================================				
	
	if     veh.acTurnStage ~= 0 then
		veh.aiRescueTimer = veh.aiRescueTimer - dt;
	else
		veh.aiRescueTimer = math.max( veh.aiRescueTimer, veh.acDeltaTimeoutStop )
	end
	
	if veh.aiRescueTimer < 0 then
		veh:stopAIVehicle()
		return
	end
	if veh.acTurnStage > 0 and AutoSteeringEngine.getTurnDistanceSq( veh ) > AIVEGlobals.aiRescueDistSq then
		veh:stopAIVehicle()
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
	local turnAngle = math.deg(AutoSteeringEngine.getTurnAngle(veh));

	if AIVEGlobals.devFeatures > 0 then
		veh.atHud.InfoText = string.format( "Turn stage: %2i, angle: %3i",veh.acTurnStage,turnAngle )
	end

	if veh.acParameters.leftAreaActive then
		turnAngle = -turnAngle;
	end;

	local fruitsDetected, fruitsAll = AutoSteeringEngine.hasFruits( veh, 0.9 )
	
	if fruitsDetected and veh.acTurnStage < 0 then
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
		local smooth       = 0
		
		if  veh.acTurnStage < 0 or veh.acTraceSmoothOffset == nil or not fruitsDetected then
			veh.acTraceSmoothOffset = AutoSteeringEngine.getTraceLength(veh) + 1
		elseif AIVEGlobals.smoothFactor > 0 and AIVEGlobals.smoothMax > 0 and AutoSteeringEngine.getTraceLength(veh) > 3 then --and fruitsDetected then
			smooth = Utils.clamp( AIVEGlobals.smoothFactor * ( AutoSteeringEngine.getTraceLength(veh) - veh.acTraceSmoothOffset ), 0, AIVEGlobals.smoothMax ) * Utils.clamp( speedLevelFactor, 0.7, 1.3 ) 
		end

		detected, angle2, border, tX, _, tZ = AIVehicleExtension.detectAngle( veh, smooth, veh.acTurnStage == -13 )
		
		if border > 0 then
			turn2Outside = true
			speedLevel = 4
			if AutoSteeringEngine.hasLeftFruits( veh ) then
				detected = false
			else
				detected = true
			end
		else
			turn2Outside           = false
			veh.acTurnInTheMiddle = nil
		end		
		
				
		if      veh.acTurnStage            == 0 
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
			
			AIVehicleExtension.debugPrint( veh, radToString(angle2).." => "..radToString(angle).." ("..tostring(veh.acParameters.leftAreaActive)..")")
			
			angle2    = nil
		elseif  detected then
		-- everything is ok
		elseif  veh.acTurnStage == -3 or veh.acTurnStage == -13 or veh.acTurnStage == -23 then
		-- start of hired worker
			if turn2Outside then
				angle =  veh.acDimensions.maxSteeringAngle
			else
				angle = 0
			end
		elseif  turn2Outside
				and veh.acTurnStage < 0
				and fruitsDetected then
		-- retry after failed turn
			if     veh.acTurnMode == "C" 
					or veh.acTurnMode == "8" 
					or veh.acTurnMode == "O" then
				if veh.acTurnStage == -2 or veh.acTurnStage == -12 or veh.acTurnStage == -22 then
					AutoSteeringEngine.shiftTurnVector( veh, 0.5 )
					veh.acTurnStage = 105
				end
			else
				if veh.acTurnStage == -2 or veh.acTurnStage == -12 or veh.acTurnStage == -22 then
					AutoSteeringEngine.shiftTurnVector( veh, 0.5 )
					veh.acTurnStage = 110
				else
					AutoSteeringEngine.shiftTurnVector( veh, 0.5 )
					veh.acTurnStage = 115
				end
			end
			veh.turnTimer = veh.acDeltaTimeoutWait;
		
		else
		-- we are still ahead of the field
			veh.acTraceSmoothOffset = nil
			
			if     veh.acTurnStage == -2 or veh.acTurnStage == -12 or veh.acTurnStage == -22 then
			-- after U-turn
				local a, o = AutoSteeringEngine.navigateToSavePoint( veh, 3, AIVehicleExtension.navigationFallbackRetry )
				if not o then
					if turn2Outside then
						angle =  veh.acDimensions.maxSteeringAngle
					else
						angle = -veh.acDimensions.maxLookingAngle 
					end
				elseif veh.acParameters.leftAreaActive then
					angle = a
				else
					angle = -a
				end	
			elseif turn2Outside then
		
				if     veh.acTurnStage < 0 then 
					angle = veh.acDimensions.maxSteeringAngle
				elseif noReverseIndex > 0 then 
					angle = veh.acDimensions.maxLookingAngle 
				else 
					angle = 0
				end 
			elseif veh.acTurnStage == -1 or veh.acTurnStage == -11 or veh.acTurnStage == -21 then
			-- after 90° turn
				a = AutoSteeringEngine.navigateToSavePoint( veh, 4, AIVehicleExtension.navigationFallbackRotateMinus )
				if veh.acParameters.leftAreaActive then
					angle = a
				else
					angle = -a
				end	
			else
				angle = math.min( math.max( math.rad( 0.5 * turnAngle ), -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle )
			end
		end
	
	
--==============================================================				
--==============================================================				
-- searching...
	if     ( -3 <= veh.acTurnStage and veh.acTurnStage < 0 )
			or (-13 <= veh.acTurnStage and veh.acTurnStage < -10 )then

		if veh.acTurnStage >= -3 then
			veh.acTurnStage = veh.acTurnStage -20;
			veh.turnTimer   = veh.acDeltaTimeoutNoTurn;
		
		elseif  fruitsAll 
				and detected 
				and veh.acTurnInTheMiddle == nil
				and not ( veh.acFullAngle ) then
			if veh.acClearTraceAfterTurn then
				AutoSteeringEngine.clearTrace( veh );
				AutoSteeringEngine.saveDirection( veh, false, not turn2Outside );
			end
			AutoSteeringEngine.ensureToolIsLowered( veh, true )
			veh.acTurnStage        = 0;
			veh.acTurn2Outside     = false;
			veh.turnTimer          = veh.acDeltaTimeoutNoTurn;
			veh.acTurnOutsideTimer = math.max( veh.turnTimer, veh.acDeltaTimeoutNoTurn );
			veh.aiRescueTimer      = veh.acDeltaTimeoutStop;
		end;
		
--==============================================================				
	elseif -23 <= veh.acTurnStage and veh.acTurnStage < -20 then
		--AutoSteeringEngine.ensureToolIsLowered( veh, true )
		AIVehicleExtension.setAIImplementsMoveDown(veh,true);
		veh.acTurnStage = veh.acTurnStage + 10;					
				
--==============================================================				
-- threshing...					
	elseif veh.acTurnStage == 0 then		
		
		local doTurn = false;
		local uTurn  = false;
		
		local turnTimer = veh.turnTimer
	--if fruitsDetected and turn2Outside then
	--	turnTime = veh.acTurnOutsideTimer 
	--end
		
		if     detected and ( fruitsDetected or turn2Outside ) then
			doTurn = false
			veh.turnTimer   	      = math.max(veh.turnTimer,veh.acDeltaTimeoutRun);
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
			if     detected then
				doTurn                     = false
				veh.acTurnStage           = -1
				veh.aiRescueTimer         = 3 * veh.acDeltaTimeoutStop;
				angle                      = 0			
				veh.acClearTraceAfterTurn = false
				veh.turnTimer             = veh.acDeltaTimeoutWait;
				AutoSteeringEngine.initTurnVector( veh, false, true )
				AIVehicleExtension.setAIImplementsMoveDown(veh,false);
				AutoSteeringEngine.ensureToolIsLowered( veh, false )
			elseif AutoSteeringEngine.getTraceLength(veh) < 10 then		
				uTurn = false
				veh.acClearTraceAfterTurn = false
			else
				uTurn = veh.acParameters.upNDown
				veh.acClearTraceAfterTurn = true
			end
		end
		
		if doTurn then		
			veh.acTurn2Outside = false
			veh.aiRescueTimer  = 3 * veh.acDeltaTimeoutStop;
			angle               = 0
			
			AutoSteeringEngine.initTurnVector( veh, uTurn, turn2Outside )

			if not turn2Outside then 
				local dist    = math.floor( 2.5 * math.max( 10, veh.acDimensions.distance ) )
				local wx,_,wz = AutoSteeringEngine.getAiWorldPosition( veh )
				local stop    = true
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
							if      AutoSteeringEngine.isChainPointOnField( veh, lx-0.5, lz-0.5 ) 
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
					veh:stopAIVehicle()
					return
				end
			end
			
			if     uTurn               then
		-- the U turn
				--invert turn angle because we will swap left/right in about 10 lines
				
				turnAngle = -turnAngle;
				if     veh.acTurnMode == "O" then				
					veh.acTurnStage = 70				
				elseif veh.acTurnMode == "8" then
					veh.acTurnStage = 80				
				elseif veh.acTurnMode == "A" then
					veh.acTurnStage = 50;
				elseif veh.acTurnMode == "Y" then
					veh.acTurnStage = 40;
				else--if veh.acTurnMode == "T" then
					veh.acTurnStage = 20;
					
				--if noReverseIndex > 0 and AutoSteeringEngine.noTurnAtEnd( veh ) then
				--	veh.acTurn2Outside = true
				--end
				end
				veh.turnTimer = veh.acDeltaTimeoutWait;
				veh.waitForTurnTime = g_currentMission.time + veh.turnTimer;
				if veh.acTurnStage == 20 and veh.acTurn2Outside then
				else
					veh.acParameters.leftAreaActive  = not veh.acParameters.leftAreaActive;
					veh.acParameters.rightAreaActive = not veh.acParameters.rightAreaActive;
					AIVehicleExtension.sendParameters(veh);
				end					
				AutoSteeringEngine.setChainStraight( veh );	
			elseif turn2Outside then
				veh.acTurn2Outside = true
		-- turn to outside because we are in the middle of the field
				if     veh.acTurnMode == "C" 
						or veh.acTurnMode == "8" 
						or veh.acTurnMode == "O" then
					veh.acTurnStage = 100
				else	
					veh.acTurnStage = 120
				end
				veh.turnTimer = veh.acDeltaTimeoutWait;
			elseif veh.acTurnMode == "C" 
					or veh.acTurnMode == "8" 
					or veh.acTurnMode == "O" then
		-- 90° turn w/o reverse
				veh.acTurnStage = 5;
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
				veh.acTurnStage = 1;
				veh.turnTimer = veh.acDeltaTimeoutWait;
			elseif veh.acTurnMode == "7" then 
		-- 90° new turn with reverse
				veh.acTurnStage = 90;
				veh.turnTimer = veh.acDeltaTimeoutWait;
			else
		-- 90° turn with reverse
				veh.acTurnStage = 30;
				veh.turnTimer = veh.acDeltaTimeoutWait;
			end
		elseif detected or fruitsDetected then
			AutoSteeringEngine.saveDirection( veh, true, not turn2Outside );
		end
		
--==============================================================				
--==============================================================				
	end
	
	
	
	if angle ~= nil then
		if not veh.acParameters.leftAreaActive then
			angle = -angle 
		end
		tX,tZ = AutoSteeringEngine.getWorldTargetFromSteeringAngle( vehicle, angle )
	end

	maxSpeed = AutoSteeringEngine.getMaxSpeed( veh, dt, 1, allowedToDrive, true, speedLevel, false, 0.7 )
			
	return tX, tZ, true, maxSpeed, distanceToStop
end


