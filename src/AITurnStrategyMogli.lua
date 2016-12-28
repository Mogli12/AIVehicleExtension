local function degToString( d )
	if d == nil then
		return "nil"
	end
	return tostring(math.floor( d + 0.5 )).."°"
end
local function radToString( r )
	if r == nil then
		return "nil"
	end
	return degToString( math.deg( r ))
end


--
-- AITurnStrategyMogli
--

-- AITurnStrategy.getTurningSizeBox is a function
-- AITurnStrategy.new is a function
-- AITurnStrategy.isa is a function
-- AITurnStrategy.getDistanceToCollision is a function
-- AITurnStrategy.onEndTurn is a function
-- AITurnStrategy.getDriveData is a function
-- AITurnStrategy.getZOffsetForTurn is a function
-- AITurnStrategy.startTurnFinalization is a function
-- AITurnStrategy.update is a function
-- AITurnStrategy.getAngleInSegment is a function
-- AITurnStrategy.copy is a function
-- AITurnStrategy.class is a function
-- AITurnStrategy.superClass is a function
-- AITurnStrategy.checkCollisionInFront is a function
-- AITurnStrategy.evaluateCollisionHits is a function
-- AITurnStrategy.collisionTestCallback is a function
-- AITurnStrategy.delete is a function
-- AITurnStrategy.adjustHeightOfTurningSizeBox is a function
-- AITurnStrategy.startTurn is a function
-- AITurnStrategy.setAIVehicle is a function
-- AITurnStrategy.drawTurnSegments is a function

AITurnStrategyMogli = {}
local AITurnStrategyMogli_mt = Class(AITurnStrategyMogli, AITurnStrategy)

function AITurnStrategyMogli:new(customMt)
	if customMt == nil then
		customMt = AITurnStrategyMogli_mt
	end
	local self = AITurnStrategy:new(customMt)
	return self
end


function AITurnStrategyMogli:getDriveData(dt, vX,vY,vZ, turnData)

  local veh = self.vehicle
	
	if veh.acTurnStage <= 0 then
		return 
	end

	local tX, tZ, moveForwards, maxSpeed, distanceToStop = nil, nil, true, 0, 0		
		
--============================================================================================================================						
--============================================================================================================================		
-- move far enough			
	if     veh.acTurnStage == 1 then

		veh.acTurnStage4Point = nil 
		AIVehicleExtension.setAIImplementsMoveDown(veh,false);
		
		--if turnAngle > -angleOffset then
		--	angle = veh.acDimensions.maxSteeringAngle;
		--else
		--	angle = 0;
		--end
		angle = math.min( math.max( math.rad( turnAngle ), -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle )

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, false );
		local toolAngle = AutoSteeringEngine.getToolAngle( veh )
		local nextTS = false
		
		if veh.acTurn2Outside then
			if      math.abs( turnAngle ) < angleOffset 
					and math.abs( toolAngle ) < AIVEGlobals.maxToolAngleF * veh.acDimensions.maxSteeringAngle then
				nextTS = true
			end
		else
			if      math.abs( turnAngle ) < angleOffset 
					and math.abs( toolAngle ) < AIVEGlobals.maxToolAngleF * veh.acDimensions.maxSteeringAngle 
					and z > math.max( veh.acDimensions.radius, AIVEGlobals.minRadius ) then
				nextTS = true
			end
		end
		
		if nextTS then
			AutoSteeringEngine.ensureToolIsLowered( veh, false )
			veh.acTurnStage   = veh.acTurnStage + 1;
			veh.turnTimer     = veh.acDeltaTimeoutWait;
			allowedToDrive     = false;			
			angle              = 0
			veh.waitForTurnTime = g_currentMission.time + veh.turnTimer;
		end

--==============================================================				
-- going back I
	elseif veh.acTurnStage == 2 then
		
		moveForwards   = false;					
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, false );
		angle = -math.min( math.max( math.rad( turnAngle ), -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle )

		if 1 == 2 then --    veh.acTurn2Outside and ( x*x+z*z > 100 or noReverseIndex > 0 ) then
			veh.acTurnStage = veh.acTurnStage + 2;
			veh.turnTimer = veh.acDeltaTimeoutNoTurn
		elseif z < math.max( veh.acDimensions.radius, AIVEGlobals.minRadius ) + stoppingDist then
			veh.acTurnStage         = veh.acTurnStage + 1;
		--veh.acLastSteeringAngle = veh.acDimensions.maxSteeringAngle
			veh.waitForTurnTime     = g_currentMission.time + veh.acDeltaTimeoutWait
			if veh.acTurn2Outside then
				angle = 0 ---veh.acDimensions.maxSteeringAngle
			elseif veh.acDimensions.wheelBase > 0 and z > 0 then
				angle = Utils.clamp( math.atan2( veh.acDimensions.wheelBase, z / ( 1 - math.sin( math.abs( math.rad( turnAngle ) ) ) ) ), 0, veh.acDimensions.maxSteeringAngle )
			else				
				angle = veh.acDimensions.maxSteeringAngle
			end
		end

--==============================================================				
-- going back II
	elseif veh.acTurnStage == 3 then

		moveForwards = false;			
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, false );

		if veh.acTurn2Outside and x*x+z*z > 100 then
			veh.acTurnStage = veh.acTurnStage + 1;
			veh.turnTimer = veh.acDeltaTimeoutStart
		elseif detected then
			angle                = 0
		--veh.acTurnStage     = -1
			veh.acTurnStage     = veh.acTurnStage + 1;
			veh.waitForTurnTime = g_currentMission.time + veh.acDeltaTimeoutWait
			veh.turnTimer       = veh.acDeltaTimeoutWait
		elseif veh.acTurn2Outside then
		--angle = -veh.acDimensions.maxLookingAngle
		--if math.abs( turnAngle ) > 30 then
		--	veh.acTurnStage = veh.acTurnStage + 1;
		--	veh.turnTimer = veh.acDeltaTimeoutStart
		--end
			angle = 0
		elseif math.abs( turnAngle ) > 90 - angleOffset 
		   and not fruitsDetected then
			veh.acTurnStage     = veh.acTurnStage + 1;
			veh.turnTimer       = veh.acDeltaTimeoutStart
			angle                = 0
			veh.waitForTurnTime = g_currentMission.time + veh.acDeltaTimeoutWait
		elseif math.abs( turnAngle ) > 120 - angleOffset then
			veh.acTurnStage     = veh.acTurnStage + 1;
			veh.turnTimer       = veh.acDeltaTimeoutStart
			angle                = math.rad( 120 - math.abs( turnAngle ) )
			veh.waitForTurnTime = g_currentMission.time + veh.acDeltaTimeoutWait
		elseif veh.acDimensions.wheelBase > 0 and z > 0 then
			angle = Utils.clamp( math.atan2( veh.acDimensions.wheelBase, z / ( 1 - math.sin( math.abs( math.rad( turnAngle ) ) ) ) ), 0, veh.acDimensions.maxSteeringAngle )
		else
			angle = veh.acDimensions.maxSteeringAngle
		end

		if noReverseIndex > 0 and veh.acTurn2Outside and angle ~= nil then			
		--local toolAngle = AutoSteeringEngine.getToolAngle( veh );			
		--angle  = nil;
		--angle2 = math.min( math.max( toolAngle, -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle );
			angle = AIVehicleExtension.getStraighBackwardsAngle( veh, turnAngle - Utils.clamp( math.deg( angle ), -5, 5 ) )
		end
						
--==============================================================				
-- going back III
	elseif veh.acTurnStage == 4 then

		moveForwards = false;					
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, false );
		local dist2 = 0
		
		if not detected then
			veh.acTurnStage4Point = nil
			local endAngle = 120
			if border > 0 then	
				--angle = -veh.acDimensions.maxSteeringAngle
				local toolAngle = AutoSteeringEngine.getToolAngle( veh );			
				angle  = nil;
				angle2 = math.min( math.max( toolAngle, -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle );
			elseif math.abs( turnAngle ) > endAngle - angleOffset then
				angle = math.rad( endAngle - math.abs( turnAngle ) )
			elseif veh.acTurn2Outside then
				angle = -veh.acDimensions.maxLookingAngle
			else
				angle = veh.acDimensions.maxSteeringAngle
			end
		else
			-- reverse => invert steeering angle2
			if angle2 ~= nil then
				angle2 = -angle2
			end
			
			if veh.acTurn2Outside then
				local x,_,z = AutoSteeringEngine.getAiWorldPosition( veh )			
				
				if veh.acTurnStage4Point == nil then 
					veh.acTurnStage4Point = { x=x, z=z }
				else 
					dist2 = (x-veh.acTurnStage4Point.x)^2 + (z-veh.acTurnStage4Point.z)^2 
				end
			else 
				dist2 = 10 
			end
		end
		
		if noReverseIndex > 0 and veh.acTurn2Outside and angle ~= nil then			
		--local toolAngle = AutoSteeringEngine.getToolAngle( veh );			
		--angle  = nil;
		--angle2 = math.min( math.max( toolAngle, -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle );
			angle = AIVehicleExtension.getStraighBackwardsAngle( veh, turnAngle - Utils.clamp( math.deg( angle ), -5, 5 ) )
		end
						
		if     ( detected and dist2 > 9 )
				or veh.turnTimer < 0
				or x*x + z*z      > 400 then
			if not detected then
				angle = 0
				if AIVEGlobals.devFeatures > 0 then
					if veh.turnTimer < 0  then
						print("time out: "..tostring(veh.acDeltaTimeoutNoTurn))
					elseif x*x + z*z > 400 then
						print("too far: 400m")
					end
				end
			end
				
			veh.acTurnStage4Point = nil
			veh.acTurnStage       = -1
			veh.waitForTurnTime   = g_currentMission.time + veh.acDeltaTimeoutWait
		end


--==============================================================				
--==============================================================				
-- 90° corner w/o going reverse					
	elseif veh.acTurnStage == 5 then
		allowedToDrive = false;				
		if noReverseIndex > 0 then
			local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );			
			angle = turn75.alpha
		else
			angle = veh.acDimensions.maxSteeringAngle
		end
		if veh.acTurn2Outside then
			angle = -angle 
		end
		
		AIVehicleExtension.setAIImplementsMoveDown(veh,false);
		veh.acTurnStage   = 6;					
		
--==============================================================				
	elseif veh.acTurnStage == 6 then
		if noReverseIndex > 0 then
			local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );			
			angle = turn75.alpha
		else
			angle = veh.acDimensions.maxSteeringAngle
		end
		if veh.acTurn2Outside then
			angle = -angle 
		end
		
		AutoSteeringEngine.ensureToolIsLowered( veh, false )
		if turnAngle < 0 then
			veh.acTurnStage   = 7;	
		end;
		
