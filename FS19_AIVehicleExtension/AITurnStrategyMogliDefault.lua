
--
-- AITurnStrategyMogliDefault
--

AITurnStrategyMogliDefault = {}
local AITurnStrategyMogliDefault_mt = Class(AITurnStrategyMogliDefault, AITurnStrategyMogli)

function AITurnStrategyMogliDefault:new(customMt)
	if customMt == nil then
		customMt = AITurnStrategyMogliDefault_mt
	end
	local self = AITurnStrategy:new(customMt)
	return self
end

--============================================================================================================================
-- onEndTurn
--============================================================================================================================
function AITurnStrategyMogliDefault:onEndTurn( ... )
	AITurnStrategyMogliDefault:superClass().onEndTurn( self, ... )
	self.lastTurnStage = nil
end

--============================================================================================================================
-- gotoNextStage
--============================================================================================================================
function AITurnStrategyMogliDefault:gotoNextStage( turnData )
	local veh = self.vehicle 
	if veh ~= nil then
		local ts0 =turnData.stage
		turnData.stage = turnData.stage + 1;
		self.aiveTurnTimer	 = veh.acDeltaTimeoutWait;
		for _,ts in pairs( AIVehicleExtension.turnStageEnd ) do
			if ts[1] == ts0 then
				turnData.stage = ts[2]
			end
		end
	end
end

--============================================================================================================================
-- fillStages
--============================================================================================================================
function AITurnStrategyMogliDefault:getNextStage( dt, vX,vY,vZ, turnData, stageId )
	if stageId == 1 then
		return self:getStageFromFunction( AITurnStrategyMogliDefault.getDriveDataDefault )
	end
end

--============================================================================================================================
-- getDriveDataDefault
--============================================================================================================================
function AITurnStrategyMogliDefault:getDriveDataDefault( dt, vX,vY,vZ, turnData )

  local veh = self.vehicle
	
	if turnData.stage <= 0 then
		return 
	end
	
	veh.acTurnStage = turnData.stage
	if veh.acChopperWithCourseplay then
		if 89 <= turnData.stage and turnData.stage <= 99 then
			veh.acTurnStage = 0
		end
	end
	
	if self.lastTurnStage == nil or self.lastTurnStage ~= turnData.stage then
		self.lastTurnStage = turnData.stage
		self.turnStageData = nil
		veh.aiRescueTimer = math.max( veh.aiRescueTimer, veh.acDeltaTimeoutStop )
	end
	
	local tX, tZ, moveForwards, distanceToStop, inactive, noLower = nil, nil, true, math.huge, false, nil
		
	AIVehicleExtension.statEvent( veh, "t0", dt )

	AIVehicleExtension.checkState( veh )
	if not AutoSteeringEngine.hasTools( veh ) then
		veh:stopAIVehicle(AIVehicle.STOP_REASON_UNKOWN)
		return;
	end
	
	local allowedToDrive =  AutoSteeringEngine.checkAllowedToDrive( veh, not ( veh.acParameters.isHired  ) )
	if not allowedToDrive then
		AIVehicleExtension.setStatus( self, 0 )
	end
	
	veh.acNoSneak       = false
	veh.acIsAnimPlaying = false
	if AIVehicleExtension.waitForAnimTurnStage( veh, turnData.stage ) then
		local isPlaying, noSneak = AutoSteeringEngine.checkIsAnimPlaying( veh, veh.acImplementsMoveDown )
		
		if isPlaying then
			if    veh.acAnimWaitTimer == nil then
				veh.acAnimWaitTimer = veh.acDeltaTimeoutWait
				veh.acIsAnimPlaying = true
			elseif veh.acAnimWaitTimer > 0 then
				veh.acAnimWaitTimer = veh.acAnimWaitTimer - dt
				veh.acIsAnimPlaying = true
			end
		else
			veh.acAnimWaitTimer = nil
			noSneak              = false
		end
		
		if noSneak then
			if    veh.acNoSneakTimer == nil then
				veh.acNoSneakTimer = veh.acDeltaTimeoutWait
				veh.acNoSneak = true
			elseif veh.acNoSneakTimer > 0 then
				veh.acNoSneakTimer = veh.acNoSneakTimer - dt
				veh.acNoSneak = true
			end
		else
			veh.acNoSneakTimer = nil
		end
		
		if      allowedToDrive 
				and veh.acNoSneak then
			AIVehicleExtension.setStatus( veh, 3 )
			allowedToDrive = false
		end
	else
		veh.acAnimWaitTimer = nil
		veh.acNoSneakTimer  = nil
	end
	
	if not allowedToDrive then
		-- tX, tZ, moveForwards, allowedToDrive, distanceToStop, angle, inactive, noLower
		AIVehicleExtension.statEvent( veh, "tS", dt )
		veh.isHirableBlocked = true		
		
		if self.lastDirection ~= nil then
			if self.lastDirection[3] ~= nil then
				AutoSteeringEngine.steer( veh, dt, self.lastDirection[3], veh.spec_aiVehicle.aiSteeringSpeed, false );
			end
			return self.lastDirection[1], self.lastDirection[2], true, self.lastDirection[4], 0, self.lastDirection[3], false, false
		end		
		return vX, vZ, true, false, 0, 0, false, false
	end
	
	veh.isHirableBlocked = false
	
	veh.acLastSteeringAngle = nil

	local moveForwards = true

	local offsetOutside = 0;
	if     veh.acParameters.rightAreaActive then
		offsetOutside = -1;
	elseif veh.acParameters.leftAreaActive then
		offsetOutside = 1;
	end;
	
	self.aiveTurnTimer = self.aiveTurnTimer - dt;
	
	local turnProgress = 0.5

--==============================================================				
	
	veh.aiRescueTimer = veh.aiRescueTimer - dt;
	
	if veh.aiRescueTimer < 0 then
		veh:stopAIVehicle(AIVehicle.STOP_REASON_BLOCKED_BY_OBJECT)
		return
	end
	if AutoSteeringEngine.getTurnDistanceSq( veh ) > AIVEGlobals.aiRescueDistSq then
		veh:stopAIVehicle(AIVehicle.STOP_REASON_BLOCKED_BY_OBJECT)
		return
	end
		
--==============================================================				
	local angle, angle2;
	local angleMax = veh.acDimensions.maxSteeringAngle;
	local detected = false;
	local border   = 0;
	local angleFactor;
	local offsetOutside;
	local noReverseIndex = 0;
	local angleOffset = 6;
	local angleOffsetStrict = 3;
	local stoppingDist = 0.5;
	local smoothAngle = 0.1
--==============================================================		
--==============================================================		
	local turnAngle = math.deg(AutoSteeringEngine.getTurnAngle(veh));

	if AIVEGlobals.devFeatures > 0 then
		local t = AIVehicleExtension.getToolAngle( veh )
		if t ~= nil then 
			t = math.deg( t )
		else 
			t = 999 
		end 
		veh.atHud.InfoText = string.format( "Turn stage: %2i, angle: %3.0f, tool: %3.0f",turnData.stage,turnAngle,t )
	end

	if veh.acParameters.leftAreaActive then
		turnAngle = -turnAngle;
	end;

	local fruitsDetected, fruitsAll = AutoSteeringEngine.hasFruits( veh )
	
	if fruitsDetected and turnData.stage < 0 then
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
		
		
	local veh_acTurn2Outside = false
		
--============================================================================================================================						
--============================================================================================================================		
-- move far enough			
	if     turnData.stage == 1 then
		turnProgress = 0.15
		inactive = true

		turnData.stage4Point = nil 
		--AIVehicleExtension.setAIImplementsMoveDown(veh,false);
		
		--if turnAngle > -angleOffset then
		--	angle = veh.acDimensions.maxSteeringAngle;
		--else
		--	angle = 0;
		--end
		angle = math.min( math.max( math.rad( turnAngle ), -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle )

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, false );
		local toolAngle = AutoSteeringEngine.getToolAngle( veh )
		local nextTS = false
		
		if veh_acTurn2Outside then
			if      math.abs( turnAngle ) < angleOffset 
					and math.abs( toolAngle ) < AIVEGlobals.maxToolAngleF * veh.acDimensions.maxSteeringAngle then
				nextTS = true
			end
		else
			if      math.abs( turnAngle ) < angleOffset 
					and math.abs( toolAngle ) < AIVEGlobals.maxToolAngleF * veh.acDimensions.maxSteeringAngle 
					and z > math.max( veh.acDimensions.radius, AIVEGlobals.minRadius ) then
				nextTS = true
				distanceToStop = math.max( 0, math.max( veh.acDimensions.radius, AIVEGlobals.minRadius ) - z )
			end
		end
		
		if nextTS then
			AutoSteeringEngine.ensureToolIsLowered( veh, false )
			turnData.stage   = turnData.stage + 1;
			self.aiveTurnTimer     = veh.acDeltaTimeoutWait;
			allowedToDrive     = false;			
			angle              = 0
			veh.waitForTurnTime = g_currentMission.time + self.aiveTurnTimer;
		end

--==============================================================				
-- going back I
	elseif turnData.stage == 2 then
		turnProgress = 0.2
		
		moveForwards   = false;					
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, false );
		angle = -math.min( math.max( math.rad( turnAngle ), -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle )

		if z < math.max( veh.acDimensions.radius, AIVEGlobals.minRadius ) + stoppingDist then
			turnData.stage         = turnData.stage + 1;
			veh.waitForTurnTime    = g_currentMission.time + veh.acDeltaTimeoutWait
			if veh_acTurn2Outside then
				angle = 0 ---veh.acDimensions.maxSteeringAngle
			elseif veh.acDimensions.wheelBase > 0 and z > 0 then
				angle = AIVEUtils.clamp( math.atan2( veh.acDimensions.wheelBase, z / ( 1 - math.sin( math.abs( math.rad( turnAngle ) ) ) ) ), 0, veh.acDimensions.maxSteeringAngle )
			else				
				angle = veh.acDimensions.maxSteeringAngle
			end
		end

--==============================================================				
-- going back II
	elseif turnData.stage == 3 then
		turnProgress = 0.3

		AutoSteeringEngine.setSteeringAngle( veh, 0 )
		if veh_acTurn2Outside then
			detected, _, border = AutoSteeringEngine.processChain( veh, false, nil, nil, "M" )
			if border <= 0 then
				detected = true
			end
		else
			AutoSteeringEngine.syncRootNode( veh, true )
			AutoSteeringEngine.setChainStraight( veh )

			border   = AutoSteeringEngine.getAllChainBorders( veh, 1, AIVEGlobals.chainMax );
			detected = border > 0
		end
	
		moveForwards = false;			
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, false );

		if veh_acTurn2Outside and x*x+z*z > 100 then
			turnData.stage = turnData.stage + 1;
			self.aiveTurnTimer = veh.acDeltaTimeoutStart
		elseif detected then
			angle                = 0
			turnData.stage     = turnData.stage + 1;
			veh.waitForTurnTime = g_currentMission.time + veh.acDeltaTimeoutWait
			self.aiveTurnTimer       = veh.acDeltaTimeoutWait
		elseif veh_acTurn2Outside then
			angle = 0
		elseif math.abs( turnAngle ) > 90 - angleOffset 
		   and not fruitsDetected then
			turnData.stage     = turnData.stage + 1;
			self.aiveTurnTimer       = veh.acDeltaTimeoutStart
			angle                = 0
			veh.waitForTurnTime = g_currentMission.time + veh.acDeltaTimeoutWait
		elseif math.abs( turnAngle ) > 120 - angleOffset then
			turnData.stage     = turnData.stage + 1;
			self.aiveTurnTimer       = veh.acDeltaTimeoutStart
			angle                = math.rad( 120 - math.abs( turnAngle ) )
			veh.waitForTurnTime = g_currentMission.time + veh.acDeltaTimeoutWait
		elseif veh.acDimensions.wheelBase > 0 and z > 0 then
			angle = AIVEUtils.clamp( math.atan2( veh.acDimensions.wheelBase, z / ( 1 - math.sin( math.abs( math.rad( turnAngle ) ) ) ) ), 0, veh.acDimensions.maxSteeringAngle )
		else
			angle = veh.acDimensions.maxSteeringAngle
		end

		if noReverseIndex > 0 and veh_acTurn2Outside and angle ~= nil then			
			angle = AIVehicleExtension.getStraighBackwardsAngle( veh, turnAngle - AIVEUtils.clamp( math.deg( angle ), -5, 5 ) )
		  smoothAngle = 1
		end
						
--==============================================================				
-- going back III
	elseif turnData.stage == 4 then
		turnProgress = 0.4

		if veh_acTurn2Outside then
			detected, angle2, border = AutoSteeringEngine.processChain( veh, false, nil, nil, "M" )
		else 
			detected, angle2, border = AutoSteeringEngine.processChain( veh, false, nil, nil, "M" )
		end 
		
		moveForwards = false;					
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, false );
		local dist2 = 0
		
		if not detected then
			turnData.stage4Point = nil
			local endAngle = 120
			if border > 0 then	
				--angle = -veh.acDimensions.maxSteeringAngle
				local toolAngle = AutoSteeringEngine.getToolAngle( veh );			
				angle  = nil;
				angle2 = math.min( math.max( toolAngle, -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle );
			elseif math.abs( turnAngle ) > endAngle - angleOffset then
				angle = math.rad( endAngle - math.abs( turnAngle ) )
			elseif veh_acTurn2Outside then
				angle = -veh.acDimensions.maxSteeringAngle
			else
				angle = veh.acDimensions.maxSteeringAngle
			end
		else
			-- reverse => invert steeering angle2
			if angle2 ~= nil then
				angle2 = -angle2
			end
			
			if veh_acTurn2Outside then
				local x,_,z = AutoSteeringEngine.getAiWorldPosition( veh )			
				
				if turnData.stage4Point == nil then 
					turnData.stage4Point = { x=x, z=z }
				else 
					dist2 = (x-turnData.stage4Point.x)^2 + (z-turnData.stage4Point.z)^2 
				end
			else 
				dist2 = 10 
			end
		end
		
		if noReverseIndex > 0 and veh_acTurn2Outside and angle ~= nil then			
		--local toolAngle = AutoSteeringEngine.getToolAngle( veh );			
		--angle  = nil;
		--angle2 = math.min( math.max( toolAngle, -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle );
			angle = AIVehicleExtension.getStraighBackwardsAngle( veh, turnAngle - AIVEUtils.clamp( math.deg( angle ), -5, 5 ) )
			smoothAngle = 1
		end
						
		if     ( detected and dist2 > 9 )
				or self.aiveTurnTimer < 0
				or x*x + z*z      > 400 then
			if not detected then
				angle = 0
				if AIVEGlobals.devFeatures > 0 then
					if self.aiveTurnTimer < 0  then
						self:addDebugText("time out: "..tostring(veh.acDeltaTimeoutNoTurn))
					elseif x*x + z*z > 400 then
						self:addDebugText("too far: 400m")
					end
				end
			end
				
			turnData.stage4Point = nil
			turnData.stage       = -1
			veh.waitForTurnTime   = g_currentMission.time + veh.acDeltaTimeoutWait
		end


--==============================================================				
--==============================================================				
-- 90° corner w/o going reverse					
	elseif turnData.stage == 10 then
		turnProgress = 0.01
	
		inactive = true
		noLower  = true
		
		angle = math.min( math.max( math.rad( turnAngle ), -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle )
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, false );
		veh:acDebugPrint("T"..tostring(turnData.stage)..": "..AutoSteeringEngine.degToString(turnAngle)..", "..AutoSteeringEngine.posToString(x)..", "..AutoSteeringEngine.posToString(z))
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );			
		if z > turn75.radius * ( 1 - math.sin(math.rad(turnAngle)) ) then
			turnData.stage = turnData.stage + 1
		end
		
--==============================================================				
	elseif turnData.stage == 11 then
		turnProgress = 0.3
	
		inactive = true
		noLower  = true
		
		veh:acDebugPrint("T"..tostring(turnData.stage)..": "..AutoSteeringEngine.degToString(turnAngle))
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, false )
		
		AutoSteeringEngine.ensureToolIsLowered( veh, false )
		if turnAngle < angleOffsetStrict - 90 then
			turnData.stage = turnData.stage + 1
		end;
		
--==============================================================				
	elseif turnData.stage == 12 then
		turnProgress = 0.6

		inactive = true
		noLower  = true
		
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, false );
		veh:acDebugPrint("T"..tostring(turnData.stage)..": "..AutoSteeringEngine.degToString(turnAngle)..", "..AutoSteeringEngine.posToString(x)..", "..AutoSteeringEngine.posToString(z))
		
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );			
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, false, true )
		if math.abs( x ) < turn75.radius + veh.acDimensions.toolDistance then
			angle = 0
		else
			turnData.stage = turnData.stage + 1
		end;
					
--==============================================================				
	elseif turnData.stage == 13 then
		turnProgress = 0.8
	
		inactive = true
		noLower  = true
		
		veh:acDebugPrint("T"..tostring(turnData.stage)..": "..AutoSteeringEngine.degToString(turnAngle))		
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, false, true )
		
		if turnAngle > 0 then
			turnData.stage = turnData.stage + 1
		end
		
--==============================================================						
	elseif turnData.stage == 14 then
		turnProgress = 0.8
	
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, false );
		veh:acDebugPrint("T"..tostring(turnData.stage)..": "..AutoSteeringEngine.degToString(turnAngle)..", "..AutoSteeringEngine.posToString(x)..", "..AutoSteeringEngine.posToString(z))
		
		inactive = true
		noLower  = false
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );			
		
		if fruitsDetected then			
			turnData.stage   = -1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutStart;
		elseif turnAngle < 120 then 
			turnData.stage = turnData.stage + 1
		elseif math.abs( z ) < turn75.radius then 
			turnData.stage = turnData.stage + 1
		else
			angle = AIVehicleExtension.getMaxAngleWithTool( veh, false, true )
		end
		
--==============================================================						
	elseif turnData.stage == 15 then
		turnProgress = 0.99

		local toolAngle = AutoSteeringEngine.getToolAngle( veh );	
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, false );
		if not veh.acParameters.leftAreaActive then
			toolAngle = -toolAngle
			x         = -x
		end
		
		veh:acDebugPrint("T"..tostring(turnData.stage)..": "..AutoSteeringEngine.degToString(turnAngle)..": "..AutoSteeringEngine.radToString(toolAngle)..", "..AutoSteeringEngine.posToString(x)..", "..AutoSteeringEngine.posToString(z))
		
		inactive = true
		noLower  = false
	
	--if      turnAngle < 90 + angleOffset
	--		and ( fruitsDetected 
	--			 or math.abs( toolAngle ) < AIVEGlobals.maxToolAngle2 
	--			 or x < 3 + veh.acDimensions.toolDistance ) then 
		if     turnAngle + math.deg( toolAngle ) < 120 + angleOffset 
				or x < AIVEGlobals.lowerAdvance + stoppingDist + veh.acDimensions.toolDistance then 
			detected, angle2, border = AutoSteeringEngine.processChain( veh, false, nil, nil, "M" )
		else
			detected = false
			border   = 1
		end

		if fruitsDetected then			
			turnData.stage   = -1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutStart;
		elseif detected and border <= 0 then 
			veh:acDebugPrint("detected")
		else 
			angle2, onTrack, tX, tZ  = AutoSteeringEngine.navigateToSavePoint( veh, 4 )			
			if onTrack then 
				veh:acDebugPrint("on track")
			else 
				veh:acDebugPrint("fall back")
				angle2, tX, tZ = nil, nil, nil 
				angle = veh.acDimensions.maxSteeringAngle * math.min( 1, veh.acDimensions.radius * ( 1 - math.cos(math.rad(turnAngle - 90)) ) / z )
			end 
		end 
--==============================================================				
--==============================================================				
-- the new U-turn with reverse
	elseif turnData.stage == 20 then
		turnProgress = 0.01
	
		inactive = true
		angle = 0;
		turnData.stage   = turnData.stage + 1;					
		self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
		
		--AIVehicleExtension.setAIImplementsMoveDown(veh,false);
				
--==============================================================				
-- move far enough if tool is in front
	elseif turnData.stage == 21 then
		turnProgress = 0.2
	
		inactive = true
		angle = 0;

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh )
		local dist = 2 + math.max( 0, veh.acDimensions.toolDistance, veh.acDimensions.distance - turn75.radius )
		
		if turn75.radius > turn75.radiusT then
		-- space for the extra turn to get the tool angle to 0
			dist = dist + 2 + turn75.radius - turn75.radiusT
		end
		
		dist = dist + veh.acParameters.turnOffset
		
		veh:acDebugPrint( string.format("T21: x: %0.3fm z: %0.3fm dist: %0.3fm (%0.3fm %0.3fm %0.3fm %0.3fm)",x, z, dist, veh.acDimensions.toolDistance, veh.acDimensions.zBack, veh.acDimensions.radius, turn75.radiusT ) )
		
		if z > dist - stoppingDist then
			AutoSteeringEngine.ensureToolIsLowered( veh, false )
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
		end