--==============================================================				
	elseif veh.acTurnStage == 7 then
		if     turnAngle > 90 then
			angle = AIVehicleExtension.getMaxAngleWithTool( veh, veh.acTurn2Outside )
		else
			if noReverseIndex > 0 then
				local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );			
				angle = turn75.alpha
			else
				angle = veh.acDimensions.maxSteeringAngle
			end
			if veh.acTurn2Outside then
				angle = -angle 
			end
		end
		
		if veh.acTurn2Outside then				
			if 170 < turnAngle and turnAngle < 180 then
				veh.acTurnStage   = 8;					
			end;
		else
			if math.abs( turnAngle ) > 165 then
				veh.acTurnStage = 9
			end
		end
		
--==============================================================						
	elseif veh.acTurnStage == 8 then
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, veh.acTurn2Outside )
		
		if detected or fruitsDetected then
			veh.acTurnStage   = -1;					
			veh.turnTimer     = veh.acDeltaTimeoutStart;
		end;

--==============================================================						
	elseif veh.acTurnStage == 9 then
	
		if math.abs( turnAngle - 90 ) < math.deg( veh.acDimensions.maxLookingAngle )  then
			detected, angle2, border = AIVehicleExtension.detectAngle( veh, AIVEGlobals.smoothMax )
		else
			detected = false
		end
		
		if fruitsDetected then
			veh.acTurnStage   = -1;					
			veh.turnTimer     = veh.acDeltaTimeoutStart;
		elseif detected then
			angle = nil
			if veh.turnTimer < 0 then
				veh.acTurnStage = -1
			end
		else
			veh.turnTimer = veh.acDeltaTimeoutRun
			local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
			angle2, onTrack = AutoSteeringEngine.navigateToSavePoint( veh, 2, nil, turn75 )		
			if onTrack then
				angle  = nil
			elseif math.abs( turnAngle - 90 ) < angleOffsetStrict then
				veh.acTurnStage   = -1;					
				veh.turnTimer     = veh.acDeltaTimeoutStart;
			else
				angle  = AIVehicleExtension.getMaxAngleWithTool( veh, veh.acTurn2Outside )
				angle2 = nil
			end
		end
	
--==============================================================				
--==============================================================				
-- the new U-turn with reverse
	elseif veh.acTurnStage == 20 then
		angle = 0;
		veh.acTurnStage   = veh.acTurnStage + 1;					
		veh.turnTimer     = veh.acDeltaTimeoutRun;
		
		AIVehicleExtension.setAIImplementsMoveDown(veh,false);
				
--==============================================================				
-- move far enough if tool is in front
	elseif veh.acTurnStage == 21 then
		angle = 0;

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		
		local dist = math.max( 0, math.max( veh.acDimensions.distance, -veh.acDimensions.zBack ) )
		
		if noReverseIndex > 0 then
			dist = math.max( 0, veh.acDimensions.toolDistance + math.max( veh.acDimensions.distance, -veh.acDimensions.zBack ) )
		end
		
		turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh )
		dist = dist + math.max( 1, veh.acDimensions.radius - turn75.radiusT )
		if noReverseIndex > 0 then
		-- space for the extra turn to get the tool angle to 0
			dist = dist + 2
		end
		
		AIVehicleExtension.debugPrint( veh, string.format("T21: x: %0.3fm z: %0.3fm dist: %0.3fm (%0.3fm %0.3fm %0.3fm %0.3fm)",x, z, dist, veh.acDimensions.toolDistance, veh.acDimensions.zBack, veh.acDimensions.radius, turn75.radiusT ) )
		
		if z > dist - stoppingDist then
			AutoSteeringEngine.ensureToolIsLowered( veh, false )
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutRun;
		end

--==============================================================				
-- turn 90°
	elseif veh.acTurnStage == 22 then
		angle = AIVehicleExtension.getMaxAngleWithTool( veh )
		
		local toolAngle = AutoSteeringEngine.getToolAngle( veh );	
		if not veh.acParameters.leftAreaActive then
			toolAngle = -toolAngle
		end
		toolAngle = math.deg( toolAngle )
				
		turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh )
		
		if -turnAngle > 90 + AIVEGlobals.maxToolAngleF * veh.acDimensions.maxSteeringAngle or turnAngle + 90 + 0.2 * toolAngle < angleOffset then
		--if turnAngle < angleOffset - 90 - math.deg(turn75.gammaE) then
			AutoSteeringEngine.setPloughTransport( veh, true, true )
			
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutRun;
		end

--==============================================================			
-- move forwards and reduce tool angle	
	elseif veh.acTurnStage == 23 then

		local toolAngle = AutoSteeringEngine.getToolAngle( veh )
		if not veh.acParameters.leftAreaActive then
			toolAngle = -toolAngle;
		end;
		--toolAngle = math.deg( toolAngle )

		--angle = turnAngle + 90 + 0.3 * toolAngle
		--
		--if math.abs( turnAngle + 90 ) < 9 and math.abs( angle ) < 3 then
		
		angle = Utils.clamp( math.rad( turnAngle + 90 ), AIVehicleExtension.getMaxAngleWithTool( veh, true ), AIVehicleExtension.getMaxAngleWithTool( veh, false ) )
		if      math.abs( turnAngle + 90 ) < angleOffset 
				and math.abs( toolAngle ) < AIVEGlobals.maxToolAngleF * veh.acDimensions.maxSteeringAngle then
			angle = 0
			
			if veh.acTurn2Outside then
				veh.acParameters.leftAreaActive  = not veh.acParameters.leftAreaActive;
				veh.acParameters.rightAreaActive = not veh.acParameters.rightAreaActive;
				AIVehicleExtension.sendParameters(veh);
			end
			
			local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
			if veh.acParameters.leftAreaActive then x = -x end

			if veh.acTurn2Outside then x = -x end
			x = x - 1 - veh.acDimensions.radius -- + math.max( 0, veh.acDimensions.radius - turn75.radiusT )
			
			if x > -stoppingDist or z < 0 then
      -- no need to drive backwards
				if veh.acParameters.leftAreaActive then
					AIVehicle.aiRotateLeft(veh);
				else
					AIVehicle.aiRotateRight(veh);
				end
				AutoSteeringEngine.setPloughTransport( veh, false )
				veh.acTurnStage     = 26
				veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
				veh.turnTimer       = 0
			else
				if noReverseIndex <= 0 then
					if veh.acParameters.leftAreaActive then
						AIVehicle.aiRotateLeft(veh);
					else
						AIVehicle.aiRotateRight(veh);
					end
					AutoSteeringEngine.setPloughTransport( veh, true, true )
				end
			
				veh.acTurnStage   = veh.acTurnStage + 1;					
				veh.turnTimer     = veh.acDeltaTimeoutRun;
			end
		end