--==============================================================				
-- turn 90°
	elseif turnData.stage == 22 then
		turnProgress = 0.3
	
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, false )
		
		local toolAngle = AutoSteeringEngine.getToolAngle( veh );	
		if not veh.acParameters.leftAreaActive then
			toolAngle = -toolAngle
		end
		toolAngle = math.deg( toolAngle )
				
		if -turnAngle > 90 + AIVEGlobals.maxToolAngleF * veh.acDimensions.maxSteeringAngle or turnAngle + 90 + 0.2 * toolAngle < angleOffset then	
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
		end

--==============================================================			
-- move forwards and reduce tool angle	
	elseif turnData.stage == 23 then
		turnProgress = 0.4
	

		local toolAngle = AutoSteeringEngine.getToolAngle( veh )
		if not veh.acParameters.leftAreaActive then
			toolAngle = -toolAngle;
		end;
		--toolAngle = math.deg( toolAngle )

		--angle = turnAngle + 90 + 0.3 * toolAngle
		--
		--if math.abs( turnAngle + 90 ) < 9 and math.abs( angle ) < 3 then
		
		angle = AIVEUtils.clamp( math.rad( turnAngle + 90 ), AIVehicleExtension.getMaxAngleWithTool( veh, true ), AIVehicleExtension.getMaxAngleWithTool( veh, false ) )
		if      math.abs( turnAngle + 90 ) < angleOffset 
				and math.abs( toolAngle ) < AIVEGlobals.maxToolAngleF * veh.acDimensions.maxSteeringAngle then
			angle = 0
			
			local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
			if veh.acParameters.leftAreaActive then x = -x end

			x = x - 1 - veh.acDimensions.radius -- + math.max( 0, veh.acDimensions.radius - turn75.radiusT )
			
			if x > -stoppingDist or z < 0 then
      -- no need to drive backwards
				turnData.stage     = 26
				veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
				self.aiveTurnTimer       = 0
			else
				turnData.stage   = turnData.stage + 1;					
				self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
			end
		end

--==============================================================				
-- wait		
	elseif turnData.stage == 24 then
		turnProgress = 0.5
	
		allowedToDrive = false;						
		moveForwards = false;				
		local target = -90
		if noReverseIndex > 0 then
			target = -93
		end
		angle  = AIVehicleExtension.getStraighBackwardsAngle( veh, target )
		smoothAngle = 1
		if self.aiveTurnTimer < 0 then
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutStop;
		end
		
--==============================================================				
-- move backwards (straight)		
	elseif turnData.stage == 25 then		
		turnProgress = 0.6
	
		moveForwards = false;					
		local target = -90
		if noReverseIndex > 0 then
			target = -93
		end
		angle  = AIVehicleExtension.getStraighBackwardsAngle( veh, target )
		smoothAngle = 1
		
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if veh.acParameters.leftAreaActive then x = -x end
		
	--x = x - 2 - veh.acDimensions.radius - math.max( 0.2 * veh.acDimensions.radius, 1 )
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh )
		x = x - math.max( turn75.radius + 2, turn75.radius * 1.15 ) + math.max( 0, turn75.radius - turn75.radiusT )

		if allowedToDrive and ( x > -stoppingDist or z < 0 ) then
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
		end
		
--==============================================================				
-- wait
	elseif turnData.stage == 26 then
		turnProgress = 0.6
	
		local onTrack    = false
		angle2, onTrack, tX, tZ  = AutoSteeringEngine.navigateToSavePoint( veh, 1 )
		if not onTrack then
			angle  = AIVehicleExtension.getMaxAngleWithTool( veh, false )
			angle2 = nil
		else
			angle  = nil
		end
		
		if self.aiveTurnTimer < 0 then
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutStop;
			
		else
			allowedToDrive = false;						
		end

--==============================================================				
-- turn 90°
	elseif turnData.stage == 27 or turnData.stage == 74  then
		turnProgress = self:getTurnProgress( turnAngle, {{ -80, 0.6 }, { -140, 0.9}, { -160, 0.98 }} )
		
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
				
		noLower = false
		
		local onTrack
		angle = nil
		angle2, onTrack, tX, tZ = AutoSteeringEngine.navigateToSavePoint( veh, 1 )

		veh:acDebugPrint("T"..tostring(turnData.stage)
									..": "..tostring(turnAngle)
									..", "..string.format("%3d%%",turnProgress*100)
									..", "..tostring(onTrack)
									..", "..tostring(veh.acParameters.leftAreaActive)
									..", "..AutoSteeringEngine.radToString(angle2))
		
		if fruitsDetected or turnAngle <= angleOffset - 180 then
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutStop
		elseif not onTrack then
			angle = AIVehicleExtension.getMaxAngleWithTool( veh, false )
		end
		
--==============================================================				
-- turn 90°
	elseif turnData.stage == 28 or turnData.stage == 75  then
		turnProgress = 0.99
	

		detected = false
		angle    = nil
		noLower = false
		
		local doIt = 0
		if     fruitsDetected
				or ( math.abs( turnAngle ) >= 180 - angleOffset 
				 and math.abs( AutoSteeringEngine.getToolAngle( veh ) ) <= AIVEGlobals.maxToolAngle2 ) then
			doIt = 2
		elseif AutoSteeringEngine.hasArticulatedAxis( veh ) then
			doIt = 0
		elseif turnAngle > 0 or turnAngle < -165 then
			doIt = 1
		end
		
		local onTrack, absAngle = false, nil
		angle = nil
		if doIt > 0 then
			detected, angle2, border = AutoSteeringEngine.processChain( veh, false, nil, nil, "M" )
			if detected then
				if veh.acParameters.leftAreaActive then
					absAngle =  angle2 
				else
					absAngle = -angle2 
				end
			end
		else
			detected, angle2, border = false, nil, 0
		end
		
		if not ( detected and border <= 0 and doIt >= 2 ) then
			angleN, onTrack, tX, tZ = AutoSteeringEngine.navigateToSavePoint( veh, 1 )
			if onTrack then
				if detected and math.abs( angleN - angle2 ) < 0.5 * veh.acDimensions.maxSteeringAngle then
					tX = nil
					tZ = nil
				else
					angle2   = angleN 
					detected = false 
				end
			end
		end
		
		veh:acDebugPrint("T"..tostring(turnData.stage)
									..": "..tostring(turnAngle)
									..", "..tostring(doIt)
									..", "..tostring(onTrack)
									..", "..tostring(detected)
									..", "..tostring(veh.acParameters.leftAreaActive)
									..", "..AutoSteeringEngine.radToString(angle2))
		
		if doIt >= 2 and detected and border <= 0 then
			if fruitsDetected or ( self.aiveTurnTimer < 0 and math.abs( turnAngle ) >= 180 - angleOffset ) then
				turnData.stage = -2
				self.aiveTurnTimer  = veh.acDeltaTimeoutNoTurn;
			end
		elseif fruitsDetected then
			if turnData.stage >= 70 then
				turnData.stage = 105
			else
				turnData.stage = 110
			end
			self.aiveTurnTimer    = veh.acDeltaTimeoutNoTurn
		elseif not ( onTrack or detected ) then
			if math.abs( turnAngle ) < 150 then
				angle  = AIVehicleExtension.getMaxAngleWithTool( veh, false )
			elseif turnData.stage >= 70 then
				turnData.stage = 105
			else
				turnData.stage = 110
			end
			self.aiveTurnTimer    = veh.acDeltaTimeoutNoTurn
		else
			self.aiveTurnTimer    = veh.acDeltaTimeoutNoTurn
		end
	
--==============================================================				
--==============================================================				
-- 90° turn to inside with reverse
	elseif turnData.stage == 30 then
		turnProgress = 0.01
	

		--AIVehicleExtension.setAIImplementsMoveDown(veh,false);
		turnData.stage   = turnData.stage + 1;
		self.aiveTurnTimer     = veh.acDeltaTimeoutWait;
		--veh.waitForTurnTime = g_currentMission.time + self.aiveTurnTimer;

--==============================================================				
-- wait
	elseif turnData.stage == 31 then
		turnProgress = 0.2
	
		allowedToDrive = false;				
		moveForwards = false;					
		angle = 0
		
		if self.aiveTurnTimer < 0 or AIVehicleExtension.stopWaiting( veh, angle ) then
			AutoSteeringEngine.ensureToolIsLowered( veh, false )
			turnData.stage   = turnData.stage + 1;					
		end

--==============================================================				
-- move backwards (straight)		
	elseif turnData.stage == 32 then		
		turnProgress = 0.4
	
		moveForwards = false;					
		angle  = nil;
		local toolAngle = AutoSteeringEngine.getToolAngle( veh );
		angle2 = math.min( math.max( toolAngle, -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle );

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh );
		
		local wx,_,wz = AutoSteeringEngine.getAiWorldPosition( veh );
		local f = 0.7
		if  AutoSteeringEngine.checkField( veh, wx, wz ) then
			f = 1.4
		end
				
		if z < f * veh.acDimensions.radius + stoppingDist then
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
		end

--==============================================================				
-- turn 50°
	elseif turnData.stage == 33 then
		turnProgress = 0.55
	
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
		
		local toolAngle = AutoSteeringEngine.getToolAngle( veh );	
		if veh.acParameters.leftAreaActive then
			toolAngle = -toolAngle
		end
		
		if turnAngle - 0.6 * math.deg( toolAngle ) > 50 - angleOffset then
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
		end