--==============================================================				
-- wait		
	elseif veh.acTurnStage == 24 then
		allowedToDrive = false;						
		moveForwards = false;				
		local target = -90
		if noReverseIndex > 0 then
			target = -87
		end
		if veh.acTurn2Outside then
			target = -target
		end
		angle  = AIVehicleExtension.getStraighBackwardsAngle( veh, target )
		if veh.turnTimer < 0 then
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutStop;
		end
		
--==============================================================				
-- move backwards (straight)		
	elseif veh.acTurnStage == 25 then		
		moveForwards = false;					
		local target = -90
		if noReverseIndex > 0 then
			target = -87
		end
		if veh.acTurn2Outside then
			target = -target
		end
		angle  = AIVehicleExtension.getStraighBackwardsAngle( veh, target )
		
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if veh.acParameters.leftAreaActive then x = -x end
		
		if veh.acTurn2Outside then x = -x end
	--x = x - 2 - veh.acDimensions.radius - math.max( 0.2 * veh.acDimensions.radius, 1 )
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh )
		x = x - math.max( turn75.radius + 2, turn75.radius * 1.15 )

		if allowedToDrive and ( x > -stoppingDist or z < 0 ) then
			if noReverseIndex > 0 then
				if veh.acParameters.leftAreaActive then
					AIVehicle.aiRotateLeft(veh);
				else
					AIVehicle.aiRotateRight(veh);
				end
			end
			AutoSteeringEngine.setPloughTransport( veh, false )--, true )
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutRun;
		end
		
--==============================================================				
-- wait
	elseif veh.acTurnStage == 26 then
		local onTrack    = false
		angle2, onTrack  = AutoSteeringEngine.navigateToSavePoint( veh, 1 )
		if not onTrack then
			angle  = AIVehicleExtension.getMaxAngleWithTool( veh, false )
			angle2 = nil
		else
			angle  = nil
		end
		
		if veh.turnTimer < 0 then
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutStop;
			
		else
			allowedToDrive = false;						
		end

--==============================================================				
-- turn 90°
	elseif veh.acTurnStage == 27 then
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		
		detected = false
		if     fruitsDetected
				or math.abs( turnAngle )   >= 180 - angleOffset
				or ( math.abs( turnAngle ) >= 180 - math.deg( veh.acDimensions.maxLookingAngle ) 
				 and math.abs( AutoSteeringEngine.getToolAngle( veh ) ) <= AIVEGlobals.maxToolAngle2 ) then
			detected, angle2, border = AIVehicleExtension.detectAngle( veh )
		end		
		
		AIVehicleExtension.debugPrint( veh, string.format("T27: x: %0.3fm z: %0.3fm test: %0.3fm fd: %s det: %s ta: %0.1f°", x, z, AutoSteeringEngine.getToolDistance( veh ), tostring(fruitsDetected), tostring(detected), turnAngle ) )
		
		if detected then
			if fruitsDetected or math.abs( turnAngle ) >= 180 - angleOffset then
				veh.acTurnStage = -2
				veh.turnTimer   = veh.acDeltaTimeoutNoTurn;
				AIVehicleExtension.setAIImplementsMoveDown(veh,true);
			end
		elseif fruitsDetected then
			veh.acTurnStage = 110
			veh.turnTimer   = veh.acDeltaTimeoutNoTurn
		else
			veh.turnTimer   = veh.acDeltaTimeoutNoTurn;
			angle            = nil
		--local turn75     = AutoSteeringEngine.getMaxSteeringAngle75( veh );
			local onTrack    = false
		--angle2, onTrack  = AutoSteeringEngine.navigateToSavePoint( veh, 1, nil, turn75 )
			angle2, onTrack  = AutoSteeringEngine.navigateToSavePoint( veh, 1 )
			if not onTrack then
				if math.abs( turnAngle ) < 150 then
					angle  = AIVehicleExtension.getMaxAngleWithTool( veh, false )
					angle2 = nil
				else
					veh.acTurnStage = 110
					veh.turnTimer   = veh.acDeltaTimeoutNoTurn
				end
			end
		end
		
--==============================================================				
--==============================================================				
-- 90° turn to inside with reverse
	elseif veh.acTurnStage == 30 then

		AIVehicleExtension.setAIImplementsMoveDown(veh,false);
		veh.acTurnStage   = veh.acTurnStage + 1;
		veh.turnTimer     = veh.acDeltaTimeoutWait;
		--veh.waitForTurnTime = g_currentMission.time + veh.turnTimer;

--==============================================================				
-- wait
	elseif veh.acTurnStage == 31 then
		allowedToDrive = false;				
		moveForwards = false;					
		angle = 0
		
		if veh.turnTimer < 0 or AIVehicleExtension.stopWaiting( veh, angle ) then
			AutoSteeringEngine.ensureToolIsLowered( veh, false )
			veh.acTurnStage   = veh.acTurnStage + 1;					
		end

--==============================================================				
-- move backwards (straight)		
	elseif veh.acTurnStage == 32 then		
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
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutRun;
		end

--==============================================================				
-- turn 50°
	elseif veh.acTurnStage == 33 then
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
		
		local toolAngle = AutoSteeringEngine.getToolAngle( veh );	
		if veh.acParameters.leftAreaActive then
			toolAngle = -toolAngle
		end
		
		if turnAngle - 0.6 * math.deg( toolAngle ) > 50 - angleOffset then
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutRun;
		end

--==============================================================			
-- move forwards and reduce tool angle	
	elseif veh.acTurnStage == 34 then

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
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutRun;
		end

--==============================================================				
-- wait		
	elseif veh.acTurnStage == 35 then
		allowedToDrive = false;						
		moveForwards = false;					
		angle  = 0;

		if veh.turnTimer < 0 or AIVehicleExtension.stopWaiting( veh, angle ) then
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutStop;
		end
		
--==============================================================				
-- move backwards (straight)		
	elseif veh.acTurnStage == 36 then		
		moveForwards = false;					
	--angle  = nil;
	--local toolAngle = AutoSteeringEngine.getToolAngle( veh );
	--angle2 = math.min( math.max( toolAngle, -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle );
		angle  = AIVehicleExtension.getStraighBackwardsAngle( veh, 50 )
		
		local _,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh );
		
		detected, angle2, border = AIVehicleExtension.detectAngle( veh )
		
		if z < 0 or ( detected and z < 0.5 * veh.acDimensions.distance ) then				
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutRun;
		end
		
--==============================================================				
-- wait
	elseif veh.acTurnStage == 37 then
		allowedToDrive = false;						
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
		
		if veh.turnTimer < 0 or AIVehicleExtension.stopWaiting( veh, angle ) then
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutStop;
		end

--==============================================================				
-- turn 45°
	elseif veh.acTurnStage == 38 then
		local x, allowedToDrive = AIVehicleExtension.getTurnVector( veh );
		if veh.acParameters.leftAreaActive then x = -x end

		detected, angle2, border = AIVehicleExtension.detectAngle( veh )
			
		if turnAngle < 90 - math.deg( veh.acDimensions.maxLookingAngle ) then
			angle = -veh.acDimensions.maxSteeringAngle;
		elseif fruitsDetected or detected or math.abs( turnAngle ) > 90 or x < 0 then
			veh.acTurnStage = -1;					
			veh.turnTimer   = veh.acDeltaTimeoutStart;
		else
			angle = 0
		end
		
--==============================================================				
-- wait after 90° turn
	elseif veh.acTurnStage == 39 then
		allowedToDrive = false;						
		
		angle = 0;
		
		if veh.turnTimer < 0 or AIVehicleExtension.stopWaiting( veh, angle ) then
			veh.acTurnStage = -1;					
			veh.turnTimer   = veh.acDeltaTimeoutStart;
		end;

--==============================================================				
--==============================================================				
-- 180° turn with 90° backwards
	elseif veh.acTurnStage == 40 then
		angle = 0;
		veh.acTurnStage   = veh.acTurnStage + 1;					
		veh.turnTimer     = veh.acDeltaTimeoutRun;

		AIVehicleExtension.setAIImplementsMoveDown(veh,false);
		
--==============================================================				
-- move far enough if tool is in front
	elseif veh.acTurnStage == 41 then
		angle = 0;

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if z > math.max( 0, veh.acDimensions.toolDistance ) + 1 - stoppingDist then
			AutoSteeringEngine.ensureToolIsLowered( veh, false )
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutRun;
		end

--==============================================================				
-- wait
	elseif veh.acTurnStage == 42 then
		allowedToDrive = false;				
		moveForwards = false;					
		angle = 0
		
		if veh.turnTimer < 0 or AIVehicleExtension.stopWaiting( veh, angle ) then
			veh.acTurnStage   = veh.acTurnStage + 1;					
		end

--==============================================================				
-- turn 45°
	elseif veh.acTurnStage == 43 then		
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
		
		if turnAngle > 45-angleOffset then
			if veh.acParameters.leftAreaActive then
				AIVehicle.aiRotateLeft(veh);
			else
				AIVehicle.aiRotateRight(veh);
			end
			veh.acTurnStage     = veh.acTurnStage + 1;					
			veh.turnTimer       = veh.acDeltaTimeoutNoTurn;
		end
--==============================================================				
-- wait
	elseif veh.acTurnStage == 44 then
		allowedToDrive = false;						
		angle = AIVehicleExtension.getMaxAngleWithTool( veh )
		
		if veh.turnTimer < 0 or AIVehicleExtension.stopWaiting( veh, angle ) then
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutStop;
		end

--==============================================================				
-- move backwards (90°)	I	
	elseif veh.acTurnStage == 45 then		
		moveForwards = false;					
		angle = AIVehicleExtension.getMaxAngleWithTool( veh )
		
		if turnAngle > 90-angleOffset then
			veh.acTurnStage     = veh.acTurnStage + 1;					
			angle = math.min( math.max( 3 * math.rad( 90 - turnAngle ), -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle )
			veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
		end
--==============================================================				
-- move backwards (0°) II
	elseif veh.acTurnStage == 46 then		
		moveForwards = false;					
		angle = math.min( math.max( 3 * math.rad( 90 - turnAngle ), -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle )
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if not veh.acParameters.leftAreaActive then x = -x end
	
		--if veh.isRealistic then
		--	x = x - 1
		--else	
		--	x = x - 0.5
		--end
		
		if x > - stoppingDist then
			veh.acTurnStage   = veh.acTurnStage + 1;					
			angle = veh.acDimensions.maxSteeringAngle;
			veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
		end
--==============================================================				
-- move backwards (45°) III
	elseif veh.acTurnStage == 47 then		
		moveForwards = false;					
		angle = AIVehicleExtension.getMaxAngleWithTool( veh )
		
		if turnAngle > 150-angleOffset then
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutRun;
		end
--==============================================================				
-- wait
	elseif veh.acTurnStage == 48 then
		allowedToDrive = false;						
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, false )
		
		if veh.turnTimer < 0 or AIVehicleExtension.stopWaiting( veh, angle ) then
			AIVehicleExtension.setAIImplementsMoveDown(veh,true);
			AutoSteeringEngine.navigateToSavePoint( veh, 1 )
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutStop;
		end

--==============================================================				
-- turn 90° II
	elseif veh.acTurnStage == 49 then
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
 
		detected, angle2, border = AIVehicleExtension.detectAngle( veh )
 
		if detected then
			AIVehicleExtension.setAIImplementsMoveDown(veh,true);
			if fruitsDetected or z < AutoSteeringEngine.getToolDistance( veh ) then
				veh.acTurnStage = -2
				veh.turnTimer   = veh.acDeltaTimeoutNoTurn;
			end
		elseif fruitsDetected then
			veh.acTurnStage = 110
			veh.turnTimer   = veh.acDeltaTimeoutNoTurn
		else
			veh.turnTimer   = veh.acDeltaTimeoutNoTurn;
			angle            = nil
		--local turn75     = AutoSteeringEngine.getMaxSteeringAngle75( veh );
			local onTrack    = false
		--angle2, onTrack  = AutoSteeringEngine.navigateToSavePoint( veh, 1, nil, turn75 )
			angle2, onTrack  = AutoSteeringEngine.navigateToSavePoint( veh, 1 )
			if not onTrack then
				veh.acTurnStage = 110
				veh.turnTimer   = veh.acDeltaTimeoutNoTurn
			end
		end
		
		
		
		
--==============================================================				
--==============================================================				
-- 180° turn with 90° backwards
--elseif veh.acTurnStage == 50 then
--	allowedToDrive = false;				
--	moveForwards = false;					
--	angle = 0
--	
--	--if veh.turnTimer < 0 then
--		AIVehicleExtension.setAIImplementsMoveDown(veh,false);
--		veh.acTurnStage   = veh.acTurnStage + 1;					
--	--end
--==============================================================				
-- move far enough if tool is in front
	elseif veh.acTurnStage == 50 then
		AIVehicleExtension.setAIImplementsMoveDown(veh,false);
		angle = 0;

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );		
		local dist = math.max( 0, veh.acDimensions.toolDistance )
		
		if z > dist - stoppingDist then
			veh.acTurnStage   = veh.acTurnStage + 1;					
		end

--==============================================================				
-- turn 45°
	elseif veh.acTurnStage == 51 then
		angle = -veh.acDimensions.maxSteeringAngle;
		moveForwards = false;					
		
		if turnAngle < -60+angleOffset then
			AutoSteeringEngine.ensureToolIsLowered( veh, false )
			if veh.acParameters.leftAreaActive then
				AIVehicle.aiRotateLeft(veh);
			else
				AIVehicle.aiRotateRight(veh);
			end
			veh.acTurnStage     = veh.acTurnStage + 1;					
			veh.turnTimer       = veh.acDeltaTimeoutNoTurn;
		end
--==============================================================				
-- wait
	elseif veh.acTurnStage == 52 then
		allowedToDrive = false;						
		angle = veh.acDimensions.maxSteeringAngle;
		
		if veh.turnTimer < 0 or AIVehicleExtension.stopWaiting( veh, angle ) then
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutStop;
		end