--==============================================================			
-- move forwards and reduce tool angle	
	elseif turnData.stage == 34 then
		turnProgress = 0.6
	

		local toolAngle = AutoSteeringEngine.getToolAngle( veh )
		
		if turnAngle > 50 + angleOffset then
			angle = AIVehicleExtension.getMaxAngleWithTool( veh, false )
		elseif turnAngle < 50 - angleOffset then
			angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
		else
			angle  = nil;		
			angle2 = math.min( math.max( -toolAngle, -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle );
		end
		
		if math.abs(math.deg(toolAngle)) < 5 and math.abs( turnAngle - 50 ) < angleOffset then
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
		end

--==============================================================				
-- wait		
	elseif turnData.stage == 35 then
		turnProgress = 0.65
	
		allowedToDrive = false;						
		moveForwards = false;					
		angle  = 0;

		if self.aiveTurnTimer < 0 or AIVehicleExtension.stopWaiting( veh, angle ) then
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutStop;
		end
		
--==============================================================				
-- move backwards (straight)		
	elseif turnData.stage == 36 then		
		turnProgress = 0.7
	
		moveForwards = false;					
	--angle  = nil;
	--local toolAngle = AutoSteeringEngine.getToolAngle( veh );
	--angle2 = math.min( math.max( toolAngle, -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle );
		angle  = AIVehicleExtension.getStraighBackwardsAngle( veh, 50 )
		smoothAngle = 1
		
		local _,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh );
		
		detected, angle2, border = AutoSteeringEngine.processChain( veh, false, nil, nil, "M" )
		
		if z < 0 or ( detected and z < 0.5 * veh.acDimensions.distance ) then				
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
		end
		
--==============================================================				
-- wait
	elseif turnData.stage == 37 then
		turnProgress = 0.75
	
		allowedToDrive = false;						
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
		
		if self.aiveTurnTimer < 0 or AIVehicleExtension.stopWaiting( veh, angle ) then
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutStop;
		end

--==============================================================				
-- turn 45°
	elseif turnData.stage == 38 then
		turnProgress = 0.8
	
		local x, allowedToDrive = AIVehicleExtension.getTurnVector( veh );
		if veh.acParameters.leftAreaActive then x = -x end

		detected, angle2, border = AutoSteeringEngine.processChain( veh, false, nil, nil, "M" )
			
		if turnAngle < 90 - math.deg( veh.acDimensions.maxSteeringAngle ) then
			angle = -veh.acDimensions.maxSteeringAngle;
		elseif fruitsDetected or detected or border <= 0 or math.abs( turnAngle ) > 90 or x < 0 then
			turnData.stage = -1;					
			self.aiveTurnTimer   = veh.acDeltaTimeoutStart;
		else
			angle = 0
		end
		
--==============================================================				
-- wait after 90° turn
	elseif turnData.stage == 39 then
		turnProgress = 0.99
	
		allowedToDrive = false;						
		
		angle = 0;
		
		if self.aiveTurnTimer < 0 or AIVehicleExtension.stopWaiting( veh, angle ) then
			turnData.stage = -1;					
			self.aiveTurnTimer   = veh.acDeltaTimeoutStart;
		end;

--==============================================================				
-- U turn with reverse
--==============================================================				
-- go to the right distance before the U-turn
	elseif turnData.stage == 40 then
		turnProgress = 0.01
	

		inactive     = true
		noLower      = true
		moveForwards = true
		angle        = math.rad( turnAngle )
		local x,z    = AIVehicleExtension.getTurnVector( veh );
		if not veh.acParameters.leftAreaActive then x = -x end
		veh:acDebugPrint( string.format("T%d: %4.1f %4.1f %3d°",turnData.stage,x,z,turnAngle) )
		
		if     z > veh.acDimensions.uTurnDist4x + 0.5 then
			turnData.stage = turnData.stage + 1
		elseif z < veh.acDimensions.uTurnDist4x - 0.5 then
			turnData.stage = turnData.stage + 2
		else
			turnData.stage = turnData.stage + 3
		end
			
--==============================================================				
-- go to the right distance before the U-turn
	elseif turnData.stage == 41 then
		turnProgress = 0.2
	

		inactive     = true
		noLower      = true
		moveForwards = false
		angle        = -math.rad( turnAngle )
		local x,z    = AIVehicleExtension.getTurnVector( veh );
		if not veh.acParameters.leftAreaActive then x = -x end
		veh:acDebugPrint( string.format("T%d: %4.1f %4.1f %3d°",turnData.stage,x,z,turnAngle) )
		
		if z <= veh.acDimensions.uTurnDist4x + 0.5 then
			turnData.stage = turnData.stage + 2
		end
		self.aiveTurnTimer  = veh.acDeltaTimeoutRun

--==============================================================				
-- go to the right distance before the U-turn
	elseif turnData.stage == 42 then
		turnProgress = 0.25
	

		inactive     = true
		noLower      = true
		moveForwards = true
		angle        = math.rad( turnAngle )
		local x,z    = AIVehicleExtension.getTurnVector( veh );
		if not veh.acParameters.leftAreaActive then x = -x end
		veh:acDebugPrint( string.format("T%d: %4.1f %4.1f %3d°",turnData.stage,x,z,turnAngle) )
		
		if z >= veh.acDimensions.uTurnDist4x - 0.5 then
			turnData.stage = turnData.stage + 1
			self.aiveTurnTimer  = veh.acDeltaTimeoutRun
		end

--==============================================================				
-- turn 90°
	elseif turnData.stage == 43 then
		turnProgress = 0.3
	

		noLower      = true
		moveForwards = true
		angle        = veh.acDimensions.maxSteeringAngle
		local x,z    = AIVehicleExtension.getTurnVector( veh );
		if not veh.acParameters.leftAreaActive then x = -x end
		veh:acDebugPrint( string.format("T%d: %4.1f %4.1f %3d°",turnData.stage,x,z,turnAngle) )
		
		if turnAngle < -87 then

			if     x > veh.acDimensions.distance + stoppingDist then
			-- move to right position II
				turnData.stage = turnData.stage + 1
				self.aiveTurnTimer  = veh.acDeltaTimeoutRun
			elseif x < veh.acDimensions.distance - stoppingDist then
			-- move to right position II
				turnData.stage = turnData.stage + 2
				self.aiveTurnTimer  = veh.acDeltaTimeoutRun
			else
			-- turn 30°
				targetAngle    = veh.acDimensions.maxSteeringAngle
				turnData.stage = turnData.stage + 3
				self.aiveTurnTimer  = veh.acDeltaTimeoutRun
			end
		end

--==============================================================				
-- move to right position II
	elseif turnData.stage == 44 then
		turnProgress = 0.35
	

		noLower      = true
		moveForwards = false
		angle        = math.rad( turnAngle + 90 )
		local x,z    = AIVehicleExtension.getTurnVector( veh );
		if not veh.acParameters.leftAreaActive then x = -x end
		veh:acDebugPrint( string.format("T%d: %4.1f %4.1f %3d°",turnData.stage,x,z,turnAngle) )
		
		if x <= veh.acDimensions.distance + stoppingDist then
			targetAngle      = veh.acDimensions.maxSteeringAngle
			moveForwards     = true					
			turnData.stage = turnData.stage + 2
			self.aiveTurnTimer  = veh.acDeltaTimeoutRun
		end
		
--==============================================================				
-- move to right position II
	elseif turnData.stage == 45 then
		turnProgress = 0.4	

		noLower      = true
		angle        = math.rad( turnAngle + 90 )
		local x,z    = AIVehicleExtension.getTurnVector( veh );
		if not veh.acParameters.leftAreaActive then x = -x end
		veh:acDebugPrint( string.format("T%d: %4.1f %4.1f %3d°",turnData.stage,x,z,turnAngle) )
		
		if x >= veh.acDimensions.distance - stoppingDist then
			targetAngle      = veh.acDimensions.maxSteeringAngle
			turnData.stage = turnData.stage + 1
			self.aiveTurnTimer  = veh.acDeltaTimeoutRun
		end
		
--==============================================================				
-- turn 30°
	elseif turnData.stage == 46 then
		turnProgress = 0.5
	
		noLower      = true
		angle        = veh.acDimensions.maxSteeringAngle
		local x,z    = AIVehicleExtension.getTurnVector( veh );
		if not veh.acParameters.leftAreaActive then x = -x end
		veh:acDebugPrint( string.format("T%d: %4.1f %4.1f %3d°",turnData.stage,x,z,turnAngle) )
		
		if turnAngle < -119 then
			moveForwards     = false
			targetAngle      = veh.acDimensions.maxSteeringAngle
			turnData.stage = turnData.stage + 1
			self.aiveTurnTimer  = veh.acDeltaTimeoutRun
		end
		
--==============================================================				
-- turn -60°
	elseif turnData.stage == 47 then
		turnProgress = 0.6
	
		noLower      = true
		moveForwards = false
		angle        = -veh.acDimensions.maxSteeringAngle
		local x,z    = AIVehicleExtension.getTurnVector( veh );
		if not veh.acParameters.leftAreaActive then x = -x end
		veh:acDebugPrint( string.format("T%d: %4.1f %4.1f %3d°",turnData.stage,x,z,turnAngle) )

	--if x > 0.2 and 0 > turnAngle and turnAngle > -180 then
	--	local c = math.cos( math.rad( turnAngle + 180 ) )
	----print(string.format("%7.4f  %7.4f",x/(1-c), veh.acDimensions.radius ) )
	--	angle = -veh.acDimensions.maxSteeringAngle * math.min( 1, veh.acDimensions.radius * ( 1 - c ) / x )
	--elseif turnAngle < 0 then
	--	angle = -math.min( veh.acDimensions.maxSteeringAngle, 2 * math.rad( turnAngle + 180 ) )
	--else
	--	angle = -math.min( veh.acDimensions.maxSteeringAngle, 2 * math.rad( turnAngle - 180 ) )
	--end
		
		if turnAngle < -175 or turnAngle > 0 then
			turnData.stage   = turnData.stage + 1
			self.aiveTurnTimer    = veh.acDeltaTimeoutRun
		end
	
--==============================================================				
-- turn -60°
	elseif turnData.stage == 48 then
		turnProgress = 0.8
	
		noLower      = true
		moveForwards = false
		angle        = math.rad( 180 - turnAngle )
		local x,z    = AIVehicleExtension.getTurnVector( veh );
		if not veh.acParameters.leftAreaActive then x = -x end
		veh:acDebugPrint( string.format("T%d: %4.1f %4.1f %3d°",turnData.stage,x,z,turnAngle) )
		
		if not fruitsDetected then
			detected, angle2, border = AutoSteeringEngine.processChain( veh, false, nil, nil, "M" )
			
			if detected then
				angle  = nil
				angle2 = -angle2
				if math.abs( angle2 ) > veh.acDimensions.maxSteeringAngle then
					detected = false
				end
			end
			
			if detected or border <= 0 then
				turnData.stage = -2
				self.aiveTurnTimer  = veh.acDeltaTimeoutNoTurn;
			end
		end
	
	
--==============================================================				
--==============================================================				
-- 180° turn with 90° backwards
--elseif turnData.stage == 50 then
--	allowedToDrive = false;				
--	moveForwards = false;					
--	angle = 0
--	
--	--if self.aiveTurnTimer < 0 then
--		--AIVehicleExtension.setAIImplementsMoveDown(veh,false);
--		turnData.stage   = turnData.stage + 1;					
--	--end
--==============================================================				
-- move far enough if tool is in front
	elseif turnData.stage == 50 then
		turnProgress = 0.01
	
		--AIVehicleExtension.setAIImplementsMoveDown(veh,false);
		inactive = true
		angle = 0;

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );		
		local dist = math.max( 0, veh.acDimensions.toolDistance )
		
		dist = dist + veh.acParameters.turnOffset

		if z > dist - stoppingDist then
			turnData.stage   = turnData.stage + 1;					
		end