--==============================================================				
-- move backwards (90°)	I	
	elseif veh.acTurnStage == 53 then		
		angle = veh.acDimensions.maxSteeringAngle;
		
		if turnAngle < -90+angleOffset then			
			angle                = math.min( math.max( 3 * math.rad( turnAngle + 90 ), -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle )
			veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
			veh.acTurnStage     = veh.acTurnStage + 1;					
		end
--==============================================================				
-- move backwards (0°) II
	elseif veh.acTurnStage == 54 then		
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if not veh.acParameters.leftAreaActive then x = -x end

		angle = math.min( math.max( 3 * math.rad( turnAngle + 90 ), -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle )
		
	--if x > - stoppingDist then
		if x > 0 then
			angle                = veh.acDimensions.maxSteeringAngle;
			veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
			veh.acTurnStage     = veh.acTurnStage + 1;					
		end
--==============================================================				
-- move backwards (90°) III
	elseif veh.acTurnStage == 55 then		
		angle = veh.acDimensions.maxSteeringAngle;
		
		if turnAngle < -120+angleOffset then
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutRun;
		end
--==============================================================				
-- wait
	elseif veh.acTurnStage == 56 then
		allowedToDrive = false;						
		moveForwards = false;					
		angle = -veh.acDimensions.maxSteeringAngle;
		
		if veh.turnTimer < 0 or AIVehicleExtension.stopWaiting( veh, angle ) then
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutStop;
			veh.acMinDetected = nil
		end

--==============================================================				
-- move backwards (90°)	I	
	elseif veh.acTurnStage == 57 then		
		angle = -veh.acDimensions.maxSteeringAngle;
		moveForwards = false;					

		if turnAngle > 0 or turnAngle < -180+angleOffset then
			angle                = 0
			veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
			veh.acTurnStage     = veh.acTurnStage + 1;					
		end
		
--==============================================================				
-- move backwards (90°)	II	
	elseif veh.acTurnStage == 58 then		
		moveForwards = false;					
	
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if not veh.acParameters.leftAreaActive then x = -x end
		
		if fruitsDetected then
			detected = false
			angle    = 0
			angle2   = nil
		else
			detected, angle2, border = AIVehicleExtension.detectAngle( veh )
						
			if detected then
				angle  = nil
				angle2 = -angle2
			else
				angle  = 0
				angle2 = nil
			end
		end
		
		if not detected then
			veh.acMinDetected = nil
		end
		
		if z > veh.acDimensions.toolDistance - stoppingDist then	
			if z > veh.acDimensions.toolDistance + 10 then	
				AIVehicleExtension.setAIImplementsMoveDown(veh,true);
				veh.acTurnStage   = veh.acTurnStage + 1;					
				veh.turnTimer     = veh.acDeltaTimeoutRun;
			elseif detected then
				if veh.acMinDetected == nil then
					veh.acMinDetected = z + 1
				elseif z > veh.acMinDetected then
					AIVehicleExtension.setAIImplementsMoveDown(veh,true);
					veh.acTurnStage   = veh.acTurnStage + 1;					
					veh.turnTimer     = veh.acDeltaTimeoutRun;
					veh.acMinDetected = nil
				end
			end
		end

--==============================================================				
-- wait
	elseif veh.acTurnStage == 59 then
		allowedToDrive = false;						
		angle = 0
		
		if veh.turnTimer < 0 or AIVehicleExtension.stopWaiting( veh, angle ) then
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutRun;
			AutoSteeringEngine.navigateToSavePoint( veh, 1 )
		end

		--==============================================================				
-- turn 90° II
	elseif veh.acTurnStage == 60 
			or veh.acTurnStage == 61 then
			
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );

		detected, angle2, border = AIVehicleExtension.detectAngle( veh )
		
		if detected then
			if veh.acTurnStage == 60 then
				AIVehicleExtension.setAIImplementsMoveDown(veh,true);
				veh.turnTimer   = veh.acDeltaTimeoutRun;
				veh.acTurnStage = 61			
			end
				
		--if     fruitsDetected 
		--		or ( z < AutoSteeringEngine.getToolDistance( veh )
		--		 and veh.acTurnStage == 61
		--		 and veh.turnTimer   <  0 ) then
			if     fruitsDetected 
					or z < AutoSteeringEngine.getToolDistance( veh ) then
				veh.acTurnStage = -2
				veh.turnTimer   = veh.acDeltaTimeoutNoTurn;
			end
		elseif fruitsDetected then
			veh.acTurnStage = 110
			veh.turnTimer   = veh.acDeltaTimeoutNoTurn
		else
			veh.acTurnStage = 60
			angle            = nil
			local onTrack    = false
			angle2, onTrack  = AutoSteeringEngine.navigateToSavePoint( veh, 1 )
			if not onTrack and veh.turnTimer < 0 then
				veh.acTurnStage = 110
				veh.turnTimer   = veh.acDeltaTimeoutNoTurn
			end
		end
		
		
--==============================================================				
--==============================================================				
-- the new U-turn w/o reverse
	elseif veh.acTurnStage == 70 then
		angle = 0;
		
		veh.acTurnStage   = veh.acTurnStage + 1;					
		veh.turnTimer     = veh.acDeltaTimeoutRun;

		AIVehicleExtension.setAIImplementsMoveDown(veh,false);
--==============================================================				
-- move far enough
	elseif veh.acTurnStage == 71 then

		local dist = math.max( 1, veh.acDimensions.toolDistance )
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if veh.acParameters.leftAreaActive then x = -x end
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
		
		if turnAngle < 90 - angleOffset then
			angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
		else
			angle = 0
		end
		
		local corr     = veh.acDimensions.radius * ( 1 - math.cos( math.rad(turnAngle)))
		local dx       = x - 2 * turn75.radius
		if turnAngle > 0 then
			dx = math.min(0,dx + corr)
		else
			dx = math.min(0,dx - corr)
		end		
		
		AIVehicleExtension.debugPrint( veh, string.format("T71: x: %0.3fm z: %0.3fm dx: %0.3fm (%0.3fm %0.1f° %0.3fm %0.3fm)",x, z, dx, veh.acDimensions.radius, turnAngle, turn75.radius, turn75.radiusT ) )		
		
		if dx > - stoppingDist then
			AutoSteeringEngine.ensureToolIsLowered( veh, false )
		--if turnAngle < angleOffset and x < Utils.getNoNil( veh.aseActiveX, 0 ) then
			if turnAngle < angleOffset then
				veh.acTurnStage     = veh.acTurnStage + 2;					
				veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
				angle                = turn75.alpha --AIVehicleExtension.getMaxAngleWithTool( veh, false )
			else
				veh.acTurnStage     = veh.acTurnStage + 1;					
				veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
				angle                = AIVehicleExtension.getMaxAngleWithTool( veh, false )
			end
		end
	
--==============================================================				
-- move far enough II
	elseif veh.acTurnStage == 72 then

		angle = AIVehicleExtension.getMaxAngleWithTool( veh, false )
		
		if turnAngle < angleOffset then
			veh.acTurnStage     = veh.acTurnStage + 1;					
			veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
			local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
			angle                = turn75.alpha 
		end
	
--==============================================================				
-- now turn 90°
	elseif veh.acTurnStage == 73 then	

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if veh.acParameters.leftAreaActive then x = -x end
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
				
		angle = turn75.alpha --AIVehicleExtension.getMaxAngleWithTool( veh, false )
		
		if turnAngle < angleOffset-90 then
			if veh.acParameters.leftAreaActive then
				AIVehicle.aiRotateLeft(veh);
			else
				AIVehicle.aiRotateRight(veh);
			end
			
			if x < turn75.radius + 0.5 then
				veh.acTurnStage = veh.acTurnStage + 2;					
			else
				veh.acTurnStage     = veh.acTurnStage + 1;					
			--veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
				angle                = 0
			end
		end

--==============================================================				
-- check distance
	elseif veh.acTurnStage == 74 then	
		angle = 0

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if veh.acParameters.leftAreaActive then x = -x end
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
	
		if x < turn75.radius - 0.5 then
			veh.acTargetValue   = nil
			veh.acTurnStage     = veh.acTurnStage + 1;					
		--veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
			angle                = turn75.alpha
		elseif x < turn75.radius then
			angle = 2 * ( turn75.radius - x ) * turn75.alpha
		end
		
--==============================================================				
-- now turn again 90°
	elseif veh.acTurnStage == 75 then	

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if veh.acParameters.leftAreaActive then x = -x end
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );

		angle = turn75.alpha

		if turnAngle < angleOffset - 180 or turnAngle > 0 then
			--AIVehicleExtension.debugPrint( veh, tostring(veh.acTurnStage).." "..tostring(turnAngle).." "..tostring(x))
			if x > -stoppingDist then
				AIVehicleExtension.setAIImplementsMoveDown(veh,true);
				AutoSteeringEngine.setPloughTransport( veh, false )
				veh.acTurnStage     = veh.acTurnStage + 4;					
				veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
				angle                = 0
			else
				veh.acTurnStage     = veh.acTurnStage + 1;					
			--veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
				angle                = turn75.alpha --AIVehicleExtension.getMaxAngleWithTool( veh, false )
			end
		end
				
--==============================================================				
-- now turn til endAngle
	elseif veh.acTurnStage == 76 then	

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if veh.acParameters.leftAreaActive then x = -x end
		x = x + stoppingDist
		
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
		angle = turn75.alpha
		
		local beta      = math.rad( 180 - turnAngle )		
		local endAngle1 = math.acos(math.min(math.max(  1 + ( x + turn75.radius * ( 1 - math.cos( beta ))) /( veh.acDimensions.radius + turn75.radius ), 0), 1))
		local endAngle2 = math.asin(math.min(math.max( z / ( veh.acDimensions.radius + turn75.radius ), -1 ), 1 ))			
		local endAngle  = math.min( endAngle1, endAngle2 )
		--AIVehicleExtension.debugPrint( veh, tostring(veh.acTurnStage)..": "..tostring(turnAngle).." "..tostring(x).." "..tostring(z).." "..tostring(math.deg(endAngle1)).." "..tostring(math.deg(endAngle2)))
		
		if 0 < turnAngle and turnAngle <= 180 - math.deg( endAngle ) + angleOffset then
			veh.acTurnStage     = veh.acTurnStage + 1;					
			veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
			angle                = -veh.acDimensions.maxSteeringAngle
		end
				
--==============================================================				
-- now turn to angle 180°
	elseif veh.acTurnStage == 77 or veh.acTurnStage == 78 then	
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if veh.acParameters.leftAreaActive then x = -x end

		if allowedToDrive then
			if math.abs(x) > 0.2 and math.abs(z) > 0.2 and angleOffset < turnAngle and turnAngle < 180 - angleOffset then
				local r = x / ( 1 - math.cos( math.rad(180-turnAngle) ) )
				angle = math.atan( veh.acDimensions.wheelBase / r )
			else
				angle = -veh.acDimensions.maxSteeringAngle
			end
			
			local nextTS = false
			if math.abs(x) <= 0.2 or math.abs(z) <= 0.2 or turnAngle < 0 or turnAngle >= 180 - angleOffset then
				nextTS = true
			elseif veh.acTurnStage == 78 and turnAngle >= 160 then --180 - math.deg( angleMax ) then
				nextTS = true
			end
			
			if veh.acTurnStage == 77 then
				if     noReverseIndex <= 0
						or math.abs( math.deg(AutoSteeringEngine.getToolAngle( veh )) ) < 60 
						or nextTS then
					AIVehicleExtension.setAIImplementsMoveDown(veh,true);
					AutoSteeringEngine.setPloughTransport( veh, false )
					veh.acTurnStage     = veh.acTurnStage + 1;					
				end
			end

			if nextTS then 
				veh.acTurnStage     = veh.acTurnStage + 1;					
				veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
				angle                = -veh.acDimensions.maxSteeringAngle
				AutoSteeringEngine.navigateToSavePoint( veh, 3 )
			end
		end
				
--==============================================================				
-- end sequence
	elseif veh.acTurnStage == 79 then	
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		if veh.acParameters.leftAreaActive then x = -x end
		
		if allowedToDrive then
			angle  = nil
			
			if     fruitsDetected
					or ( math.abs( turnAngle ) >= 170 
					 and math.abs( AutoSteeringEngine.getToolAngle( veh ) ) <= AIVEGlobals.maxToolAngle2 ) then
				detected, angle2, border = AIVehicleExtension.detectAngle( veh, -1 )
			else
				detected = false
			end
			
			--AIVehicleExtension.debugPrint( veh, tostring(veh.acTurnStage)..": "..tostring(turnAngle).." "..tostring(x).." "..tostring(z).." "..tostring(detected))
			
			if detected then			
				veh.acTurnStage   = -2
				veh.turnTimer     = veh.acDeltaTimeoutNoTurn;
				AIVehicleExtension.setAIImplementsMoveDown(veh,true);
			elseif not detected then					
				angle2 = AutoSteeringEngine.navigateToSavePoint( veh, 3, AIVehicleExtension.navigationFallbackRetry )
			else
				AIVehicleExtension.setAIImplementsMoveDown(veh,true);
			end
		else
			angle = 0
		end
		
--==============================================================				
--==============================================================				
-- U-turn with 8-shape
	elseif veh.acTurnStage == 80 then	
		veh.acTurnStage   = veh.acTurnStage + 1;					
		veh.turnTimer     = veh.acDeltaTimeoutRun;
		angle              = AIVehicleExtension.getMaxAngleWithTool( veh, false )

		AIVehicleExtension.setAIImplementsMoveDown(veh,false);
		
--==============================================================				
-- turn inside
	elseif veh.acTurnStage == 81 then	
		angle              = AIVehicleExtension.getMaxAngleWithTool( veh, false )

		if turnAngle < -150 + angleOffset then
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutRun;
		end
		
--==============================================================		
-- rotate plough		
	elseif veh.acTurnStage == 82 then	
		angle                = AIVehicleExtension.getMaxAngleWithTool( veh, true )
		
		if 		 turnAngle > -90 - angleOffset - angleOffset
				or math.abs( AutoSteeringEngine.getToolAngle( veh ) ) <= AIVEGlobals.maxToolAngle2 then
			veh.acTurnStage     = veh.acTurnStage + 1;					
			if veh.acParameters.leftAreaActive then
				AIVehicle.aiRotateLeft(veh);
			else
				AIVehicle.aiRotateRight(veh);
			end
		end

--==============================================================				
-- turn outside I
	elseif veh.acTurnStage == 83 then	
		angle              = AIVehicleExtension.getMaxAngleWithTool( veh, true )			

		if turnAngle > -90 - angleOffset then
			local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
			local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
			if math.abs(x) > veh.acDimensions.distance - turn75.radius - stoppingDist then
			--veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
				angle                = 90 + turnAngle
				veh.acTurnStage     = veh.acTurnStage + 1;					
				veh.turnTimer       = veh.acDeltaTimeoutRun;
			else
				veh.acTurnStage   = veh.acTurnStage + 2
				veh.turnTimer     = veh.acDeltaTimeoutRun;
			end
			AutoSteeringEngine.setPloughTransport( veh, false )
		end

--==============================================================				
-- move far enough
	elseif veh.acTurnStage == 84 then	
		angle = 90 + turnAngle

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
		if math.abs(x) > veh.acDimensions.distance - turn75.radius + stoppingDist then
		--veh.waitForTurnTime = veh.acDeltaTimeoutRun + g_currentMission.time
			angle                = AIVehicleExtension.getMaxAngleWithTool( veh, true )		
			veh.acTurnStage     = veh.acTurnStage + 1;					
			veh.turnTimer       = veh.acDeltaTimeoutRun;
		end
		
--==============================================================				
-- turn outside II
	elseif veh.acTurnStage == 85 then	
		angle              = AIVehicleExtension.getMaxAngleWithTool( veh, true )			

		if turnAngle > 90 then
			veh.acTurnStage     = veh.acTurnStage + 1					
			veh.turnTimer       = veh.acDeltaTimeoutRun
		end

--==============================================================				
-- turn 90°
	elseif veh.acTurnStage == 86 then
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true );
		
		detected  = false
		local nav = true
		if     fruitsDetected
				or ( math.abs( turnAngle ) >= 170 
				 and math.abs( AutoSteeringEngine.getToolAngle( veh ) ) <= AIVEGlobals.maxToolAngle2 ) then
	--if math.abs( turnAngle ) >= 180-math.deg( angleMax ) then
			nav = false
			detected, angle2, border = AIVehicleExtension.detectAngle( veh )
		end		
		
		AIVehicleExtension.debugPrint( veh, string.format("T84: x: %0.3fm z: %0.3fm test: %0.3fm fd: %s det: %s ta: %0.1f° to: %0.1f°", x, z, AutoSteeringEngine.getToolDistance( veh ), tostring(fruitsDetected), tostring(detected), turnAngle, math.deg(AutoSteeringEngine.getToolAngle( veh )) ) )
		
		if detected then
			veh.acTurnStage   = -2
			veh.turnTimer     = veh.acDeltaTimeoutNoTurn;
			AIVehicleExtension.setAIImplementsMoveDown(veh,true);
		elseif nav or z < math.min( 0, AutoSteeringEngine.getToolDistance( veh ) ) - 5 then
			veh.turnTimer     = veh.acDeltaTimeoutNoTurn;
			angle  = nil
			angle2 = AutoSteeringEngine.navigateToSavePoint( veh, 3, AIVehicleExtension.navigationFallbackRetry )
		end
			