--==============================================================				
-- turn 30°
	elseif turnData.stage == 51 then
		turnProgress = 0.2
	
	--angle = -veh.acDimensions.maxSteeringAngle;
		angle = -math.min( veh.acDimensions.maxSteeringAngle, 2 * math.rad( turnAngle + 60 ) )
		moveForwards = false;					
		
		if turnAngle < -60+angleOffset then
			AutoSteeringEngine.ensureToolIsLowered( veh, false )
			turnData.stage     = turnData.stage + 1;					
			self.aiveTurnTimer       = veh.acDeltaTimeoutNoTurn;
		end
--==============================================================				
-- wait
	elseif turnData.stage == 52 then
		turnProgress = 0.3
	
		allowedToDrive = false;						
		angle = veh.acDimensions.maxSteeringAngle;
		
		if self.aiveTurnTimer < 0 or AIVehicleExtension.stopWaiting( veh, angle ) then
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutStop;
		end

--==============================================================				
-- move forwards (90°)	I	
	elseif turnData.stage == 53 then		
		turnProgress = 0.4
	
	--angle = veh.acDimensions.maxSteeringAngle;
		angle = math.min( veh.acDimensions.maxSteeringAngle, 2 * math.rad( turnAngle + 90 ) )
		
	--allowedToDrive = AIVehicleExtension.stopWaiting( veh, angle )			
		
		if turnAngle < -90+angleOffset then			
			angle               = 0 --math.min( math.max( 2 * math.rad( turnAngle + 90 ), -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle )
			veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
			turnData.stage      = turnData.stage + 1;					
		end
--==============================================================				
-- move forwards (0°) II
	elseif turnData.stage == 54 then		
		turnProgress = 0.51
	
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if not veh.acParameters.leftAreaActive then x = -x end

	--angle = 0
		angle = math.min( math.max( math.rad( turnAngle + 90 ), -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle )
	--allowedToDrive = AIVehicleExtension.stopWaiting( veh, angle )			
		
		if x > 0 then
			angle                = veh.acDimensions.maxSteeringAngle;
			veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
			turnData.stage     = turnData.stage + 1;					
		end
--==============================================================				
-- move forwards (30°) III
	elseif turnData.stage == 55 then		
		turnProgress = 0.55
	
	--angle = veh.acDimensions.maxSteeringAngle;
	
		angle = math.min( veh.acDimensions.maxSteeringAngle, 2 * math.rad( turnAngle + 120 ) )

	--allowedToDrive = AIVehicleExtension.stopWaiting( veh, angle )			
		
		if turnAngle < -120+angleOffset then
			turnData.stage   = turnData.stage + 2;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
		end
--==============================================================				
-- wait
	elseif turnData.stage == 56 then
		turnProgress = 0.6
	
		moveForwards = false;					
		angle = -math.min( veh.acDimensions.maxSteeringAngle, 2 * math.rad( turnAngle + 120 ) )
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if not veh.acParameters.leftAreaActive then x = -x end
		
		veh:acDebugPrint("T56: "..AutoSteeringEngine.posToString(x))
		
		if x + x < veh.acDimensions.radius+stoppingDist+stoppingDist then
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutStop;
			veh.acMinDetected = nil
		end

--==============================================================				
-- move backwards (90°)	I	
	elseif turnData.stage == 57 then		
		turnProgress = 0.7
	
	--angle = -veh.acDimensions.maxSteeringAngle;
	
		moveForwards = false;					
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if not veh.acParameters.leftAreaActive then x = -x end
		
	--local t = veh.acDimensions.radius * ( 1- math.cos( math.rad( turnAngle + 180 ) ) )
	--veh:acDebugPrint(string.format("T57: %7.4f  %7.4f  %7.4f",x, t, turnAngle ) )
	--if -180 < turnAngle and turnAngle < 0 and x > veh.acDimensions.radius * ( 1 - c ) then
	--	angle = -veh.acDimensions.maxSteeringAngle * t / x
		if     -180 < turnAngle and turnAngle < 0 then 
			local a = math.deg( math.acos( math.max( -1, math.min( 1, 1 - x / veh.acDimensions.radius ) ) ) )
			local t = turnAngle + 180 
			local d = math.max( 1, math.min( 20, t * 0.5 ) )
			angle = math.max( -1, math.min( 0, ( a - t - 0.8*d ) / d ) ) * veh.acDimensions.maxSteeringAngle
			veh:acDebugPrint(string.format("T57: %7.4f  %7.4f  %7.4f => %7.4f",x, a, t, math.deg( angle ) ) )
		elseif turnAngle < 0 then
			angle = -math.min( veh.acDimensions.maxSteeringAngle, 2 * math.rad( turnAngle + 180 ) )
		else
			angle = -math.min( veh.acDimensions.maxSteeringAngle, 2 * math.rad( turnAngle - 180 ) )
		end
			
		if turnAngle > 0 or turnAngle < angleOffsetStrict-180 then
			angle                = 0
			veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
			turnData.stage     = turnData.stage + 1;					
		end
		
--==============================================================				
-- move backwards (90°)	II	
	elseif turnData.stage == 58 then		
		turnProgress = 0.8
	
		moveForwards = false;					
	
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if not veh.acParameters.leftAreaActive then x = -x end
		
		if turnAngle < 0 then
			angle = -math.min( veh.acDimensions.maxSteeringAngle, 2 * math.rad( turnAngle + 180 ) )
		else
			angle = -math.min( veh.acDimensions.maxSteeringAngle, 2 * math.rad( turnAngle - 180 ) )
		end 
		
		if fruitsDetected then
			angle2   = nil
		else
			detected, angle2, border = AutoSteeringEngine.processChain( veh, false, nil, nil, "M" )
			
			if detected then
				angle  = nil
				angle2 = -angle2
				if math.abs( angle2 ) > veh.acDimensions.maxSteeringAngle then
					detected = false
				end
			else
				if border <= 0 then
					detected = true
				end
				angle2 = nil
			end
		end
		
		if not ( detected ) then
			veh.acMinDetected = nil
		end
		
		if z > veh.acDimensions.toolDistance - stoppingDist then	
			if z > veh.acDimensions.toolDistance + 10 then	
			--AIVehicleExtension.setAIImplementsMoveDown(veh,true);
				turnData.stage   = turnData.stage + 1;					
				self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
			elseif detected then
				if veh.acMinDetected == nil then
					veh.acMinDetected = z + 1
				elseif z > veh.acMinDetected then
				--AIVehicleExtension.setAIImplementsMoveDown(veh,true);
					turnData.stage   = turnData.stage + 1;					
					self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
					veh.acMinDetected = nil
				end
			end
		end

--==============================================================				
-- wait
	elseif turnData.stage == 59 then
		turnProgress = 0.9
	
		allowedToDrive = false;						
		angle = 0
		
		if self.aiveTurnTimer < 0 or AIVehicleExtension.stopWaiting( veh, angle ) then
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
			AutoSteeringEngine.navigateToSavePoint( veh, 1 )
		end

		--==============================================================				
-- turn 90° II
	elseif turnData.stage == 60 
			or turnData.stage == 61 then
		turnProgress = 0.99	
			
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		noLower  = false
		inactive = true
		
		detected, angle2, border = AutoSteeringEngine.processChain( veh, false, nil, nil, "M" )
		
		if detected then
			if turnData.stage == 60 then
				--AIVehicleExtension.setAIImplementsMoveDown(veh,true);
				self.aiveTurnTimer   = veh.acDeltaTimeoutRun;
				turnData.stage = 61			
			end
				
		--if     fruitsDetected 
		--		or ( z < AutoSteeringEngine.getToolDistance( veh )
		--		 and turnData.stage == 61
		--		 and self.aiveTurnTimer   <  0 ) then
			if     fruitsDetected 
					or z < AutoSteeringEngine.getToolDistance( veh ) then
				turnData.stage = -2
				self.aiveTurnTimer   = veh.acDeltaTimeoutNoTurn;
			end
		elseif fruitsDetected then
			turnData.stage = 110
			self.aiveTurnTimer   = veh.acDeltaTimeoutNoTurn
		else
			turnData.stage = 60
			angle            = nil
			local onTrack    = false
			angle2, onTrack, tX, tZ  = AutoSteeringEngine.navigateToSavePoint( veh, 1 )
			if not onTrack and self.aiveTurnTimer < 0 then
				turnData.stage = 110
				self.aiveTurnTimer   = veh.acDeltaTimeoutNoTurn
			end
		end
		
		
--==============================================================				
--==============================================================				
-- the new U-turn w/o reverse
-- move far enough I
	elseif turnData.stage == 70 then
		turnProgress = 0.01
	
		inactive = true

		local dist = math.max( 2, veh.acDimensions.toolDistance )
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if veh.acParameters.leftAreaActive then x = -x end
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
		x = x + turn75.radius - turn75.radiusT 
		local d2 = 4 * veh.acDimensions.radius * veh.acDimensions.radius - x * x 
		local dx = 0
		if d2 > 0 then 
			dx = - math.sqrt( d2 )
		end 
		angle  = math.rad( turnAngle )
		
		veh:acDebugPrint( string.format("T70: x: %0.3fm z: %0.3fm td: %0.3fm dx: %0.3fm (%0.3fm %0.1f° %0.3fm %0.3fm)",
																		x, z, veh.acDimensions.toolDistance, dx, 
																		veh.acDimensions.radius, turnAngle, turn75.radius, turn75.radiusT ) )		

		if z > dist + dx + stoppingDist then
		-- add extra stoppingDist to be very sure
			turnData.stage      = turnData.stage + 1;					
			veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
			angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
		end
		
--==============================================================				
-- move far enough II
	elseif turnData.stage == 71 then
		turnProgress = 0.1
	
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if veh.acParameters.leftAreaActive then x = -x end
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
		x = x + turn75.radius - turn75.radiusT 
		if turnAngle < 90 - angleOffset then
			angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
		else
			angle = 0
		end
		
		local corr = veh.acDimensions.radius * ( 1 - math.cos( math.rad(turnAngle)))
		local dx   = 0.5 * ( x - turn75.radius - veh.acDimensions.radius )

		if turnAngle > 0 then
			dx = math.min(0,dx + corr)
		else
			dx = math.min(0,dx - corr)
		end		
		
		veh:acDebugPrint( string.format("T71: x: %0.3fm z: %0.3fm dx: %0.3fm (%0.3fm %0.1f° %0.3fm %0.3fm)",x, z, dx, veh.acDimensions.radius, turnAngle, turn75.radius, turn75.radiusT ) )		
		
		if dx > - stoppingDist then
			AutoSteeringEngine.ensureToolIsLowered( veh, false )
		--if turnAngle < angleOffset and x < AIVEUtils.getNoNil( veh.aseActiveX, 0 ) then
			if turnAngle < angleOffset then
				turnData.stage      = turnData.stage + 2;					
				veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
				angle               = AIVehicleExtension.getMaxAngleWithTool( veh, false )
			else
				turnData.stage      = turnData.stage + 1;					
				veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
				angle               = AIVehicleExtension.getMaxAngleWithTool( veh, false )
			end
		end
	
--==============================================================				
-- move far enough III
	elseif turnData.stage == 72 then
		turnProgress = 0.2
	
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, false )
		
		veh:acDebugPrint("T72: "..AutoSteeringEngine.radToString(angle))
		
		if turnAngle < angleOffset then
			turnData.stage     = turnData.stage + 1;					
			veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
		end
	
--==============================================================				
-- now turn 90°
	elseif turnData.stage == 73 then	
		turnProgress = self:getTurnProgress( turnAngle, {{ 0, 0.3 }, { -80, 0.6}} )
	
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, false )
		
		veh:acDebugPrint("T73: "..AutoSteeringEngine.radToString(angle)..string.format(" %3d%%", turnProgress*100))
		
		if turnAngle < angleOffset-90 then		
			angle2, onTrack, tX, tZ  = AutoSteeringEngine.navigateToSavePoint( veh, 1 )					
			turnData.stage = turnData.stage + 1;					
		end
		
--==============================================================				
--==============================================================				
-- U-turn with 8-shape
	elseif turnData.stage == 80 then	
		turnProgress = 0.01
	
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
	--angle = turn75.alpha
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, false )
		
		veh:acDebugPrint("T"..tostring(turnData.stage)..": "..tostring(turnAngle))

		if turnAngle < -90 + angleOffset then
			local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
			veh:acDebugPrint(tostring(x)..", "..tostring(z))
			if x > veh.acDimensions.distance - turn75.radius - turn75.radius then
				turnData.stage = turnData.stage + 1;					
				self.aiveTurnTimer  = veh.acDeltaTimeoutRun;
			else
				angle = 0
			end
		end
		
--==============================================================				
-- turn inside
	elseif turnData.stage == 81 then	
		turnProgress = 0.1
	
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
	--angle = turn75.alpha
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, false )

		if turnAngle < -150 + angleOffset then
			angle = turn75.alpha
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
		end
		
--==============================================================		
-- rotate plow		
	elseif turnData.stage == 82 then	
		turnProgress = 0.2
	
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
	--angle = -turn75.alpha
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
		
		if 		 turnAngle > -90 - angleOffset - angleOffset
				or math.abs( AutoSteeringEngine.getToolAngle( veh ) ) <= AIVEGlobals.maxToolAngle2 then
			turnData.stage     = turnData.stage + 1;					
		end

--==============================================================				
-- turn outside I
	elseif turnData.stage == 83 then	
		turnProgress = 0.4
	
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
	--angle = -turn75.alpha
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )

		if turnAngle > -90 - angleOffset then
			local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
			local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
			if math.abs(x) < veh.acDimensions.distance - turn75.radius - stoppingDist then
				angle          = math.rad( 90 + turnAngle )
				turnData.stage = turnData.stage + 1;					
				self.aiveTurnTimer  = veh.acDeltaTimeoutRun;
			else
				turnData.stage = turnData.stage + 2
				self.aiveTurnTimer  = veh.acDeltaTimeoutRun;
			end
		end

--==============================================================				
-- move far enough
	elseif turnData.stage == 84 then	
		turnProgress = 0.6
	
		angle = math.rad( 90 + turnAngle )

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
		if math.abs(x) > veh.acDimensions.distance - turn75.radius + stoppingDist then
			angle          = -turn75.alpha
			turnData.stage = turnData.stage + 1;					
			self.aiveTurnTimer  = veh.acDeltaTimeoutRun;
		end
		
--==============================================================				
-- turn outside II
	elseif turnData.stage == 85 then	
		turnProgress = 0.8
	
	--angle              = AIVehicleExtension.getMaxAngleWithTool( veh, true )			
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
	--angle = -turn75.alpha
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )

		if turnAngle > 90 then
			turnData.stage = turnData.stage + 1					
			self.aiveTurnTimer  = veh.acDeltaTimeoutRun
		end

--==============================================================				
-- turn 90°
	elseif turnData.stage == 86 then
		turnProgress = 0.95
	
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		
		detected  = false
		local nav = true
		if     fruitsDetected
				or ( math.abs( turnAngle ) >= 180 - angleOffset 
				and math.abs( AutoSteeringEngine.getToolAngle( veh ) ) <= AIVEGlobals.maxToolAngle2 ) then
			nav = false
			detected, angle2, border = AutoSteeringEngine.processChain( veh, false, nil, nil, "M" )
			if border <= 0 then
				detected = true
			end
		end		
		
		veh:acDebugPrint( string.format("T84: x: %0.3fm z: %0.3fm test: %0.3fm fd: %s det: %s ta: %0.1f° to: %0.1f°", x, z, AutoSteeringEngine.getToolDistance( veh ), tostring(fruitsDetected), tostring(detected), turnAngle, math.deg(AutoSteeringEngine.getToolAngle( veh )) ) )
		
		if detected then
			turnData.stage   = -2
			self.aiveTurnTimer     = veh.acDeltaTimeoutNoTurn;
			--AIVehicleExtension.setAIImplementsMoveDown(veh,true);
		elseif nav or z < math.min( 0, AutoSteeringEngine.getToolDistance( veh ) ) - 5 then
			self.aiveTurnTimer     = veh.acDeltaTimeoutNoTurn;
			angle  = nil
			angle2, _, tX, tZ = AutoSteeringEngine.navigateToSavePoint( veh, 1, AIVehicleExtension.navigationFallbackRetry )
		else 
			local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
			angle        = -turn75.alpha
		end
		
--==============================================================				
--==============================================================				
-- 90° new turn with reverse
	elseif turnData.stage == 90 then
		turnProgress = 0.01
	
		inactive = true
		noLower  = true
		if AutoSteeringEngine.getNoReverseIndex( veh ) <= 0 then 
			turnData.stage = turnData.stage + 2; 
		else 
			turnData.stage = turnData.stage + 1;	
		end 
		self.aiveTurnTimer    = veh.acDeltaTimeoutRun;
		angle            = 0
		
--==============================================================				
-- reduce tool angle 
	elseif turnData.stage == 91 then
		turnProgress = 0.2
	
		inactive = true
		noLower  = true
		
		local toolAngle = AutoSteeringEngine.getToolAngle( veh )
		
		angle  = nil;		
		angle2 = math.min( math.max( -toolAngle, -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle );
		
		if math.abs( AutoSteeringEngine.getToolAngle( veh ) ) <= AIVEGlobals.maxToolAngle2 then
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
		end
		
--==============================================================				F
-- move backwards (straight)		
	elseif turnData.stage == 92 then		
		turnProgress = 0.3
	
		inactive = true
		noLower  = true
		moveForwards = false;					
		--angle  = nil;
		--local toolAngle = AutoSteeringEngine.getToolAngle( veh );
		--angle2 = math.min( math.max( toolAngle, -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle );
		angle  = AIVehicleExtension.getStraighBackwardsAngle( veh, 0 )
		smoothAngle = 1

		local _,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh );
		
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
		if     veh.aiveHas.combineVehicle 
				or veh.acDimensions.zBack > 0 then
			local radius   = veh.acDimensions.radius
			if veh.acDimensions.toolDistance > 0 then
				radius = math.sqrt( veh.acDimensions.radius^2 + veh.acDimensions.toolDistance^2 )
			end
			if -z > radius - stoppingDist then				
				AIVehicleExtension.setAIImplementsMoveDown(veh,true,true)		
				AIVehicleExtension.stopCoursePlayMode2( veh, false )
				inactive          = true
				noLower           = false
				moveForwards      = true
				turnData.stage    = 89;					
				self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
				veh.waitForTurnTime = g_currentMission.time + self.aiveTurnTimer;
				angle = -veh.acDimensions.maxSteeringAngle * veh.acDimensions.radius / radius
			end
		else	
			local dist   = math.max( turn75.radius + 2, 1.15 * turn75.radius ) - math.max( 0, turn75.radius - turn75.radiusT )
			if -z > dist then				
	--if z < -veh.acDimensions.radius then				
				turnData.stage   = turnData.stage + 1;					
				self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
				veh.waitForTurnTime = g_currentMission.time + self.aiveTurnTimer;
				angle = 0
			end
		end
	
--==============================================================				
-- turn 90°
	elseif turnData.stage == 89 then		
		turnProgress = 0.4
	
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh );
		local alpha1, alpha2 = 71, 90

		local radius = veh.acDimensions.radius
		if veh.acDimensions.toolDistance > 0 then
			radius = math.sqrt( veh.acDimensions.radius^2 + veh.acDimensions.toolDistance^2 )
			alpha2 = 90 - math.deg( math.atan2( veh.acDimensions.toolDistance, veh.acDimensions.radius ) )
		end
		
		if veh.acDimensions.distance < 3 * veh.acDimensions.radius then
			alpha1 = math.deg( math.atan2( veh.acDimensions.distance, radius ) )
		end

		inactive = true
		noLower  = false
		
		if      math.abs( turnAngle ) < alpha1 - angleOffsetStrict then
			-- do not detect until we turned far enough 
			angle = -veh.acDimensions.maxSteeringAngle
		elseif  math.abs( turnAngle ) < alpha2 - angleOffsetStrict 
				and not AutoSteeringEngine.processOneAngle( veh, 0 ) then
			-- go all the way around the corner
			angle = -veh.acDimensions.maxSteeringAngle
		else
			detected, angle2, border = AutoSteeringEngine.processChain( veh, false, nil, nil, "M" )

			if     border    > 0 then
				-- giving up
				if self.aiveTurnTimer < 0 then
					turnData.stage   = 93
					self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
					veh.waitForTurnTime = g_currentMission.time + self.aiveTurnTimer;
				end
				angle  = veh.acDimensions.maxSteeringAngle
				angle2 = nil
			elseif not detected then
				-- hmm, nothing found
				self.aiveTurnTimer = math.max( self.aiveTurnTimer, veh.acDeltaTimeoutRun )
				angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )		
				angle2 = nil
			elseif turnAngle > 90 - angleOffset or math.abs( x ) > veh.acDimensions.radius then		
				-- this is far enough 
				turnData.stage      = -1
				veh.waitForTurnTime = g_currentMission.time + self.aiveTurnTimer;
			else
				-- great!
				self.aiveTurnTimer = math.max( self.aiveTurnTimer, veh.acDeltaTimeoutRun )
				angle = nil
			end
		end
		
		veh:acDebugPrint("T89: "..AutoSteeringEngine.degToString( turnAngle )
						.." "..AutoSteeringEngine.radToString(angle2)
						.." "..AutoSteeringEngine.degToString(alpha1)
						.." "..tostring(turnData.stage)
						.." "..tostring(detected)
						.." "..tostring(border))
		