--==============================================================				
--==============================================================				
-- 90° new turn with reverse
	elseif veh.acTurnStage == 90 then
		veh.acTurnStage   = veh.acTurnStage + 1;					
		veh.turnTimer     = veh.acDeltaTimeoutRun;
		angle              = AIVehicleExtension.getMaxAngleWithTool( veh, false )

		AIVehicleExtension.setAIImplementsMoveDown(veh,false);
		
--==============================================================				
-- reduce tool angle 
	elseif veh.acTurnStage == 91 then
		
		local toolAngle = AutoSteeringEngine.getToolAngle( veh )
		
		angle  = nil;		
		angle2 = math.min( math.max( -toolAngle, -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle );
		
		if math.abs(math.deg(toolAngle)) < 5 then
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutRun;
		end
		
--==============================================================				
-- move backwards (straight)		
	elseif veh.acTurnStage == 92 then		
		moveForwards = false;					
		--angle  = nil;
		--local toolAngle = AutoSteeringEngine.getToolAngle( veh );
		--angle2 = math.min( math.max( toolAngle, -veh.acDimensions.maxSteeringAngle ), veh.acDimensions.maxSteeringAngle );
		angle  = AIVehicleExtension.getStraighBackwardsAngle( veh, 0 )

		local _,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh );
		
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
		local dist   = math.max( turn75.radius + 2, 1.15 * turn75.radius )
		if -z > dist then				
	--if z < -veh.acDimensions.radius then				
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutRun;
			veh.waitForTurnTime = g_currentMission.time + veh.turnTimer;
			angle = 0
		end

--==============================================================				
-- turn 90°
	elseif veh.acTurnStage == 93 then		
	--angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
	--
		local onTrack 
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );

		angle2, onTrack = AutoSteeringEngine.navigateToSavePoint( veh, 2, nil, turn75 )		
		
		local ta = AIVehicleExtension.getToolAngle( veh )
		
		veh:acDebugPrint("T93: "..degToString( turnAngle ).." "..radToString(ta))
		
		if     turnAngle > 90 - angleOffsetStrict + math.deg( ta ) then
			if math.abs( ta ) < AIVEGlobals.maxToolAngleF * veh.acDimensions.maxSteeringAngle then
				veh.acTurnStage = veh.acTurnStage + 4
				veh.turnTimer   = veh.acDeltaTimeoutRun;
			else 
				veh.acTurnStage = veh.acTurnStage + 1
				veh.turnTimer   = veh.acDeltaTimeoutRun;
			end
		elseif onTrack then
			angle  = nil
		else
			veh.acTurnStage = veh.acTurnStage + 2
			veh.turnTimer   = veh.acDeltaTimeoutRun;
		end
		
--==============================================================				
-- turn 90° II
	elseif veh.acTurnStage == 94 then		
	--angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
	--
		local onTrack 
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );

		angle2, onTrack = AutoSteeringEngine.navigateToSavePoint( veh, 2, nil, turn75 )		

		local ta = AIVehicleExtension.getToolAngle( veh )
		veh:acDebugPrint("T94: "..degToString( turnAngle ).." "..radToString(ta))		
		
		
		if      math.abs( turnAngle - 90 - math.deg( ta ) ) < angleOffsetStrict
				and math.abs( turnAngle - 90 )                  < angleOffset       then
			if math.abs( ta ) < AIVEGlobals.maxToolAngleF * veh.acDimensions.maxSteeringAngle then
				veh.acTurnStage = veh.acTurnStage + 3
				veh.turnTimer   = veh.acDeltaTimeoutRun;
			else
				veh.acTurnStage = veh.acTurnStage + 1
				veh.turnTimer   = veh.acDeltaTimeoutRun;
			end
		elseif onTrack then
			angle  = nil
		else
			veh.acTurnStage = veh.acTurnStage + 1
			veh.turnTimer   = veh.acDeltaTimeoutRun;
		end
		
--==============================================================				
-- reduce tool angle I
	elseif veh.acTurnStage == 95 then
		
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( veh );
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh );
		if veh.acParameters.leftAreaActive then x = -x end
		
	--angle = -turn75.alpha
		angle = -0.3333 * turn75.alpha
		
		veh:acDebugPrint("T95: "..radToString( angle ).." "..degToString( turnAngle ).." "..tostring(x).." / "..tostring(z).." "..radToString( math.atan2( z, x )))

		if turnAngle > 90 - angleOffsetStrict + 0.5 * math.deg( math.abs( AIVehicleExtension.getToolAngle( veh ) ) ) then
			veh.acTurnStage = veh.acTurnStage + 1				
			veh.turnTimer   = veh.acDeltaTimeoutStop;
		end
		
--==============================================================				
-- reduce tool angle II
	elseif veh.acTurnStage == 96 then
		
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh );
		if veh.acParameters.leftAreaActive then x = -x end		
		local target = 90 -- + angleOffset
		if x > 1 then
			target = target + math.deg( math.atan2( z, x ) )
		end
		
		local newTurnAngle = turnAngle - target 
		local f = 1
		if veh.articulatedAxis == nil then
			f = 2
		end

		local ta = AIVehicleExtension.getToolAngle( veh )
		
		angle = Utils.clamp( f * ( math.rad( newTurnAngle ) - math.min( 0, ta ) ), AIVehicleExtension.getMaxAngleWithTool( veh, true ), AIVehicleExtension.getMaxAngleWithTool( veh, false ) )

		veh:acDebugPrint("T96: "..radToString( angle ).." "..radToString( ta ).." "..degToString( turnAngle ).." "..degToString( newTurnAngle ).." "..tostring(x).." / "..tostring(z).." "..radToString( math.atan2( z, x )))
		
		if      math.abs( newTurnAngle + math.deg( ta ) ) < angleOffsetStrict
				and math.abs( ta ) < AIVEGlobals.maxToolAngleF * veh.acDimensions.maxSteeringAngle then
			veh.acTurnStage = veh.acTurnStage + 1;					
			veh.turnTimer   = veh.acDeltaTimeoutRun;
			angle            = 0
		elseif x > 20 then
			veh.acTurnStage = veh.acTurnStage + 1;					
			veh.turnTimer   = veh.acDeltaTimeoutRun;
			angle            = 0
		end
		
--==============================================================				
-- get tool angle over 90
	elseif veh.acTurnStage == 97 then		
		angle    = math.min( -0.1 * veh.acDimensions.maxSteeringAngle, math.rad( turnAngle - 90 ) )
		if turnAngle >= 90 + math.deg( AIVehicleExtension.getToolAngle( veh ) ) + angleOffsetStrict then
			veh.acTurnStage = veh.acTurnStage + 1;					
			veh.turnTimer   = veh.acDeltaTimeoutRun;
			angle            = 0
		end
		
--==============================================================				
-- get turn angle to exactly 90°
	elseif veh.acTurnStage == 98 then		
		local newTurnAngle = turnAngle - 90 
		angle = math.rad( newTurnAngle )
		if math.abs( newTurnAngle ) < angleOffsetStrict then
			veh.acTurnStage = veh.acTurnStage + 1;					
			veh.turnTimer   = veh.acDeltaTimeoutRun;
			angle            = 0
			veh.waitForTurnTime = g_currentMission.time + veh.turnTimer;
		end
		
--==============================================================				
-- move backwards (straight)		
	elseif veh.acTurnStage == 99 then		
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
		detected, a2, border = AIVehicleExtension.detectAngle( veh, AIVEGlobals.smoothMax )
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
			target = Utils.clamp( 90 - math.deg( t+t+t ), minTarget, maxTarget )		
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
		
		veh:acDebugPrint( "T97: "..degToString( turnAngle ).." "..radToString( ta ).." "..radToString( a2 ).." "..degToString( target ).." "..string.format("%2.3fm %2.3fm / %2.3fm", x, z, -veh.acDimensions.toolDistance) )
		
		if      x < -veh.acDimensions.toolDistance 
				and ( detected or x < -15 ) 
			--and a2 <= 0
			--and turnAngle <= 90
				and not fruitsDetected then				
			if veh.turnTimer < 0 then
				veh.acTurnStage = -1
				veh.waitForTurnTime = g_currentMission.time + veh.turnTimer;
				angle = a2
			end
		else
			veh.turnTimer = veh.acDeltaTimeoutRun
		end