--==============================================================				
-- turn 90°
	elseif turnData.stage == 93 then		
		turnProgress = 0.5
	
	--angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
	--
		if     veh.aiveHas.combineVehicle 
				or veh.acDimensions.zBack > 0 then
			inactive = true
			noLower  = false
		end
	
		local onTrack 
		angle2, onTrack, tX, tZ = AutoSteeringEngine.navigateToSavePoint( veh, 2 )		
		
		local ta = AIVehicleExtension.getToolAngle( veh )
		
		veh:acDebugPrint("T93: "..AutoSteeringEngine.degToString( turnAngle ).." "..AutoSteeringEngine.radToString(ta))
		
		if     turnAngle > 90 - angleOffsetStrict + math.deg( ta ) then
			if math.abs( ta ) < AIVEGlobals.maxToolAngleF * veh.acDimensions.maxSteeringAngle then
				turnData.stage = turnData.stage + 4
				self.aiveTurnTimer   = veh.acDeltaTimeoutRun;
			else 
				turnData.stage = turnData.stage + 1
				self.aiveTurnTimer   = veh.acDeltaTimeoutRun;
			end
		elseif onTrack then
			angle  = nil
		else
			turnData.stage = turnData.stage + 2
			self.aiveTurnTimer   = veh.acDeltaTimeoutRun;
		end
		
--==============================================================				
-- turn 90° II
	elseif turnData.stage == 94 then		
		turnProgress = 0.6
	
	--angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
	--
		if     veh.aiveHas.combineVehicle 
				or veh.acDimensions.zBack > 0 then
			inactive = true
			noLower  = false
		end
	
		local onTrack 
		angle2, onTrack, tX, tZ = AutoSteeringEngine.navigateToSavePoint( veh, 2 )		

		local ta = AIVehicleExtension.getToolAngle( veh )
		veh:acDebugPrint("T94: "..AutoSteeringEngine.degToString( turnAngle ).." "..AutoSteeringEngine.radToString(ta))		
		
		
		if      math.abs( turnAngle - 90 - math.deg( ta ) ) < angleOffsetStrict
				and math.abs( turnAngle - 90 )                  < angleOffset       then
			if math.abs( ta ) < AIVEGlobals.maxToolAngleF * veh.acDimensions.maxSteeringAngle then
				turnData.stage = turnData.stage + 3
				self.aiveTurnTimer   = veh.acDeltaTimeoutRun;
			else
				turnData.stage = turnData.stage + 1
				self.aiveTurnTimer   = veh.acDeltaTimeoutRun;
			end
		elseif onTrack then
			angle  = nil
		else
			turnData.stage = turnData.stage + 1
			self.aiveTurnTimer   = veh.acDeltaTimeoutRun;
		end
		
--==============================================================				
-- reduce tool angle I
	elseif turnData.stage == 95 then
		turnProgress = 0.7	
		
		if     veh.aiveHas.combineVehicle 
				or veh.acDimensions.zBack > 0 then
			inactive = true
			noLower  = false
		end
	
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh );
		if veh.acParameters.leftAreaActive then x = -x end
		
	--angle = -turn75.alpha
		angle = -0.3333 * turn75.alpha
		
		veh:acDebugPrint("T95: "..AutoSteeringEngine.radToString( angle ).." "..AutoSteeringEngine.degToString( turnAngle ).." "..tostring(x).." / "..tostring(z).." "..AutoSteeringEngine.radToString( math.atan2( z, x )))

		if turnAngle > 90 - angleOffsetStrict + 0.5 * math.deg( math.abs( AIVehicleExtension.getToolAngle( veh ) ) ) then
			turnData.stage = turnData.stage + 1				
			self.aiveTurnTimer   = veh.acDeltaTimeoutStop;
		end
		
--==============================================================				
-- reduce tool angle II
	elseif turnData.stage == 96 then
		turnProgress = 0.75
	
		if     veh.aiveHas.combineVehicle 
				or veh.acDimensions.zBack > 0 then
			inactive = true
			noLower  = false
		end
	
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh );
		if veh.acParameters.leftAreaActive then x = -x end		
		local target = 90 -- + angleOffset
		if x > 1 then
			target = target + math.deg( math.atan2( z, x ) )
		end
		
		local newTurnAngle = turnAngle - target 
		local f = 1
		if not AutoSteeringEngine.hasArticulatedAxis( veh ) then
			f = 2
		end

		local ta = AIVehicleExtension.getToolAngle( veh )
		
		angle = AIVEUtils.clamp( f * ( math.rad( newTurnAngle ) - math.min( 0, ta ) ), AIVehicleExtension.getMaxAngleWithTool( veh, true ), AIVehicleExtension.getMaxAngleWithTool( veh, false ) )

		veh:acDebugPrint("T96: "..AutoSteeringEngine.radToString( angle ).." "..AutoSteeringEngine.radToString( ta ).." "..AutoSteeringEngine.degToString( turnAngle ).." "..AutoSteeringEngine.degToString( newTurnAngle ).." "..tostring(x).." / "..tostring(z).." "..AutoSteeringEngine.radToString( math.atan2( z, x )))
		
		if      math.abs( newTurnAngle + math.deg( ta ) ) < angleOffsetStrict
				and math.abs( ta ) < AIVEGlobals.maxToolAngleF * veh.acDimensions.maxSteeringAngle then
			turnData.stage = turnData.stage + 1;					
			self.aiveTurnTimer   = veh.acDeltaTimeoutRun;
			angle            = 0
		elseif x > 20 then
			turnData.stage = turnData.stage + 1;					
			self.aiveTurnTimer   = veh.acDeltaTimeoutRun;
			angle            = 0
		end
		
--==============================================================				
-- get tool angle over 90
	elseif turnData.stage == 97 then		
		turnProgress = 0.8
	
		if     veh.aiveHas.combineVehicle 
				or veh.acDimensions.zBack > 0 then
			inactive = true
			noLower  = false
		end
	
		angle    = math.min( -0.1 * veh.acDimensions.maxSteeringAngle, math.rad( turnAngle - 90 ) )
		if turnAngle >= 90 + math.deg( AIVehicleExtension.getToolAngle( veh ) ) + angleOffsetStrict then
			turnData.stage = turnData.stage + 1;					
			self.aiveTurnTimer   = veh.acDeltaTimeoutRun;
			angle            = 0
		end
		
--==============================================================				
-- get turn angle to exactly 90°
	elseif turnData.stage == 98 then		
		turnProgress = 0.85
	
		if     veh.aiveHas.combineVehicle 
				or veh.acDimensions.zBack > 0 then
			inactive = true
			noLower  = false
		end
	
		local newTurnAngle = turnAngle - 90 
		angle = math.rad( newTurnAngle )
		if math.abs( newTurnAngle ) < angleOffsetStrict then
			turnData.stage = turnData.stage + 1;					
			self.aiveTurnTimer   = veh.acDeltaTimeoutRun;
			angle            = 0
			veh.waitForTurnTime = g_currentMission.time + self.aiveTurnTimer;
		end
		
--==============================================================				
-- move backwards (straight)		
	elseif turnData.stage == 99 then		
		turnProgress = 0.9
	
		moveForwards = false;					
	
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh );
		if veh.acParameters.leftAreaActive then x = -x end

		local ta = AIVehicleExtension.getToolAngle( veh )
		
		local xMin, xMax, zMin, zMax = AutoSteeringEngine.getToolsTurnVector( veh )
		if veh.acParameters.leftAreaActive then 
			xMin = -xMin
			xMax = -xMax
			ta   = -ta
		end
		
		local a2
		detected, a2, border = AutoSteeringEngine.processChain( veh, false, nil, nil, "M" )
		if not veh.acParameters.leftAreaActive then
			a2 = -a2
		end
				
		local target, minTarget, maxTarget = 90, 82, 98
		if xMax < -3 then
			local t = 0
			if zMin < -0.5 then
				zMin = zMin + 0.5
			elseif zMin < 0 then
				zMin = 0
			end
			t = math.atan( zMin / xMax )
			target = AIVEUtils.clamp( 90 - math.deg( t+t+t ), minTarget, maxTarget )		
		elseif border > 0 then
			if xMin > 0 then
				target = minTarget
			else
				target = maxTarget
			end
		elseif a2 > 0 then
			if xMin > 0 then
				target = 0.5 * ( target + minTarget )
			else
				target = 0.5 * ( target + maxTarget )
			end
		elseif xMin > 0 then
			target = 88
		end
		
		angle  = AIVehicleExtension.getStraighBackwardsAngle( veh, target )
		smoothAngle = 1
		
		veh:acDebugPrint( "T97: "..AutoSteeringEngine.degToString( turnAngle ).." "..AutoSteeringEngine.radToString( ta ).." "..AutoSteeringEngine.radToString( a2 ).." "..AutoSteeringEngine.degToString( target ).." "..string.format("%2.3fm %2.3fm / %2.3fm", x, z, -veh.acDimensions.toolDistance) )
		
		local xtd = -x-veh.acDimensions.toolDistance 
		
		if      xtd > 0
				and ( border <= 0 or x > 15 ) 
			
			-- allow more tool angle if we are far away
				and math.abs( ta ) < math.rad( xtd )
				and not fruitsDetected 
				and not AutoSteeringEngine.hasLeftFruits( veh ) then
			if self.aiveTurnTimer < 0 then
				turnData.stage = -1
				veh.waitForTurnTime = g_currentMission.time + self.aiveTurnTimer;
				angle = a2
			end
		else
			self.aiveTurnTimer = veh.acDeltaTimeoutRun
		end

--==============================================================				
--==============================================================				
-- going back w/o reverse
	elseif turnData.stage == 100 then
		turnProgress = 0.2
	
		turnData.stage   = turnData.stage + 1;					
		self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
		angle              = AIVehicleExtension.getMaxAngleWithTool( veh, false )

		--AIVehicleExtension.setAIImplementsMoveDown(veh,false,true);
	