--==============================================================				
--==============================================================				
-- going back w/o reverse
	elseif veh.acTurnStage == 100 then
		veh.acTurnStage   = veh.acTurnStage + 1;					
		veh.turnTimer     = veh.acDeltaTimeoutRun;
		angle              = AIVehicleExtension.getMaxAngleWithTool( veh, false )

		AIVehicleExtension.setAIImplementsMoveDown(veh,false,true);
	
--==============================================================				
-- turn 180° I
	elseif veh.acTurnStage == 101 then
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
			
		if math.abs( turnAngle ) > 180 - angleOffset then
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutRun;
			angle              = 0
		end

--==============================================================				
-- turn 180° I
	elseif veh.acTurnStage == 102 then
		angle = 0

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh );
		if z < -5 then
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutRun;
			angle              = AIVehicleExtension.getMaxAngleWithTool( veh, true )
		end
		
--==============================================================				
-- turn 180° II
	elseif veh.acTurnStage == 103 then
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
			
		if math.abs( turnAngle ) < angleOffset then
			veh.acTurnStage   = -1				
			veh.turnTimer     = veh.acDeltaTimeoutRun;
			angle              = 0
		end

	
--==============================================================				
--==============================================================				
-- going back w/o reverse at the end of a turn
	elseif veh.acTurnStage == 105 then
		veh.acTurnStage   = veh.acTurnStage + 1;					
		veh.turnTimer     = veh.acDeltaTimeoutRun;
		angle              = AIVehicleExtension.getMaxAngleWithTool( veh, false )

		AIVehicleExtension.setAIImplementsMoveDown(veh,false,true);
	
--==============================================================				
-- turn 180° I
	elseif veh.acTurnStage == 106 then
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
			
		if math.abs( turnAngle ) < angleOffset then
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutRun;
			angle              = 0
		end

--==============================================================				
-- turn 180° I
	elseif veh.acTurnStage == 107 then
		angle = 0

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh );
		if z > 5 then
			veh.acTurnStage   = veh.acTurnStage + 1;					
			veh.turnTimer     = veh.acDeltaTimeoutRun;
			angle              = AIVehicleExtension.getMaxAngleWithTool( veh, true )
		end
		
--==============================================================				
-- turn 180° II
	elseif veh.acTurnStage == 108 then
		angle = AIVehicleExtension.getMaxAngleWithTool( veh, true )
			
		if math.abs( turnAngle ) > 180 - angleOffset then
			veh.acTurnStage   = -1				
			veh.turnTimer     = veh.acDeltaTimeoutRun;
			angle              = 0
		end

	
--==============================================================				
--==============================================================				
-- forward and reduce tool angle
	elseif  110 <= veh.acTurnStage and veh.acTurnStage < 125 then
		local turnStageMod = ( veh.acTurnStage - 110 ) % 5
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( veh, true, veh.acTurnStage >= 120 );
		if veh.acParameters.leftAreaActive then x = -x end

		local turnMode, targetS, targetA, targetT
			
		if     veh.acTurnStage < 115 then
			turnMode = 3
			targetS  = x
			targetT  = 180
		elseif veh.acTurnStage < 120 then
			turnMode = 4
			targetS  = z
			targetT  = 90
		else
			turnMode = 5
			targetS  = -x
			targetT  = 0
		end
		
		targetA  = turnAngle - targetT
				
		if     targetA <= -180 then
			targetA = targetA + 360
		elseif targetA > 180 then
			targetA = targetA - 360
		end
					
--==============================================================				
--==============================================================				
-- forward and reduce tool angle
		if     turnStageMod == 0 then
		
			if veh.turnTimer < 0 then
				AIVehicleExtension.setAIImplementsMoveDown(veh,false,true);
			end
			
			local onTrack  = false
			angle2, onTrack = AutoSteeringEngine.navigateToSavePoint( veh, turnMode )
			
			if      math.abs( targetS ) < 0.5
					and math.abs( targetA ) < angleOffset then
				if math.abs( math.deg( AIVehicleExtension.getToolAngle( veh ) ) ) < angleOffsetStrict then
					veh.acTurnStage = veh.acTurnStage + 2;					
					veh.turnTimer   = veh.acDeltaTimeoutRun;
					angle            = 0
				elseif not onTrack then
					veh.acTurnStage = veh.acTurnStage + 1;					
					veh.turnTimer   = veh.acDeltaTimeoutRun;
					angle            = 0
				end
			elseif not onTrack then		
				angle2  = nil
				local a = 0
				if     math.abs( targetS ) < 0.5 then
					a = math.rad( targetA )
				else
					a = AutoSteeringEngine.normalizeAngle( math.rad( targetA - Utils.clamp( targetS, -3, 3 ) * 15 ) )
				end
				angle = Utils.clamp( a, AIVehicleExtension.getMaxAngleWithTool( veh, true ), AIVehicleExtension.getMaxAngleWithTool( veh, false ) ) 
			end
			
			AIVehicleExtension.debugPrint( veh, tostring(veh.acTurnStage).." "..tostring(onTrack).." "..degToString( targetA ).." "..tostring( targetS ).." "..radToString( angle2 ).." "..radToString( angle ).." "..tostring(x).." "..tostring(z) )
			
	--==============================================================				
	-- forward and reduce tool angle
		elseif turnStageMod == 1 then

			local newTurnAngle = math.rad( targetA )
			
			angle = Utils.clamp( newTurnAngle, AIVehicleExtension.getMaxAngleWithTool( veh, true ), AIVehicleExtension.getMaxAngleWithTool( veh, false ) )

			if      math.abs( math.deg( newTurnAngle ) ) < angleOffset
					and math.abs( math.deg( AIVehicleExtension.getToolAngle( veh ) ) ) < angleOffsetStrict then
				AIVehicleExtension.setAIImplementsMoveDown(veh,false);
				veh.acTurnStage = veh.acTurnStage + 1;					
				veh.turnTimer   = veh.acDeltaTimeoutRun;
				angle            = 0
			end
		
	--==============================================================				
	-- backwards and reduce tool angle
		elseif turnStageMod == 2 then
		
			moveForwards = false
			angle        = AIVehicleExtension.getStraighBackwardsAngle( veh, targetT )
			
			if z < 0 and not fruitsDetected then
				detected = AIVehicleExtension.detectAngle( veh )
				if detected then
					veh.acTurnStage = veh.acTurnStage + 1
					veh.turnTimer   = veh.acDeltaTimeoutRun;
				end
			end
		
	--==============================================================				
	-- backwards and reduce tool angle
		elseif turnStageMod == 3 then

			moveForwards     = false
			angle            = AIVehicleExtension.getStraighBackwardsAngle( veh, targetT )
			detected         = AIVehicleExtension.detectAngle( veh )
			if not detected then
				veh.turnTimer   = veh.acDeltaTimeoutRun;
			elseif veh.turnTimer < 0 then
				veh.acTurnStage = veh.acTurnStage + 1
				veh.turnTimer   = veh.acDeltaTimeoutRun;
			end
		
	--==============================================================				
	-- forward and reduce tool angle
		else --if turnStageMod == 4 then

			moveForwards     = true
			detected, angle2 = AIVehicleExtension.detectAngle( veh )
			if not detected then
				if veh.turnTimer < 0 or fruitsDetected then
					AutoSteeringEngine.shiftTurnVector( veh, 0.5 )
					veh.acTurnStage = veh.acTurnStage - 4
				end
			elseif fruitsDetected then
				if veh.acTurnStage < 115 then
					veh.acTurnStage = -2
				else
					veh.acTurnStage = -1
				end
				veh.turnTimer   = veh.acDeltaTimeoutNoTurn;
				AIVehicleExtension.setAIImplementsMoveDown(veh,true);
			else
				veh.turnTimer   = veh.acDeltaTimeoutRun;
			end
		end

	end
	
	if tX == nil then
			if     angle2 ~= nil then
			elseif veh.acParameters.leftAreaActive then
				angle2 =  angle
			else
				angle2 = -angle
			end
	
		tX,tZ = AutoSteeringEngine.getWorldTargetFromSteeringAngle( vehicle, angle2 )
	end
		
	maxSpeed = AutoSteeringEngine.getMaxSpeed( veh, dt, 1, allowedToDrive, moveForwards, speedLevel, false, 0.7 )
			
	return tX, tZ, moveForwards, maxSpeed, distanceToStop
end