--==============================================================				
-- turn 180° I
	elseif turnData.stage == 101 then
		turnProgress = 0.4
	
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
			
		if math.abs( turnAngle ) > 180 - angleOffset then
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
			angle              = 0
		end

--==============================================================				
-- turn 180° I
	elseif turnData.stage == 102 then
		turnProgress = 0.6
	
		angle = 0

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh );
		if z < -5 then
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
			angle              = AIVehicleExtension.getMaxAngleWithTool( veh, true )
		end
		
--==============================================================				
-- turn 180° II
	elseif turnData.stage == 103 then
		turnProgress = 0.8
	
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
			
		if math.abs( turnAngle ) < angleOffset then
			turnData.stage   = -1				
			self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
			angle              = 0
		end

	
--==============================================================				
--==============================================================				
-- going back w/o reverse at the end of a turn
	elseif turnData.stage == 105 then
		turnProgress = 0.2
	
		turnData.stage   = turnData.stage + 1;					
		self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
		angle              = AIVehicleExtension.getMaxAngleWithTool( veh, true )

		--AIVehicleExtension.setAIImplementsMoveDown(veh,false,true);
	
--==============================================================				
-- turn 180° I
	elseif turnData.stage == 106 then
		turnProgress = 0.4
	
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
			
		if math.abs( turnAngle ) < angleOffset then
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
			angle              = 0
		end

--==============================================================				
-- turn 180° I
	elseif turnData.stage == 107 then
		turnProgress = 0.6
	
		angle = 0

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh );
		if z > 5 then
			turnData.stage   = turnData.stage + 1;					
			self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
			angle              = AIVehicleExtension.getMaxAngleWithTool( veh, true )
		end
		
--==============================================================				
-- turn 180° II
	elseif turnData.stage == 108 then
		turnProgress = 0.8
	
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
			
		if math.abs( turnAngle ) > 180 - angleOffset then
			turnData.stage   = -1				
			self.aiveTurnTimer     = veh.acDeltaTimeoutRun;
			angle              = 0
		end

	
--==============================================================				
--==============================================================				
-- forward and reduce tool angle
	elseif  110 <= turnData.stage and turnData.stage < 125 then
	
		local turnStageMod = ( turnData.stage - 110 ) % 5

		turnProgress = 0.1 + 0.2 * turnStageMod
		
		local x,z, allowedToDrive
		if     turnData.stage < 115 then
			x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true, false )	
		elseif turnData.stage < 120 then
			x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, false, false )	
		else
			x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true, true )
		end
		
		if veh.acParameters.leftAreaActive then x = -x end

		local turnMode, targetS, targetA, targetT, targetZ
			
		if     turnData.stage < 115 then
			turnMode = 3
			targetS  = x
			targetZ  = z
			targetT  = 180
		elseif turnData.stage < 120 then
			turnMode = 4
			targetS  = z
			targetZ  = -x
			targetT  = 90
		else
			turnMode = 5
			targetS  = -x
			targetZ  = -z
			targetT  = 0
		end
		
	--print(string.format("%3d: %5.2f %5.2f", turnData.stage, targetS, targetZ ))
		
		targetA  = turnAngle - targetT
				
		if     targetA <= -180 then
			targetA = targetA + 360
		elseif targetA > 180 then
			targetA = targetA - 360
		end
					
--==============================================================				
--==============================================================				
-- forward and reduce tool angle
		if AutoSteeringEngine.getIsAtEnd( veh ) and not fruitsDetected then
			if turnData.stage < 115 then
				turnData.stage = -2
			else
				turnData.stage = -1
			end			
			self.aiveTurnTimer    = veh.acDeltaTimeoutNoTurn;
		elseif turnStageMod == 0 then
		
			if     veh.aiveHas.combineVehicle 
					or veh.acDimensions.zBack > 0 then
				inactive = true
				noLower  = false
			end
		
			if self.aiveTurnTimer < 0 then
				--AIVehicleExtension.setAIImplementsMoveDown(veh,false,true);
			end
			
			local onTrack  = false
			angle2, onTrack, tX, tZ = AutoSteeringEngine.navigateToSavePoint( veh, turnMode )
			
			if      math.abs( targetS ) < 1
					and math.abs( targetA ) < angleOffset then
				if     AutoSteeringEngine.getNoReverseIndex( veh ) <= 0 
						or math.abs( math.deg( AIVehicleExtension.getToolAngle( veh ) ) ) < angleOffsetStrict then
					turnData.stage = turnData.stage + 2;					
					self.aiveTurnTimer   = veh.acDeltaTimeoutRun;
					angle            = 0
				elseif not onTrack then
					turnData.stage = turnData.stage + 1;					
					self.aiveTurnTimer   = veh.acDeltaTimeoutRun;
					angle            = 0
				end
			elseif not onTrack then		
				angle2  = nil
				local a = 0
				if     math.abs( targetS ) < 1 then
					a = math.rad( targetA )
				else
					a = AutoSteeringEngine.normalizeAngle( math.rad( targetA - AIVEUtils.clamp( targetS, -3, 3 ) * 15 ) )
				end
				angle = AIVEUtils.clamp( a, AIVehicleExtension.getMaxAngleWithTool( veh, true ), AIVehicleExtension.getMaxAngleWithTool( veh, false ) ) 
			end
			
			veh:acDebugPrint( tostring(turnData.stage).." "..tostring(onTrack).." "..AutoSteeringEngine.degToString( targetA ).." "..tostring( targetS ).." "..AutoSteeringEngine.radToString( angle2 ).." "..AutoSteeringEngine.radToString( angle ).." "..tostring(x).." "..tostring(z) )
			
	--==============================================================				
	-- forward and reduce tool angle
		elseif turnStageMod == 1 then

			if     veh.aiveHas.combineVehicle 
					or veh.acDimensions.zBack > 0 then
				inactive = true
				noLower  = false
			end
		
			local newTurnAngle = math.rad( targetA )
			
			angle = AIVEUtils.clamp( newTurnAngle, AIVehicleExtension.getMaxAngleWithTool( veh, true ), AIVehicleExtension.getMaxAngleWithTool( veh, false ) )

			if      math.abs( math.deg( newTurnAngle ) ) < angleOffset
					and ( AutoSteeringEngine.getNoReverseIndex( veh ) <= 0
						 or math.abs( math.deg( AIVehicleExtension.getToolAngle( veh ) ) ) < angleOffsetStrict ) then
				--AIVehicleExtension.setAIImplementsMoveDown(veh,false);
				turnData.stage = turnData.stage + 1;					
				self.aiveTurnTimer  = veh.acDeltaTimeoutWait
				angle          = 0
			end
		
	--==============================================================				
	-- backwards and reduce tool angle
		elseif turnStageMod == 2 then
		
			inactive = true
			moveForwards = false
			angle        = AIVehicleExtension.getStraighBackwardsAngle( veh, targetT )
			smoothAngle  = 1
			
			if     math.abs( targetZ ) > 30 then
				turnData.stage   = turnData.stage + 2
				self.aiveTurnTimer    = veh.acDeltaTimeoutRun
			elseif fruitsDetected or targetZ < 0 then
				self.aiveTurnTimer    = veh.acDeltaTimeoutWait
			elseif self.aiveTurnTimer < 0 then
				detected,_,border = AutoSteeringEngine.processChain( veh, false, nil, nil, "M" )
				if border <= 0 then
					turnData.stage = turnData.stage + 1
					self.aiveTurnTimer  = veh.acDeltaTimeoutRun
				end
			end
		
	--==============================================================				
	-- backwards and reduce tool angle
		elseif turnStageMod == 3 then

			inactive = true
			moveForwards      = false
			angle             = AIVehicleExtension.getStraighBackwardsAngle( veh, targetT )
			smoothAngle       = 1
			detected,_,border = AutoSteeringEngine.processChain( veh, false, nil, nil, "M" )
			if border > 0 then
				self.aiveTurnTimer   = veh.acDeltaTimeoutRun;
			elseif self.aiveTurnTimer < 0 then
				turnData.stage  = turnData.stage + 1
				self.aiveTurnTimer   = veh.acDeltaTimeoutRun;
			end
		
	--==============================================================				
	-- forward and reduce tool angle
		else --if turnStageMod == 4 then

			inactive = true
			noLower  = false
		
			moveForwards     = true
			detected, angle2, border, tX,_,tZ = AutoSteeringEngine.processChain( veh, false, nil, nil, "M" )
			
			local onTrack  = false
			if border <= 0 and not detected then
				angle2, onTrack, tX, tZ = AutoSteeringEngine.navigateToSavePoint( veh, turnMode )
				if not onTrack then
					angle2 = 0
				end
			end
			
			if border > 0 then
			--if self.aiveTurnTimer < 0 or fruitsDetected then
				if AutoSteeringEngine.hasLeftFruits( veh ) then
					AutoSteeringEngine.shiftTurnVector( veh, 1 )
					turnData.stage = turnData.stage - 4
				end
			elseif fruitsDetected then
				if turnData.stage < 115 then
					turnData.stage = -2
				else
					turnData.stage = -1
				end
				self.aiveTurnTimer    = veh.acDeltaTimeoutNoTurn;
				--AIVehicleExtension.setAIImplementsMoveDown(veh,true);
			elseif not ( detected or onTrack ) then
				turnData.stage  = turnData.stage - 4
			else
				self.aiveTurnTimer   = veh.acDeltaTimeoutRun;
			end
		end

	end
	
	if      not veh.acImplementsMoveDown 
			and ( not moveForwards or not allowedToDrive ) then
		AutoSteeringEngine.ensureToolIsLowered( veh, false )
	end
	
	if turnData.stage <= 0 then
		return 
	end
	veh:aiTurnProgress( turnProgress, veh.acParameters.leftAreaActive )
	
	if     angle2 ~= nil then
	elseif angle  ~= nil then
		if veh.acParameters.leftAreaActive then
			angle2 =  angle
		else
			angle2 = -angle
		end
		
		if      smoothAngle < 1
				and allowedToDrive
				and tX                    == nil
				and self.lastDirection    ~= nil
				and self.lastDirection[3] ~= nil
				and self.lastDirection[4] ~= nil
				and self.lastDirection[4] == moveForwards then
			angle2 = self.lastDirection[3] + 0.05 * ( angle2 - self.lastDirection[3] )
		end
	else
		angle2 = 0
	end

	self.lastDirection = { tX, tZ, angle2, moveForwards }
	
	if noLower == nil then
		if not allowedToDrive then
			noLower = false
		elseif not moveForwards then
			noLower = true
		elseif inactive then
			noLower = false
		else
			noLower = true 
		end
	end
	
	return tX, tZ, moveForwards, allowedToDrive, distanceToStop, angle2, inactive, noLower
end