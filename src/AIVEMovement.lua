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

------------------------------------------------------------------------
-- AIVehicleExtension:detectAngle
------------------------------------------------------------------------
function AIVehicleExtension:detectAngle( smooth )
	if self.acHighPrec == nil then
		self.acHighPrec = true
	end
	
	local d, a, b = AutoSteeringEngine.processChain( self, smooth, not ( self.acHighPrec ), ( self.acTurnStage == 0 or self.acTurnStage == 199 ) )

	if      self.acTurnStage == 0 
			and b                <= 0
			and math.abs( a )    <  AIVEGlobals.maxDtAngle * self.acDimensions.maxLookingAngle then
		self.acHighPrec = false --AutoSteeringEngine.getIsAtEnd( self )
	elseif  self.acTurnStage <  0 
			and b                <= 0 then
		self.acHighPrec = false
	else
		self.acHighPrec = true
	end

	local oldFullAngle = self.acFullAngle
	self.acFullAngle = false
	
	if     b > 0 then
		d = false
		self.acFullAngle = true
	elseif self.acTurnStage > 0 then
		self.acFullAngle = true
	elseif oldFullAngle then
		if math.abs( a ) > self.acDimensions.maxLookingAngle then
			self.acFullAngle = true
		end
	end
	
	return d, a, b
end

------------------------------------------------------------------------
-- AIVehicleExtension:getMaxAngleWithTool
------------------------------------------------------------------------
function AIVehicleExtension:getMaxAngleWithTool( outside )
	
	local angle
	local toolAngle = AutoSteeringEngine.getToolAngle( self );	
	if not self.acParameters.leftAreaActive then
		toolAngle = -toolAngle
	end

	if outside then
		angle = -self.acDimensions.maxSteeringAngle + math.min( 2 * math.max( -toolAngle - AIVEGlobals.maxToolAngle, 0 ), 0.9 * self.acDimensions.maxSteeringAngle );	-- 75° => 1,3089969389957471826927680763665
	else
		angle =  self.acDimensions.maxSteeringAngle - math.min( 2 * math.max(  toolAngle - AIVEGlobals.maxToolAngle, 0 ), 0.9 * self.acDimensions.maxSteeringAngle );	-- 75° => 1,3089969389957471826927680763665
	end

	if AIVEGlobals.devFeatures > 0 and math.abs( toolAngle ) >= AIVEGlobals.maxToolAngle - 0.01745 then
		AIVehicleExtension.debugPrint( self, string.format("Tool angle: a: %0.1f° ms: %0.1f° to: %0.1f°", math.deg(angle), math.deg(self.acDimensions.maxSteeringAngle), math.deg(toolAngle) ) )
	end

	
	return angle
end

------------------------------------------------------------------------
-- AIVehicleExtension:waitForAnimTurnStage
------------------------------------------------------------------------
function AIVehicleExtension:waitForAnimTurnStage()
	if     self.acTurnStage <  0
			or ( self.acTurnStage == 0 and AIVEGlobals.raiseNoFruits > 0 )
			or self.acTurnStage == 3
			or self.acTurnStage == 8
			or self.acTurnStage == 26 or self.acTurnStage == 27
			or self.acTurnStage == 38
			or self.acTurnStage == 48 or self.acTurnStage == 49
			or self.acTurnStage == 59 or self.acTurnStage == 60 or self.acTurnStage == 61 
			or self.acTurnStage == 77 or self.acTurnStage == 78 or self.acTurnStage == 79 then
		return true
	end
	return false
end			

------------------------------------------------------------------------
-- AIVehicleExtension:checkCorrectField
------------------------------------------------------------------------
function AIVehicleExtension:checkIsCorrectField()
--local wx,_,wz = localToWorld( self.aseChain.refNode, 0.5 * ( self.aseActiveX + self.aseOtherX ), 0, 0.5 * ( self.aseStart + self.aseDistance ) )
--if self.aseCurrentField ~= nil and not AutoSteeringEngine.checkField( self, wx, wz ) then
--	local checkFunction, areaTotalFunction = AutoSteeringEngine.getCheckFunction( self )
--	if AutoSteeringEngine.checkFieldNoBuffer( wx, wz, checkFunction ) then
--		return false 
--	end
--end
	
	return true
end

------------------------------------------------------------------------
-- AIVehicleExtension:stopWaiting
------------------------------------------------------------------------
function AIVehicleExtension:stopWaiting( angle )
	local a
	if self.acParameters.leftAreaActive then
		a = angle 
	else	 
		a = -angle 
	end
	
	if math.abs( a - AutoSteeringEngine.currentSteeringAngle( self, self.acParameters.inverted ) ) < 0.05236 then -- 3° 
		return true 
	end
	return false
end

------------------------------------------------------------------------
-- AICombine:updateAIMovement
------------------------------------------------------------------------
function AIVehicleExtension:newUpdateAIMovement( dt )
	
	local dt = self.acDtSum

	AIVehicleExtension.statEvent( self, "t0", dt )

	AIVehicleExtension.checkState( self )
	if not AutoSteeringEngine.hasTools( self ) then
		self:stopAIVehicle()
		return;
	end
	
	if      ( self.acTurnStage == 0 
				 or self.acTurnStage == -3 
				 or self.acTurnStage == -13 
				 or self.acTurnStage == -23 )
			and not AIVehicleExtension.checkIsCorrectField( self ) then
		self:stopAIVehicle()
		return;
	end
	
	local allowedToDrive =  AutoSteeringEngine.checkAllowedToDrive( self, not ( self.acParameters.isHired  ) )
	
	if self.acPause then
		allowedToDrive = false
		AIVehicleExtension.setStatus( self, 0 )
	end
	
	self.acNoSneak       = false
	self.acIsAnimPlaying = false
	if AIVehicleExtension.waitForAnimTurnStage( self ) then
		local isPlaying, noSneak = AutoSteeringEngine.checkIsAnimPlaying( self, self.acImplementsMoveDown )
		
		if isPlaying then
			if    self.acAnimWaitTimer == nil then
				self.acAnimWaitTimer = self.acDeltaTimeoutWait
				self.acIsAnimPlaying = true
			elseif self.acAnimWaitTimer > 0 then
				self.acAnimWaitTimer = self.acAnimWaitTimer - dt
				self.acIsAnimPlaying = true
			end
		else
			self.acAnimWaitTimer = nil
			noSneak              = false
		end
		
		if noSneak then
			if    self.acNoSneakTimer == nil then
				self.acNoSneakTimer = self.acDeltaTimeoutWait
				self.acNoSneak = true
			elseif self.acNoSneakTimer > 0 then
				self.acNoSneakTimer = self.acNoSneakTimer - dt
				self.acNoSneak = true
			end
		else
			self.acNoSneakTimer = nil
		end
		
		if      allowedToDrive 
				and self.acNoSneak then
			AIVehicleExtension.setStatus( self, 3 )
			allowedToDrive = false
		end
	else
		self.acAnimWaitTimer = nil
		self.acNoSneakTimer  = nil
	end
	
	for _, v in pairs(self.numCollidingVehicles) do
		if v > 0 then
			AIVehicleExtension.setStatus( self, 3 )
			allowedToDrive = false
			break
		end
	end
	
	if self.waitForTurnTime > g_currentMission.time then
		if self.acLastSteeringAngle ~= nil then
			local a = AutoSteeringEngine.currentSteeringAngle( self, self.acParameters.inverted )
			if math.abs( self.acLastSteeringAngle - a ) < 0.05236 then -- 3°
				self.waitForTurnTime = 0
			end
		end
	end
	
	if self.waitForTurnTime > g_currentMission.time then
		AIVehicleExtension.setStatus( self, 0 )
		if self.acLastSteeringAngle ~= nil then
			AutoSteeringEngine.steer( self, dt, self.acLastSteeringAngle, self.aiSteeringSpeed, false );
		end
		AutoSteeringEngine.drive( self, dt, 0, false, true, 0 );
		return
	end
	
	local speedLevel = 2;
	if self.speed2Level ~= nil and 0 <= self.speed2Level and self.speed2Level <= 4 then
		speedLevel = self.speed2Level;
	end
	-- 20 km/h => lastSpeed = 5.555E-3 => speedLevelFactor = 234 * 5.555E-3 = 1.3
	-- 10 km/h =>                         speedLevelFactor                  = 0.7
	local speedLevelFactor = math.min( self.lastSpeed * 234, 0.5 ) 
	                                                               
	
-- Speed level always 1 while turning	
	if self.acTurnStage ~= 0 and 0 < speedLevel and speedLevel < 4 then
		speedLevel = 1
	end

	if not allowedToDrive or speedLevel == 0 then
		AIVehicleExtension.statEvent( self, "tS", dt )
		self.isHirableBlocked = true		
		AutoSteeringEngine.drive( self, dt, 0, false, true, 0 );
		return
	end
	self.isHirableBlocked = false
	
	self.acLastSteeringAngle = nil

	local moveForwards = true

	local offsetOutside = 0;
	if     self.acParameters.rightAreaActive then
		offsetOutside = -1;
	elseif self.acParameters.leftAreaActive then
		offsetOutside = 1;
	end;
	
	self.turnTimer          = self.turnTimer - dt;
	self.acTurnOutsideTimer = self.acTurnOutsideTimer - dt;

--==============================================================				
	
	if     self.acTurnStage ~= 0 then
		self.aiRescueTimer = self.aiRescueTimer - dt;
	else
		self.aiRescueTimer = math.max( self.aiRescueTimer, self.acDeltaTimeoutStop )
	end
	
	if self.aiRescueTimer < 0 then
		self:stopAIVehicle()
		return
	end
	if self.acTurnStage > 0 and AutoSteeringEngine.getTurnDistanceSq( self ) > AIVEGlobals.aiRescueDistSq then
		self:stopAIVehicle()
		return
	end
		
--==============================================================				
	local angle, angle2;
	local angleMax = self.acDimensions.maxLookingAngle;
	local detected = false;
	local border   = 0;
	local angleFactor;
	local offsetOutside;
	local noReverseIndex = 0;
	local angleOffset = 6;
	local angleOffsetStrict = 4;
	local stoppingDist = 0.5;
	local turn2Outside = self.acTurn2Outside;
--==============================================================		
--==============================================================		
	local turnAngle = math.deg(AutoSteeringEngine.getTurnAngle(self));

	if AIVEGlobals.devFeatures > 0 then
		self.atHud.InfoText = string.format( "Turn stage: %2i, angle: %3i",self.acTurnStage,turnAngle )
	end

	if self.acParameters.leftAreaActive then
		turnAngle = -turnAngle;
	end;

	local fruitsDetected, fruitsAll = AutoSteeringEngine.hasFruits( self, 0.9 )
	
	if fruitsDetected and self.acTurnStage < 0 then
		if self.acFruitAllTimer == nil then
			self.acFruitAllTimer = self.acDeltaTimeoutStart
		elseif self.acFruitAllTimer > 0 then
			self.acFruitAllTimer = self.acFruitAllTimer - dt
		else
			fruitsAll = true
		end
	else
		self.acFruitAllTimer = nil
	end	
	
	noReverseIndex  = AutoSteeringEngine.getNoReverseIndex( self );
	
--==============================================================				
	if self.acTurnStage <= 0 then	
		local smooth       = 0
		
		if  self.acTurnStage < 0 or self.acTraceSmoothOffset == nil or not fruitsDetected then
			self.acTraceSmoothOffset = AutoSteeringEngine.getTraceLength(self) + 1
		elseif AIVEGlobals.smoothFactor > 0 and AIVEGlobals.smoothMax > 0 and AutoSteeringEngine.getTraceLength(self) > 3 then --and fruitsDetected then
			smooth = Utils.clamp( AIVEGlobals.smoothFactor * ( AutoSteeringEngine.getTraceLength(self) - self.acTraceSmoothOffset ), 0, AIVEGlobals.smoothMax ) * Utils.clamp( speedLevelFactor, 0.7, 1.3 ) 
		end

		detected, angle2, border = AIVehicleExtension.detectAngle( self, smooth, self.acTurnStage == -13 )
		
		if AIVEGlobals.devFeatures > 0 and self.acTurnStage == -13 then
			AIVehicleExtension.debugPrint( self, tostring(fruitsDetected).." "..tostring(fruitsAll).." "..tostring(self.acFruitAllTimer).." "..tostring(detected).." "..tostring(border))
		end		
			
		if border > 0 then
			turn2Outside = true
			speedLevel = 4
			if AutoSteeringEngine.hasLeftFruits( self ) then
				detected = false
			else
				detected = true
			end
		else
			turn2Outside           = false
			self.acTurnInTheMiddle = nil
		end		
		
				
		if      self.acTurnStage            == 0 
				and AutoSteeringEngine.getIsAtEnd( self ) 
				and AutoSteeringEngine.getTraceLength(self) > 5 then
			
			speedLevel = 4
			
			local ta = math.min( math.max( math.rad( 0.5 * turnAngle ), -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle )
			
			if noReverseIndex <= 0 then
				ta = 0
			end
			
			if self.acParameters.leftAreaActive then
				angle = angle2 
			else
				angle = -angle2		
			end	
			angle   = math.max( angle, ta )
			
			AIVehicleExtension.debugPrint( self, radToString(angle2).." => "..radToString(angle).." ("..tostring(self.acParameters.leftAreaActive)..")")
			
			angle2    = nil
		elseif  detected then
		-- everything is ok
		elseif  self.acTurnStage == -3 or self.acTurnStage == -13 or self.acTurnStage == -23 then
		-- start of hired worker
			if turn2Outside then
				angle =  self.acDimensions.maxSteeringAngle
			else
				angle = 0
			end
		elseif  turn2Outside
				and self.acTurnStage < 0
				and fruitsDetected then
		-- retry after failed turn
			if     self.acTurnMode == "C" 
					or self.acTurnMode == "8" 
					or self.acTurnMode == "O" then
				if self.acTurnStage == -2 or self.acTurnStage == -12 or self.acTurnStage == -22 then
					AutoSteeringEngine.shiftTurnVector( self, 0.5 )
					self.acTurnStage = 105
				end
			else
				if self.acTurnStage == -2 or self.acTurnStage == -12 or self.acTurnStage == -22 then
					AutoSteeringEngine.shiftTurnVector( self, 0.5 )
					self.acTurnStage = 110
				else
					AutoSteeringEngine.shiftTurnVector( self, 0.5 )
					self.acTurnStage = 115
				end
			end
			self.turnTimer = self.acDeltaTimeoutWait;
		
		else
		-- we are still ahead of the field
			self.acTraceSmoothOffset = nil
			
			if     self.acTurnStage == -2 or self.acTurnStage == -12 or self.acTurnStage == -22 then
			-- after U-turn
				local a, o = AutoSteeringEngine.navigateToSavePoint( self, 3, AIVehicleExtension.navigationFallbackRetry )
				if not o then
					if turn2Outside then
						angle =  self.acDimensions.maxSteeringAngle
					else
						angle = -self.acDimensions.maxLookingAngle 
					end
				else
					angle  = nil
					angle2 = a
				end
			elseif turn2Outside then
		
				if     self.acTurnStage < 0 then 
					angle = self.acDimensions.maxSteeringAngle
				elseif noReverseIndex > 0 then 
					angle = self.acDimensions.maxLookingAngle 
				else 
					angle = 0
				end 
			elseif self.acTurnStage == -1 or self.acTurnStage == -11 or self.acTurnStage == -21 then
			-- after 90° turn
				angle  = nil
				angle2 = AutoSteeringEngine.navigateToSavePoint( self, 4, AIVehicleExtension.navigationFallbackRotateMinus )
				
			else
				angle = math.min( math.max( math.rad( 0.5 * turnAngle ), -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle )
			end
		end
				
--==============================================================				
	elseif self.acTurnStage == 8 then
		AutoSteeringEngine.currentSteeringAngle( self );
		AutoSteeringEngine.syncRootNode( self, true )
		AutoSteeringEngine.setChainStraight( self );			
		border = AutoSteeringEngine.getAllChainBorders( self );
		if border > 0 then detected = true end
	
--==============================================================				
-- backwards
	elseif self.acTurnStage == 4 then

		if self.acTurn2Outside then
			detected, angle2, border = AIVehicleExtension.detectAngle( self, 0.5 )
		else 
			detected, angle2, border = AIVehicleExtension.detectAngle( self )
		end 
		
	elseif self.acTurnStage == 3 then

		AutoSteeringEngine.setSteeringAngle( self, 0 )
	
		if self.acTurn2Outside then
			detected, _, border = AIVehicleExtension.detectAngle( self, 0.5 )
		else
			AutoSteeringEngine.syncRootNode( self, true )
			AutoSteeringEngine.setChainStraight( self )

			border   = AutoSteeringEngine.getAllChainBorders( self, 1, AIVEGlobals.chainMax );
			detected = border > 0
		end

	else
		AutoSteeringEngine.setChainContinued( self );
	end

	
	local lastAcTurnStage = self.acTurnStage 
--============================================================================================================================						
--============================================================================================================================						
--============================================================================================================================						
--============================================================================================================================		
-- move far enough			
	if     self.acTurnStage == 1 then

		self.acTurnStage4Point = nil 
		AIVehicleExtension.setAIImplementsMoveDown(self,false);
		
		--if turnAngle > -angleOffset then
		--	angle = self.acDimensions.maxSteeringAngle;
		--else
		--	angle = 0;
		--end
		angle = math.min( math.max( math.rad( turnAngle ), -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle )

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, false );
		local toolAngle = AutoSteeringEngine.getToolAngle( self )
		local nextTS = false
		
		if self.acTurn2Outside then
			if      math.abs( turnAngle ) < angleOffset 
					and math.abs( toolAngle ) < AIVEGlobals.maxToolAngleF * self.acDimensions.maxSteeringAngle then
				nextTS = true
			end
		else
			if      math.abs( turnAngle ) < angleOffset 
					and math.abs( toolAngle ) < AIVEGlobals.maxToolAngleF * self.acDimensions.maxSteeringAngle 
					and z > math.max( self.acDimensions.radius, AIVEGlobals.minRadius ) then
				nextTS = true
			end
		end
		
		if nextTS then
			AutoSteeringEngine.ensureToolIsLowered( self, false )
			self.acTurnStage   = self.acTurnStage + 1;
			self.turnTimer     = self.acDeltaTimeoutWait;
			allowedToDrive     = false;			
			angle              = 0
			self.waitForTurnTime = g_currentMission.time + self.turnTimer;
		end

--==============================================================				
-- going back I
	elseif self.acTurnStage == 2 then
		
		moveForwards   = false;					
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, false );
		angle = -math.min( math.max( math.rad( turnAngle ), -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle )

		if 1 == 2 then --    self.acTurn2Outside and ( x*x+z*z > 100 or noReverseIndex > 0 ) then
			self.acTurnStage = self.acTurnStage + 2;
			self.turnTimer = self.acDeltaTimeoutNoTurn
		elseif z < math.max( self.acDimensions.radius, AIVEGlobals.minRadius ) + stoppingDist then
			self.acTurnStage         = self.acTurnStage + 1;
		--self.acLastSteeringAngle = self.acDimensions.maxSteeringAngle
			self.waitForTurnTime     = g_currentMission.time + self.acDeltaTimeoutWait
			if self.acTurn2Outside then
				angle = 0 ---self.acDimensions.maxSteeringAngle
			elseif self.acDimensions.wheelBase > 0 and z > 0 then
				angle = Utils.clamp( math.atan2( self.acDimensions.wheelBase, z / ( 1 - math.sin( math.abs( math.rad( turnAngle ) ) ) ) ), 0, self.acDimensions.maxSteeringAngle )
			else				
				angle = self.acDimensions.maxSteeringAngle
			end
		end

--==============================================================				
-- going back II
	elseif self.acTurnStage == 3 then

		moveForwards = false;			
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, false );

		if self.acTurn2Outside and x*x+z*z > 100 then
			self.acTurnStage = self.acTurnStage + 1;
			self.turnTimer = self.acDeltaTimeoutStart
		elseif detected then
			angle                = 0
		--self.acTurnStage     = -1
			self.acTurnStage     = self.acTurnStage + 1;
			self.waitForTurnTime = g_currentMission.time + self.acDeltaTimeoutWait
			self.turnTimer       = self.acDeltaTimeoutWait
		elseif self.acTurn2Outside then
		--angle = -self.acDimensions.maxLookingAngle
		--if math.abs( turnAngle ) > 30 then
		--	self.acTurnStage = self.acTurnStage + 1;
		--	self.turnTimer = self.acDeltaTimeoutStart
		--end
			angle = 0
		elseif math.abs( turnAngle ) > 90 - angleOffset 
		   and not fruitsDetected then
			self.acTurnStage     = self.acTurnStage + 1;
			self.turnTimer       = self.acDeltaTimeoutStart
			angle                = 0
			self.waitForTurnTime = g_currentMission.time + self.acDeltaTimeoutWait
		elseif math.abs( turnAngle ) > 120 - angleOffset then
			self.acTurnStage     = self.acTurnStage + 1;
			self.turnTimer       = self.acDeltaTimeoutStart
			angle                = math.rad( 120 - math.abs( turnAngle ) )
			self.waitForTurnTime = g_currentMission.time + self.acDeltaTimeoutWait
		elseif self.acDimensions.wheelBase > 0 and z > 0 then
			angle = Utils.clamp( math.atan2( self.acDimensions.wheelBase, z / ( 1 - math.sin( math.abs( math.rad( turnAngle ) ) ) ) ), 0, self.acDimensions.maxSteeringAngle )
		else
			angle = self.acDimensions.maxSteeringAngle
		end

		if noReverseIndex > 0 and self.acTurn2Outside and angle ~= nil then			
		--local toolAngle = AutoSteeringEngine.getToolAngle( self );			
		--angle  = nil;
		--angle2 = math.min( math.max( toolAngle, -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle );
			angle = AIVehicleExtension.getStraighBackwardsAngle( self, turnAngle - Utils.clamp( math.deg( angle ), -5, 5 ) )
		end
						
--==============================================================				
-- going back III
	elseif self.acTurnStage == 4 then

		moveForwards = false;					
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, false );
		local dist2 = 0
		
		if not detected then
			self.acTurnStage4Point = nil
			local endAngle = 120
			if border > 0 then	
				--angle = -self.acDimensions.maxSteeringAngle
				local toolAngle = AutoSteeringEngine.getToolAngle( self );			
				angle  = nil;
				angle2 = math.min( math.max( toolAngle, -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle );
			elseif math.abs( turnAngle ) > endAngle - angleOffset then
				angle = math.rad( endAngle - math.abs( turnAngle ) )
			elseif self.acTurn2Outside then
				angle = -self.acDimensions.maxLookingAngle
			else
				angle = self.acDimensions.maxSteeringAngle
			end
		else
			-- reverse => invert steeering angle2
			if angle2 ~= nil then
				angle2 = -angle2
			end
			
			if self.acTurn2Outside then
				local x,_,z = AutoSteeringEngine.getAiWorldPosition( self )			
				
				if self.acTurnStage4Point == nil then 
					self.acTurnStage4Point = { x=x, z=z }
				else 
					dist2 = (x-self.acTurnStage4Point.x)^2 + (z-self.acTurnStage4Point.z)^2 
				end
			else 
				dist2 = 10 
			end
		end
		
		if noReverseIndex > 0 and self.acTurn2Outside and angle ~= nil then			
		--local toolAngle = AutoSteeringEngine.getToolAngle( self );			
		--angle  = nil;
		--angle2 = math.min( math.max( toolAngle, -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle );
			angle = AIVehicleExtension.getStraighBackwardsAngle( self, turnAngle - Utils.clamp( math.deg( angle ), -5, 5 ) )
		end
						
		if     ( detected and dist2 > 9 )
				or self.turnTimer < 0
				or x*x + z*z      > 400 then
			if not detected then
				angle = 0
				if AIVEGlobals.devFeatures > 0 then
					if self.turnTimer < 0  then
						print("time out: "..tostring(self.acDeltaTimeoutNoTurn))
					elseif x*x + z*z > 400 then
						print("too far: 400m")
					end
				end
			end
				
			self.acTurnStage4Point = nil
			self.acTurnStage       = -1
			self.waitForTurnTime   = g_currentMission.time + self.acDeltaTimeoutWait
		end


--==============================================================				
--==============================================================				
-- 90° corner w/o going reverse					
	elseif self.acTurnStage == 5 then
		allowedToDrive = false;				
		if noReverseIndex > 0 then
			local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self );			
			angle = turn75.alpha
		else
			angle = self.acDimensions.maxSteeringAngle
		end
		if self.acTurn2Outside then
			angle = -angle 
		end
		
		AIVehicleExtension.setAIImplementsMoveDown(self,false);
		self.acTurnStage   = 6;					
		
--==============================================================				
	elseif self.acTurnStage == 6 then
		if noReverseIndex > 0 then
			local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self );			
			angle = turn75.alpha
		else
			angle = self.acDimensions.maxSteeringAngle
		end
		if self.acTurn2Outside then
			angle = -angle 
		end
		
		AutoSteeringEngine.ensureToolIsLowered( self, false )
		if turnAngle < 0 then
			self.acTurnStage   = 7;	
		end;
		
--==============================================================				
	elseif self.acTurnStage == 7 then
		if     turnAngle > 90 then
			angle = AIVehicleExtension.getMaxAngleWithTool( self, self.acTurn2Outside )
		else
			if noReverseIndex > 0 then
				local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self );			
				angle = turn75.alpha
			else
				angle = self.acDimensions.maxSteeringAngle
			end
			if self.acTurn2Outside then
				angle = -angle 
			end
		end
		
		if self.acTurn2Outside then				
			if 170 < turnAngle and turnAngle < 180 then
				self.acTurnStage   = 8;					
			end;
		else
			if math.abs( turnAngle ) > 165 then
				self.acTurnStage = 9
			end
		end
		
--==============================================================						
	elseif self.acTurnStage == 8 then
		angle = AIVehicleExtension.getMaxAngleWithTool( self, self.acTurn2Outside )
		
		if detected or fruitsDetected then
			self.acTurnStage   = -1;					
			self.turnTimer     = self.acDeltaTimeoutStart;
		end;

--==============================================================						
	elseif self.acTurnStage == 9 then
	
		if math.abs( turnAngle - 90 ) < math.deg( self.acDimensions.maxLookingAngle )  then
			detected, angle2, border = AIVehicleExtension.detectAngle( self, AIVEGlobals.smoothMax )
		else
			detected = false
		end
		
		if fruitsDetected then
			self.acTurnStage   = -1;					
			self.turnTimer     = self.acDeltaTimeoutStart;
		elseif detected then
			angle = nil
			if self.turnTimer < 0 then
				self.acTurnStage = -1
			end
		else
			self.turnTimer = self.acDeltaTimeoutRun
			local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self );
			angle2, onTrack = AutoSteeringEngine.navigateToSavePoint( self, 2, nil, turn75 )		
			if onTrack then
				angle  = nil
			elseif math.abs( turnAngle - 90 ) < angleOffsetStrict then
				self.acTurnStage   = -1;					
				self.turnTimer     = self.acDeltaTimeoutStart;
			else
				angle  = AIVehicleExtension.getMaxAngleWithTool( self, self.acTurn2Outside )
				angle2 = nil
			end
		end
	
--==============================================================				
--==============================================================				
-- the new U-turn with reverse
	elseif self.acTurnStage == 20 then
		angle = 0;
		self.acTurnStage   = self.acTurnStage + 1;					
		self.turnTimer     = self.acDeltaTimeoutRun;
		
		AIVehicleExtension.setAIImplementsMoveDown(self,false);
				
--==============================================================				
-- move far enough if tool is in front
	elseif self.acTurnStage == 21 then
		angle = 0;

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
		
		local dist = math.max( 0, math.max( self.acDimensions.distance, -self.acDimensions.zBack ) )
		
		if noReverseIndex > 0 then
			dist = math.max( 0, self.acDimensions.toolDistance + math.max( self.acDimensions.distance, -self.acDimensions.zBack ) )
		end
		
		turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self )
		dist = dist + math.max( 1, self.acDimensions.radius - turn75.radiusT )
		if noReverseIndex > 0 then
		-- space for the extra turn to get the tool angle to 0
			dist = dist + 2
		end
		
		AIVehicleExtension.debugPrint( self, string.format("T21: x: %0.3fm z: %0.3fm dist: %0.3fm (%0.3fm %0.3fm %0.3fm %0.3fm)",x, z, dist, self.acDimensions.toolDistance, self.acDimensions.zBack, self.acDimensions.radius, turn75.radiusT ) )
		
		if z > dist - stoppingDist then
			AutoSteeringEngine.ensureToolIsLowered( self, false )
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutRun;
		end

--==============================================================				
-- turn 90°
	elseif self.acTurnStage == 22 then
		angle = AIVehicleExtension.getMaxAngleWithTool( self )
		
		local toolAngle = AutoSteeringEngine.getToolAngle( self );	
		if not self.acParameters.leftAreaActive then
			toolAngle = -toolAngle
		end
		toolAngle = math.deg( toolAngle )
				
		turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self )
		
		if -turnAngle > 90 + AIVEGlobals.maxToolAngleF * self.acDimensions.maxSteeringAngle or turnAngle + 90 + 0.2 * toolAngle < angleOffset then
		--if turnAngle < angleOffset - 90 - math.deg(turn75.gammaE) then
			AutoSteeringEngine.setPloughTransport( self, true, true )
			
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutRun;
		end

--==============================================================			
-- move forwards and reduce tool angle	
	elseif self.acTurnStage == 23 then

		local toolAngle = AutoSteeringEngine.getToolAngle( self )
		if not self.acParameters.leftAreaActive then
			toolAngle = -toolAngle;
		end;
		--toolAngle = math.deg( toolAngle )

		--angle = turnAngle + 90 + 0.3 * toolAngle
		--
		--if math.abs( turnAngle + 90 ) < 9 and math.abs( angle ) < 3 then
		
		angle = Utils.clamp( math.rad( turnAngle + 90 ), AIVehicleExtension.getMaxAngleWithTool( self, true ), AIVehicleExtension.getMaxAngleWithTool( self, false ) )
		if      math.abs( turnAngle + 90 ) < angleOffset 
				and math.abs( toolAngle ) < AIVEGlobals.maxToolAngleF * self.acDimensions.maxSteeringAngle then
			angle = 0
			
			if self.acTurn2Outside then
				self.acParameters.leftAreaActive  = not self.acParameters.leftAreaActive;
				self.acParameters.rightAreaActive = not self.acParameters.rightAreaActive;
				AIVehicleExtension.sendParameters(self);
			end
			
			local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
			if self.acParameters.leftAreaActive then x = -x end

			if self.acTurn2Outside then x = -x end
			x = x - 1 - self.acDimensions.radius -- + math.max( 0, self.acDimensions.radius - turn75.radiusT )
			
			if x > -stoppingDist or z < 0 then
      -- no need to drive backwards
				if self.acParameters.leftAreaActive then
					AIVehicle.aiRotateLeft(self);
				else
					AIVehicle.aiRotateRight(self);
				end
				AutoSteeringEngine.setPloughTransport( self, false )
				self.acTurnStage     = 26
				self.waitForTurnTime = self.acDeltaTimeoutRun + g_currentMission.time
				self.turnTimer       = 0
			else
				if noReverseIndex <= 0 then
					if self.acParameters.leftAreaActive then
						AIVehicle.aiRotateLeft(self);
					else
						AIVehicle.aiRotateRight(self);
					end
					AutoSteeringEngine.setPloughTransport( self, true, true )
				end
			
				self.acTurnStage   = self.acTurnStage + 1;					
				self.turnTimer     = self.acDeltaTimeoutRun;
			end
		end

--==============================================================				
-- wait		
	elseif self.acTurnStage == 24 then
		allowedToDrive = false;						
		moveForwards = false;				
		local target = -90
		if noReverseIndex > 0 then
			target = -87
		end
		if self.acTurn2Outside then
			target = -target
		end
		angle  = AIVehicleExtension.getStraighBackwardsAngle( self, target )
		if self.turnTimer < 0 then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutStop;
		end
		
--==============================================================				
-- move backwards (straight)		
	elseif self.acTurnStage == 25 then		
		moveForwards = false;					
		local target = -90
		if noReverseIndex > 0 then
			target = -87
		end
		if self.acTurn2Outside then
			target = -target
		end
		angle  = AIVehicleExtension.getStraighBackwardsAngle( self, target )
		
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
		if self.acParameters.leftAreaActive then x = -x end
		
		if self.acTurn2Outside then x = -x end
	--x = x - 2 - self.acDimensions.radius - math.max( 0.2 * self.acDimensions.radius, 1 )
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self )
		x = x - math.max( turn75.radius + 2, turn75.radius * 1.15 )

		if allowedToDrive and ( x > -stoppingDist or z < 0 ) then
			if noReverseIndex > 0 then
				if self.acParameters.leftAreaActive then
					AIVehicle.aiRotateLeft(self);
				else
					AIVehicle.aiRotateRight(self);
				end
			end
			AutoSteeringEngine.setPloughTransport( self, false )--, true )
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutRun;
		end
		
--==============================================================				
-- wait
	elseif self.acTurnStage == 26 then
		local onTrack    = false
		angle2, onTrack  = AutoSteeringEngine.navigateToSavePoint( self, 1 )
		if not onTrack then
			angle  = AIVehicleExtension.getMaxAngleWithTool( self, false )
			angle2 = nil
		else
			angle  = nil
		end
		
		if self.turnTimer < 0 then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutStop;
			
		else
			allowedToDrive = false;						
		end

--==============================================================				
-- turn 90°
	elseif self.acTurnStage == 27 then
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
		
		detected = false
		if     fruitsDetected
				or math.abs( turnAngle )   >= 180 - angleOffset
				or ( math.abs( turnAngle ) >= 180 - math.deg( self.acDimensions.maxLookingAngle ) 
				 and math.abs( AutoSteeringEngine.getToolAngle( self ) ) <= AIVEGlobals.maxToolAngle2 ) then
			detected, angle2, border = AIVehicleExtension.detectAngle( self )
		end		
		
		AIVehicleExtension.debugPrint( self, string.format("T27: x: %0.3fm z: %0.3fm test: %0.3fm fd: %s det: %s ta: %0.1f°", x, z, AutoSteeringEngine.getToolDistance( self ), tostring(fruitsDetected), tostring(detected), turnAngle ) )
		
		if detected then
			if fruitsDetected or math.abs( turnAngle ) >= 180 - angleOffset then
				self.acTurnStage = -2
				self.turnTimer   = self.acDeltaTimeoutNoTurn;
				AIVehicleExtension.setAIImplementsMoveDown(self,true);
			end
		elseif fruitsDetected then
			self.acTurnStage = 110
			self.turnTimer   = self.acDeltaTimeoutNoTurn
		else
			self.turnTimer   = self.acDeltaTimeoutNoTurn;
			angle            = nil
		--local turn75     = AutoSteeringEngine.getMaxSteeringAngle75( self );
			local onTrack    = false
		--angle2, onTrack  = AutoSteeringEngine.navigateToSavePoint( self, 1, nil, turn75 )
			angle2, onTrack  = AutoSteeringEngine.navigateToSavePoint( self, 1 )
			if not onTrack then
				if math.abs( turnAngle ) < 150 then
					angle  = AIVehicleExtension.getMaxAngleWithTool( self, false )
					angle2 = nil
				else
					self.acTurnStage = 110
					self.turnTimer   = self.acDeltaTimeoutNoTurn
				end
			end
		end
		
--==============================================================				
--==============================================================				
-- 90° turn to inside with reverse
	elseif self.acTurnStage == 30 then

		AIVehicleExtension.setAIImplementsMoveDown(self,false);
		self.acTurnStage   = self.acTurnStage + 1;
		self.turnTimer     = self.acDeltaTimeoutWait;
		--self.waitForTurnTime = g_currentMission.time + self.turnTimer;

--==============================================================				
-- wait
	elseif self.acTurnStage == 31 then
		allowedToDrive = false;				
		moveForwards = false;					
		angle = 0
		
		if self.turnTimer < 0 or AIVehicleExtension.stopWaiting( self, angle ) then
			AutoSteeringEngine.ensureToolIsLowered( self, false )
			self.acTurnStage   = self.acTurnStage + 1;					
		end

--==============================================================				
-- move backwards (straight)		
	elseif self.acTurnStage == 32 then		
		moveForwards = false;					
		angle  = nil;
		local toolAngle = AutoSteeringEngine.getToolAngle( self );
		angle2 = math.min( math.max( toolAngle, -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle );

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self );
		
		local wx,_,wz = AutoSteeringEngine.getAiWorldPosition( self );
		local f = 0.7
		if  AutoSteeringEngine.checkField( self, wx, wz ) then
			f = 1.4
		end
				
		if z < f * self.acDimensions.radius + stoppingDist then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutRun;
		end

--==============================================================				
-- turn 50°
	elseif self.acTurnStage == 33 then
		angle = AIVehicleExtension.getMaxAngleWithTool( self, true )
		
		local toolAngle = AutoSteeringEngine.getToolAngle( self );	
		if self.acParameters.leftAreaActive then
			toolAngle = -toolAngle
		end
		
		if turnAngle - 0.6 * math.deg( toolAngle ) > 50 - angleOffset then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutRun;
		end

--==============================================================			
-- move forwards and reduce tool angle	
	elseif self.acTurnStage == 34 then

		local toolAngle = AutoSteeringEngine.getToolAngle( self )
		
		if turnAngle > 50 + angleOffset then
			angle = AIVehicleExtension.getMaxAngleWithTool( self, false )
		elseif turnAngle < 50 - angleOffset then
			angle = AIVehicleExtension.getMaxAngleWithTool( self, true )
		else
			angle  = nil;		
			angle2 = math.min( math.max( -toolAngle, -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle );
		end
		
		if math.abs(math.deg(toolAngle)) < 5 and math.abs( turnAngle - 50 ) < angleOffset then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutRun;
		end

--==============================================================				
-- wait		
	elseif self.acTurnStage == 35 then
		allowedToDrive = false;						
		moveForwards = false;					
		angle  = 0;

		if self.turnTimer < 0 or AIVehicleExtension.stopWaiting( self, angle ) then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutStop;
		end
		
--==============================================================				
-- move backwards (straight)		
	elseif self.acTurnStage == 36 then		
		moveForwards = false;					
	--angle  = nil;
	--local toolAngle = AutoSteeringEngine.getToolAngle( self );
	--angle2 = math.min( math.max( toolAngle, -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle );
		angle  = AIVehicleExtension.getStraighBackwardsAngle( self, 50 )
		
		local _,z, allowedToDrive = AIVehicleExtension.getTurnVector( self );
		
		detected, angle2, border = AIVehicleExtension.detectAngle( self )
		
		if z < 0 or ( detected and z < 0.5 * self.acDimensions.distance ) then				
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutRun;
		end
		
--==============================================================				
-- wait
	elseif self.acTurnStage == 37 then
		allowedToDrive = false;						
		angle = AIVehicleExtension.getMaxAngleWithTool( self, true )
		
		if self.turnTimer < 0 or AIVehicleExtension.stopWaiting( self, angle ) then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutStop;
		end

--==============================================================				
-- turn 45°
	elseif self.acTurnStage == 38 then
		local x, allowedToDrive = AIVehicleExtension.getTurnVector( self );
		if self.acParameters.leftAreaActive then x = -x end

		detected, angle2, border = AIVehicleExtension.detectAngle( self )
			
		if turnAngle < 90 - math.deg( self.acDimensions.maxLookingAngle ) then
			angle = -self.acDimensions.maxSteeringAngle;
		elseif fruitsDetected or detected or math.abs( turnAngle ) > 90 or x < 0 then
			self.acTurnStage = -1;					
			self.turnTimer   = self.acDeltaTimeoutStart;
		else
			angle = 0
		end
		
--==============================================================				
-- wait after 90° turn
	elseif self.acTurnStage == 39 then
		allowedToDrive = false;						
		
		angle = 0;
		
		if self.turnTimer < 0 or AIVehicleExtension.stopWaiting( self, angle ) then
			self.acTurnStage = -1;					
			self.turnTimer   = self.acDeltaTimeoutStart;
		end;

--==============================================================				
--==============================================================				
-- 180° turn with 90° backwards
	elseif self.acTurnStage == 40 then
		angle = 0;
		self.acTurnStage   = self.acTurnStage + 1;					
		self.turnTimer     = self.acDeltaTimeoutRun;

		AIVehicleExtension.setAIImplementsMoveDown(self,false);
		
--==============================================================				
-- move far enough if tool is in front
	elseif self.acTurnStage == 41 then
		angle = 0;

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
		if z > math.max( 0, self.acDimensions.toolDistance ) + 1 - stoppingDist then
			AutoSteeringEngine.ensureToolIsLowered( self, false )
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutRun;
		end

--==============================================================				
-- wait
	elseif self.acTurnStage == 42 then
		allowedToDrive = false;				
		moveForwards = false;					
		angle = 0
		
		if self.turnTimer < 0 or AIVehicleExtension.stopWaiting( self, angle ) then
			self.acTurnStage   = self.acTurnStage + 1;					
		end

--==============================================================				
-- turn 45°
	elseif self.acTurnStage == 43 then		
		angle = AIVehicleExtension.getMaxAngleWithTool( self, true )
		
		if turnAngle > 45-angleOffset then
			if self.acParameters.leftAreaActive then
				AIVehicle.aiRotateLeft(self);
			else
				AIVehicle.aiRotateRight(self);
			end
			self.acTurnStage     = self.acTurnStage + 1;					
			self.turnTimer       = self.acDeltaTimeoutNoTurn;
		end
--==============================================================				
-- wait
	elseif self.acTurnStage == 44 then
		allowedToDrive = false;						
		angle = AIVehicleExtension.getMaxAngleWithTool( self )
		
		if self.turnTimer < 0 or AIVehicleExtension.stopWaiting( self, angle ) then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutStop;
		end

--==============================================================				
-- move backwards (90°)	I	
	elseif self.acTurnStage == 45 then		
		moveForwards = false;					
		angle = AIVehicleExtension.getMaxAngleWithTool( self )
		
		if turnAngle > 90-angleOffset then
			self.acTurnStage     = self.acTurnStage + 1;					
			angle = math.min( math.max( 3 * math.rad( 90 - turnAngle ), -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle )
			self.waitForTurnTime = self.acDeltaTimeoutRun + g_currentMission.time
		end
--==============================================================				
-- move backwards (0°) II
	elseif self.acTurnStage == 46 then		
		moveForwards = false;					
		angle = math.min( math.max( 3 * math.rad( 90 - turnAngle ), -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle )
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
		if not self.acParameters.leftAreaActive then x = -x end
	
		--if self.isRealistic then
		--	x = x - 1
		--else	
		--	x = x - 0.5
		--end
		
		if x > - stoppingDist then
			self.acTurnStage   = self.acTurnStage + 1;					
			angle = self.acDimensions.maxSteeringAngle;
			self.waitForTurnTime = self.acDeltaTimeoutRun + g_currentMission.time
		end
--==============================================================				
-- move backwards (45°) III
	elseif self.acTurnStage == 47 then		
		moveForwards = false;					
		angle = AIVehicleExtension.getMaxAngleWithTool( self )
		
		if turnAngle > 150-angleOffset then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutRun;
		end
--==============================================================				
-- wait
	elseif self.acTurnStage == 48 then
		allowedToDrive = false;						
		angle = AIVehicleExtension.getMaxAngleWithTool( self, false )
		
		if self.turnTimer < 0 or AIVehicleExtension.stopWaiting( self, angle ) then
			AIVehicleExtension.setAIImplementsMoveDown(self,true);
			AutoSteeringEngine.navigateToSavePoint( self, 1 )
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutStop;
		end

--==============================================================				
-- turn 90° II
	elseif self.acTurnStage == 49 then
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
 
		detected, angle2, border = AIVehicleExtension.detectAngle( self )
 
		if detected then
			AIVehicleExtension.setAIImplementsMoveDown(self,true);
			if fruitsDetected or z < AutoSteeringEngine.getToolDistance( self ) then
				self.acTurnStage = -2
				self.turnTimer   = self.acDeltaTimeoutNoTurn;
			end
		elseif fruitsDetected then
			self.acTurnStage = 110
			self.turnTimer   = self.acDeltaTimeoutNoTurn
		else
			self.turnTimer   = self.acDeltaTimeoutNoTurn;
			angle            = nil
		--local turn75     = AutoSteeringEngine.getMaxSteeringAngle75( self );
			local onTrack    = false
		--angle2, onTrack  = AutoSteeringEngine.navigateToSavePoint( self, 1, nil, turn75 )
			angle2, onTrack  = AutoSteeringEngine.navigateToSavePoint( self, 1 )
			if not onTrack then
				self.acTurnStage = 110
				self.turnTimer   = self.acDeltaTimeoutNoTurn
			end
		end
		
		
		
		
--==============================================================				
--==============================================================				
-- 180° turn with 90° backwards
--elseif self.acTurnStage == 50 then
--	allowedToDrive = false;				
--	moveForwards = false;					
--	angle = 0
--	
--	--if self.turnTimer < 0 then
--		AIVehicleExtension.setAIImplementsMoveDown(self,false);
--		self.acTurnStage   = self.acTurnStage + 1;					
--	--end
--==============================================================				
-- move far enough if tool is in front
	elseif self.acTurnStage == 50 then
		AIVehicleExtension.setAIImplementsMoveDown(self,false);
		angle = 0;

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );		
		local dist = math.max( 0, self.acDimensions.toolDistance )
		
		if z > dist - stoppingDist then
			self.acTurnStage   = self.acTurnStage + 1;					
		end

--==============================================================				
-- turn 45°
	elseif self.acTurnStage == 51 then
		angle = -self.acDimensions.maxSteeringAngle;
		moveForwards = false;					
		
		if turnAngle < -60+angleOffset then
			AutoSteeringEngine.ensureToolIsLowered( self, false )
			if self.acParameters.leftAreaActive then
				AIVehicle.aiRotateLeft(self);
			else
				AIVehicle.aiRotateRight(self);
			end
			self.acTurnStage     = self.acTurnStage + 1;					
			self.turnTimer       = self.acDeltaTimeoutNoTurn;
		end
--==============================================================				
-- wait
	elseif self.acTurnStage == 52 then
		allowedToDrive = false;						
		angle = self.acDimensions.maxSteeringAngle;
		
		if self.turnTimer < 0 or AIVehicleExtension.stopWaiting( self, angle ) then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutStop;
		end

--==============================================================				
-- move backwards (90°)	I	
	elseif self.acTurnStage == 53 then		
		angle = self.acDimensions.maxSteeringAngle;
		
		if turnAngle < -90+angleOffset then			
			angle                = math.min( math.max( 3 * math.rad( turnAngle + 90 ), -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle )
			self.waitForTurnTime = self.acDeltaTimeoutRun + g_currentMission.time
			self.acTurnStage     = self.acTurnStage + 1;					
		end
--==============================================================				
-- move backwards (0°) II
	elseif self.acTurnStage == 54 then		
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
		if not self.acParameters.leftAreaActive then x = -x end

		angle = math.min( math.max( 3 * math.rad( turnAngle + 90 ), -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle )
		
	--if x > - stoppingDist then
		if x > 0 then
			angle                = self.acDimensions.maxSteeringAngle;
			self.waitForTurnTime = self.acDeltaTimeoutRun + g_currentMission.time
			self.acTurnStage     = self.acTurnStage + 1;					
		end
--==============================================================				
-- move backwards (90°) III
	elseif self.acTurnStage == 55 then		
		angle = self.acDimensions.maxSteeringAngle;
		
		if turnAngle < -120+angleOffset then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutRun;
		end
--==============================================================				
-- wait
	elseif self.acTurnStage == 56 then
		allowedToDrive = false;						
		moveForwards = false;					
		angle = -self.acDimensions.maxSteeringAngle;
		
		if self.turnTimer < 0 or AIVehicleExtension.stopWaiting( self, angle ) then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutStop;
			self.acMinDetected = nil
		end

--==============================================================				
-- move backwards (90°)	I	
	elseif self.acTurnStage == 57 then		
		angle = -self.acDimensions.maxSteeringAngle;
		moveForwards = false;					

		if turnAngle > 0 or turnAngle < -180+angleOffset then
			angle                = 0
			self.waitForTurnTime = self.acDeltaTimeoutRun + g_currentMission.time
			self.acTurnStage     = self.acTurnStage + 1;					
		end
		
--==============================================================				
-- move backwards (90°)	II	
	elseif self.acTurnStage == 58 then		
		moveForwards = false;					
	
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
		if not self.acParameters.leftAreaActive then x = -x end
		
		if fruitsDetected then
			detected = false
			angle    = 0
			angle2   = nil
		else
			detected, angle2, border = AIVehicleExtension.detectAngle( self )
						
			if detected then
				angle  = nil
				angle2 = -angle2
			else
				angle  = 0
				angle2 = nil
			end
		end
		
		if not detected then
			self.acMinDetected = nil
		end
		
		if z > self.acDimensions.toolDistance - stoppingDist then	
			if z > self.acDimensions.toolDistance + 10 then	
				AIVehicleExtension.setAIImplementsMoveDown(self,true);
				self.acTurnStage   = self.acTurnStage + 1;					
				self.turnTimer     = self.acDeltaTimeoutRun;
			elseif detected then
				if self.acMinDetected == nil then
					self.acMinDetected = z + 1
				elseif z > self.acMinDetected then
					AIVehicleExtension.setAIImplementsMoveDown(self,true);
					self.acTurnStage   = self.acTurnStage + 1;					
					self.turnTimer     = self.acDeltaTimeoutRun;
					self.acMinDetected = nil
				end
			end
		end

--==============================================================				
-- wait
	elseif self.acTurnStage == 59 then
		allowedToDrive = false;						
		angle = 0
		
		if self.turnTimer < 0 or AIVehicleExtension.stopWaiting( self, angle ) then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutRun;
			AutoSteeringEngine.navigateToSavePoint( self, 1 )
		end

		--==============================================================				
-- turn 90° II
	elseif self.acTurnStage == 60 
			or self.acTurnStage == 61 then
			
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );

		detected, angle2, border = AIVehicleExtension.detectAngle( self )
		
		if detected then
			if self.acTurnStage == 60 then
				AIVehicleExtension.setAIImplementsMoveDown(self,true);
				self.turnTimer   = self.acDeltaTimeoutRun;
				self.acTurnStage = 61			
			end
				
		--if     fruitsDetected 
		--		or ( z < AutoSteeringEngine.getToolDistance( self )
		--		 and self.acTurnStage == 61
		--		 and self.turnTimer   <  0 ) then
			if     fruitsDetected 
					or z < AutoSteeringEngine.getToolDistance( self ) then
				self.acTurnStage = -2
				self.turnTimer   = self.acDeltaTimeoutNoTurn;
			end
		elseif fruitsDetected then
			self.acTurnStage = 110
			self.turnTimer   = self.acDeltaTimeoutNoTurn
		else
			self.acTurnStage = 60
			angle            = nil
			local onTrack    = false
			angle2, onTrack  = AutoSteeringEngine.navigateToSavePoint( self, 1 )
			if not onTrack and self.turnTimer < 0 then
				self.acTurnStage = 110
				self.turnTimer   = self.acDeltaTimeoutNoTurn
			end
		end
		
		
--==============================================================				
--==============================================================				
-- the new U-turn w/o reverse
	elseif self.acTurnStage == 70 then
		angle = 0;
		
		self.acTurnStage   = self.acTurnStage + 1;					
		self.turnTimer     = self.acDeltaTimeoutRun;

		AIVehicleExtension.setAIImplementsMoveDown(self,false);
--==============================================================				
-- move far enough
	elseif self.acTurnStage == 71 then

		local dist = math.max( 1, self.acDimensions.toolDistance )
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
		if self.acParameters.leftAreaActive then x = -x end
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self );
		
		if turnAngle < 90 - angleOffset then
			angle = AIVehicleExtension.getMaxAngleWithTool( self, true )
		else
			angle = 0
		end
		
		local corr     = self.acDimensions.radius * ( 1 - math.cos( math.rad(turnAngle)))
		local dx       = x - 2 * turn75.radius
		if turnAngle > 0 then
			dx = math.min(0,dx + corr)
		else
			dx = math.min(0,dx - corr)
		end		
		
		AIVehicleExtension.debugPrint( self, string.format("T71: x: %0.3fm z: %0.3fm dx: %0.3fm (%0.3fm %0.1f° %0.3fm %0.3fm)",x, z, dx, self.acDimensions.radius, turnAngle, turn75.radius, turn75.radiusT ) )		
		
		if dx > - stoppingDist then
			AutoSteeringEngine.ensureToolIsLowered( self, false )
		--if turnAngle < angleOffset and x < Utils.getNoNil( self.aseActiveX, 0 ) then
			if turnAngle < angleOffset then
				self.acTurnStage     = self.acTurnStage + 2;					
				self.waitForTurnTime = self.acDeltaTimeoutRun + g_currentMission.time
				angle                = turn75.alpha --AIVehicleExtension.getMaxAngleWithTool( self, false )
			else
				self.acTurnStage     = self.acTurnStage + 1;					
				self.waitForTurnTime = self.acDeltaTimeoutRun + g_currentMission.time
				angle                = AIVehicleExtension.getMaxAngleWithTool( self, false )
			end
		end
	
--==============================================================				
-- move far enough II
	elseif self.acTurnStage == 72 then

		angle = AIVehicleExtension.getMaxAngleWithTool( self, false )
		
		if turnAngle < angleOffset then
			self.acTurnStage     = self.acTurnStage + 1;					
			self.waitForTurnTime = self.acDeltaTimeoutRun + g_currentMission.time
			local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self );
			angle                = turn75.alpha 
		end
	
--==============================================================				
-- now turn 90°
	elseif self.acTurnStage == 73 then	

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
		if self.acParameters.leftAreaActive then x = -x end
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self );
				
		angle = turn75.alpha --AIVehicleExtension.getMaxAngleWithTool( self, false )
		
		if turnAngle < angleOffset-90 then
			if self.acParameters.leftAreaActive then
				AIVehicle.aiRotateLeft(self);
			else
				AIVehicle.aiRotateRight(self);
			end
			
			if x < turn75.radius + 0.5 then
				self.acTurnStage = self.acTurnStage + 2;					
			else
				self.acTurnStage     = self.acTurnStage + 1;					
			--self.waitForTurnTime = self.acDeltaTimeoutRun + g_currentMission.time
				angle                = 0
			end
		end

--==============================================================				
-- check distance
	elseif self.acTurnStage == 74 then	
		angle = 0

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
		if self.acParameters.leftAreaActive then x = -x end
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self );
	
		if x < turn75.radius - 0.5 then
			self.acTargetValue   = nil
			self.acTurnStage     = self.acTurnStage + 1;					
		--self.waitForTurnTime = self.acDeltaTimeoutRun + g_currentMission.time
			angle                = turn75.alpha
		elseif x < turn75.radius then
			angle = 2 * ( turn75.radius - x ) * turn75.alpha
		end
		
--==============================================================				
-- now turn again 90°
	elseif self.acTurnStage == 75 then	

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
		if self.acParameters.leftAreaActive then x = -x end
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self );

		angle = turn75.alpha

		if turnAngle < angleOffset - 180 or turnAngle > 0 then
			--AIVehicleExtension.debugPrint( self, tostring(self.acTurnStage).." "..tostring(turnAngle).." "..tostring(x))
			if x > -stoppingDist then
				AIVehicleExtension.setAIImplementsMoveDown(self,true);
				AutoSteeringEngine.setPloughTransport( self, false )
				self.acTurnStage     = self.acTurnStage + 4;					
				self.waitForTurnTime = self.acDeltaTimeoutRun + g_currentMission.time
				angle                = 0
			else
				self.acTurnStage     = self.acTurnStage + 1;					
			--self.waitForTurnTime = self.acDeltaTimeoutRun + g_currentMission.time
				angle                = turn75.alpha --AIVehicleExtension.getMaxAngleWithTool( self, false )
			end
		end
				
--==============================================================				
-- now turn til endAngle
	elseif self.acTurnStage == 76 then	

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
		if self.acParameters.leftAreaActive then x = -x end
		x = x + stoppingDist
		
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self );
		angle = turn75.alpha
		
		local beta      = math.rad( 180 - turnAngle )		
		local endAngle1 = math.acos(math.min(math.max(  1 + ( x + turn75.radius * ( 1 - math.cos( beta ))) /( self.acDimensions.radius + turn75.radius ), 0), 1))
		local endAngle2 = math.asin(math.min(math.max( z / ( self.acDimensions.radius + turn75.radius ), -1 ), 1 ))			
		local endAngle  = math.min( endAngle1, endAngle2 )
		--AIVehicleExtension.debugPrint( self, tostring(self.acTurnStage)..": "..tostring(turnAngle).." "..tostring(x).." "..tostring(z).." "..tostring(math.deg(endAngle1)).." "..tostring(math.deg(endAngle2)))
		
		if 0 < turnAngle and turnAngle <= 180 - math.deg( endAngle ) + angleOffset then
			self.acTurnStage     = self.acTurnStage + 1;					
			self.waitForTurnTime = self.acDeltaTimeoutRun + g_currentMission.time
			angle                = -self.acDimensions.maxSteeringAngle
		end
				
--==============================================================				
-- now turn to angle 180°
	elseif self.acTurnStage == 77 or self.acTurnStage == 78 then	
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
		if self.acParameters.leftAreaActive then x = -x end

		if allowedToDrive then
			if math.abs(x) > 0.2 and math.abs(z) > 0.2 and angleOffset < turnAngle and turnAngle < 180 - angleOffset then
				local r = x / ( 1 - math.cos( math.rad(180-turnAngle) ) )
				angle = math.atan( self.acDimensions.wheelBase / r )
			else
				angle = -self.acDimensions.maxSteeringAngle
			end
			
			local nextTS = false
			if math.abs(x) <= 0.2 or math.abs(z) <= 0.2 or turnAngle < 0 or turnAngle >= 180 - angleOffset then
				nextTS = true
			elseif self.acTurnStage == 78 and turnAngle >= 160 then --180 - math.deg( angleMax ) then
				nextTS = true
			end
			
			if self.acTurnStage == 77 then
				if     noReverseIndex <= 0
						or math.abs( math.deg(AutoSteeringEngine.getToolAngle( self )) ) < 60 
						or nextTS then
					AIVehicleExtension.setAIImplementsMoveDown(self,true);
					AutoSteeringEngine.setPloughTransport( self, false )
					self.acTurnStage     = self.acTurnStage + 1;					
				end
			end

			if nextTS then 
				self.acTurnStage     = self.acTurnStage + 1;					
				self.waitForTurnTime = self.acDeltaTimeoutRun + g_currentMission.time
				angle                = -self.acDimensions.maxSteeringAngle
				AutoSteeringEngine.navigateToSavePoint( self, 3 )
			end
		end
				
--==============================================================				
-- end sequence
	elseif self.acTurnStage == 79 then	
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
		if self.acParameters.leftAreaActive then x = -x end
		
		if allowedToDrive then
			angle  = nil
			
			if     fruitsDetected
					or ( math.abs( turnAngle ) >= 170 
					 and math.abs( AutoSteeringEngine.getToolAngle( self ) ) <= AIVEGlobals.maxToolAngle2 ) then
				detected, angle2, border = AIVehicleExtension.detectAngle( self, -1 )
			else
				detected = false
			end
			
			--AIVehicleExtension.debugPrint( self, tostring(self.acTurnStage)..": "..tostring(turnAngle).." "..tostring(x).." "..tostring(z).." "..tostring(detected))
			
			if detected then			
				self.acTurnStage   = -2
				self.turnTimer     = self.acDeltaTimeoutNoTurn;
				AIVehicleExtension.setAIImplementsMoveDown(self,true);
			elseif not detected then					
				angle2 = AutoSteeringEngine.navigateToSavePoint( self, 3, AIVehicleExtension.navigationFallbackRetry )
			else
				AIVehicleExtension.setAIImplementsMoveDown(self,true);
			end
		else
			angle = 0
		end
		
--==============================================================				
--==============================================================				
-- U-turn with 8-shape
	elseif self.acTurnStage == 80 then	
		self.acTurnStage   = self.acTurnStage + 1;					
		self.turnTimer     = self.acDeltaTimeoutRun;
		angle              = AIVehicleExtension.getMaxAngleWithTool( self, false )

		AIVehicleExtension.setAIImplementsMoveDown(self,false);
		
--==============================================================				
-- turn inside
	elseif self.acTurnStage == 81 then	
		angle              = AIVehicleExtension.getMaxAngleWithTool( self, false )

		if turnAngle < -150 + angleOffset then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutRun;
		end
		
--==============================================================		
-- rotate plough		
	elseif self.acTurnStage == 82 then	
		angle                = AIVehicleExtension.getMaxAngleWithTool( self, true )
		
		if 		 turnAngle > -90 - angleOffset - angleOffset
				or math.abs( AutoSteeringEngine.getToolAngle( self ) ) <= AIVEGlobals.maxToolAngle2 then
			self.acTurnStage     = self.acTurnStage + 1;					
			if self.acParameters.leftAreaActive then
				AIVehicle.aiRotateLeft(self);
			else
				AIVehicle.aiRotateRight(self);
			end
		end

--==============================================================				
-- turn outside I
	elseif self.acTurnStage == 83 then	
		angle              = AIVehicleExtension.getMaxAngleWithTool( self, true )			

		if turnAngle > -90 - angleOffset then
			local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
			local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self );
			if math.abs(x) > self.acDimensions.distance - turn75.radius - stoppingDist then
			--self.waitForTurnTime = self.acDeltaTimeoutRun + g_currentMission.time
				angle                = 90 + turnAngle
				self.acTurnStage     = self.acTurnStage + 1;					
				self.turnTimer       = self.acDeltaTimeoutRun;
			else
				self.acTurnStage   = self.acTurnStage + 2
				self.turnTimer     = self.acDeltaTimeoutRun;
			end
			AutoSteeringEngine.setPloughTransport( self, false )
		end

--==============================================================				
-- move far enough
	elseif self.acTurnStage == 84 then	
		angle = 90 + turnAngle

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self );
		if math.abs(x) > self.acDimensions.distance - turn75.radius + stoppingDist then
		--self.waitForTurnTime = self.acDeltaTimeoutRun + g_currentMission.time
			angle                = AIVehicleExtension.getMaxAngleWithTool( self, true )		
			self.acTurnStage     = self.acTurnStage + 1;					
			self.turnTimer       = self.acDeltaTimeoutRun;
		end
		
--==============================================================				
-- turn outside II
	elseif self.acTurnStage == 85 then	
		angle              = AIVehicleExtension.getMaxAngleWithTool( self, true )			

		if turnAngle > 90 then
			self.acTurnStage     = self.acTurnStage + 1					
			self.turnTimer       = self.acDeltaTimeoutRun
		end

--==============================================================				
-- turn 90°
	elseif self.acTurnStage == 86 then
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true );
		
		detected  = false
		local nav = true
		if     fruitsDetected
				or ( math.abs( turnAngle ) >= 170 
				 and math.abs( AutoSteeringEngine.getToolAngle( self ) ) <= AIVEGlobals.maxToolAngle2 ) then
	--if math.abs( turnAngle ) >= 180-math.deg( angleMax ) then
			nav = false
			detected, angle2, border = AIVehicleExtension.detectAngle( self )
		end		
		
		AIVehicleExtension.debugPrint( self, string.format("T84: x: %0.3fm z: %0.3fm test: %0.3fm fd: %s det: %s ta: %0.1f° to: %0.1f°", x, z, AutoSteeringEngine.getToolDistance( self ), tostring(fruitsDetected), tostring(detected), turnAngle, math.deg(AutoSteeringEngine.getToolAngle( self )) ) )
		
		if detected then
			self.acTurnStage   = -2
			self.turnTimer     = self.acDeltaTimeoutNoTurn;
			AIVehicleExtension.setAIImplementsMoveDown(self,true);
		elseif nav or z < math.min( 0, AutoSteeringEngine.getToolDistance( self ) ) - 5 then
			self.turnTimer     = self.acDeltaTimeoutNoTurn;
			angle  = nil
			angle2 = AutoSteeringEngine.navigateToSavePoint( self, 3, AIVehicleExtension.navigationFallbackRetry )
		end
			
--==============================================================				
--==============================================================				
-- 90° new turn with reverse
	elseif self.acTurnStage == 90 then
		self.acTurnStage   = self.acTurnStage + 1;					
		self.turnTimer     = self.acDeltaTimeoutRun;
		angle              = AIVehicleExtension.getMaxAngleWithTool( self, false )

		AIVehicleExtension.setAIImplementsMoveDown(self,false);
		
--==============================================================				
-- reduce tool angle 
	elseif self.acTurnStage == 91 then
		
		local toolAngle = AutoSteeringEngine.getToolAngle( self )
		
		angle  = nil;		
		angle2 = math.min( math.max( -toolAngle, -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle );
		
		if math.abs(math.deg(toolAngle)) < 5 then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutRun;
		end
		
--==============================================================				
-- move backwards (straight)		
	elseif self.acTurnStage == 92 then		
		moveForwards = false;					
		--angle  = nil;
		--local toolAngle = AutoSteeringEngine.getToolAngle( self );
		--angle2 = math.min( math.max( toolAngle, -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle );
		angle  = AIVehicleExtension.getStraighBackwardsAngle( self, 0 )

		local _,z, allowedToDrive = AIVehicleExtension.getTurnVector( self );
		
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self );
		local dist   = math.max( turn75.radius + 2, 1.15 * turn75.radius )
		if -z > dist then				
	--if z < -self.acDimensions.radius then				
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutRun;
			self.waitForTurnTime = g_currentMission.time + self.turnTimer;
			angle = 0
		end

--==============================================================				
-- turn 90°
	elseif self.acTurnStage == 93 then		
	--angle = AIVehicleExtension.getMaxAngleWithTool( self, true )
	--
		local onTrack 
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self );

		angle2, onTrack = AutoSteeringEngine.navigateToSavePoint( self, 2, nil, turn75 )		
		
		local ta = AIVehicleExtension.getToolAngle( self )
		
		self:acDebugPrint("T93: "..degToString( turnAngle ).." "..radToString(ta))
		
		if     turnAngle > 90 - angleOffsetStrict + math.deg( ta ) then
			if math.abs( ta ) < AIVEGlobals.maxToolAngleF * self.acDimensions.maxSteeringAngle then
				self.acTurnStage = self.acTurnStage + 4
				self.turnTimer   = self.acDeltaTimeoutRun;
			else 
				self.acTurnStage = self.acTurnStage + 1
				self.turnTimer   = self.acDeltaTimeoutRun;
			end
		elseif onTrack then
			angle  = nil
		else
			self.acTurnStage = self.acTurnStage + 2
			self.turnTimer   = self.acDeltaTimeoutRun;
		end
		
--==============================================================				
-- turn 90° II
	elseif self.acTurnStage == 94 then		
	--angle = AIVehicleExtension.getMaxAngleWithTool( self, true )
	--
		local onTrack 
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self );

		angle2, onTrack = AutoSteeringEngine.navigateToSavePoint( self, 2, nil, turn75 )		

		local ta = AIVehicleExtension.getToolAngle( self )
		self:acDebugPrint("T94: "..degToString( turnAngle ).." "..radToString(ta))		
		
		
		if      math.abs( turnAngle - 90 - math.deg( ta ) ) < angleOffsetStrict
				and math.abs( turnAngle - 90 )                  < angleOffset       then
			if math.abs( ta ) < AIVEGlobals.maxToolAngleF * self.acDimensions.maxSteeringAngle then
				self.acTurnStage = self.acTurnStage + 3
				self.turnTimer   = self.acDeltaTimeoutRun;
			else
				self.acTurnStage = self.acTurnStage + 1
				self.turnTimer   = self.acDeltaTimeoutRun;
			end
		elseif onTrack then
			angle  = nil
		else
			self.acTurnStage = self.acTurnStage + 1
			self.turnTimer   = self.acDeltaTimeoutRun;
		end
		
--==============================================================				
-- reduce tool angle I
	elseif self.acTurnStage == 95 then
		
		local turn75 = AutoSteeringEngine.getMaxSteeringAngle75( self );
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self );
		if self.acParameters.leftAreaActive then x = -x end
		
	--angle = -turn75.alpha
		angle = -0.3333 * turn75.alpha
		
		self:acDebugPrint("T95: "..radToString( angle ).." "..degToString( turnAngle ).." "..tostring(x).." / "..tostring(z).." "..radToString( math.atan2( z, x )))

		if turnAngle > 90 - angleOffsetStrict + 0.5 * math.deg( math.abs( AIVehicleExtension.getToolAngle( self ) ) ) then
			self.acTurnStage = self.acTurnStage + 1				
			self.turnTimer   = self.acDeltaTimeoutStop;
		end
		
--==============================================================				
-- reduce tool angle II
	elseif self.acTurnStage == 96 then
		
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self );
		if self.acParameters.leftAreaActive then x = -x end		
		local target = 90 -- + angleOffset
		if x > 1 then
			target = target + math.deg( math.atan2( z, x ) )
		end
		
		local newTurnAngle = turnAngle - target 
		local f = 1
		if self.articulatedAxis == nil then
			f = 2
		end

		local ta = AIVehicleExtension.getToolAngle( self )
		
		angle = Utils.clamp( f * ( math.rad( newTurnAngle ) - math.min( 0, ta ) ), AIVehicleExtension.getMaxAngleWithTool( self, true ), AIVehicleExtension.getMaxAngleWithTool( self, false ) )

		self:acDebugPrint("T96: "..radToString( angle ).." "..radToString( ta ).." "..degToString( turnAngle ).." "..degToString( newTurnAngle ).." "..tostring(x).." / "..tostring(z).." "..radToString( math.atan2( z, x )))
		
		if      math.abs( newTurnAngle + math.deg( ta ) ) < angleOffsetStrict
				and math.abs( ta ) < AIVEGlobals.maxToolAngleF * self.acDimensions.maxSteeringAngle then
			self.acTurnStage = self.acTurnStage + 1;					
			self.turnTimer   = self.acDeltaTimeoutRun;
			angle            = 0
		elseif x > 20 then
			self.acTurnStage = self.acTurnStage + 1;					
			self.turnTimer   = self.acDeltaTimeoutRun;
			angle            = 0
		end
		
--==============================================================				
-- get tool angle over 90
	elseif self.acTurnStage == 97 then		
		angle    = math.min( -0.1 * self.acDimensions.maxSteeringAngle, math.rad( turnAngle - 90 ) )
		if turnAngle >= 90 + math.deg( AIVehicleExtension.getToolAngle( self ) ) + angleOffsetStrict then
			self.acTurnStage = self.acTurnStage + 1;					
			self.turnTimer   = self.acDeltaTimeoutRun;
			angle            = 0
		end
		
--==============================================================				
-- get turn angle to exactly 90°
	elseif self.acTurnStage == 98 then		
		local newTurnAngle = turnAngle - 90 
		angle = math.rad( newTurnAngle )
		if math.abs( newTurnAngle ) < angleOffsetStrict then
			self.acTurnStage = self.acTurnStage + 1;					
			self.turnTimer   = self.acDeltaTimeoutRun;
			angle            = 0
			self.waitForTurnTime = g_currentMission.time + self.turnTimer;
		end
		
--==============================================================				
-- move backwards (straight)		
	elseif self.acTurnStage == 99 then		
		moveForwards = false;					
	
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self );
		if self.acParameters.leftAreaActive then x = -x end

		local ta = AIVehicleExtension.getToolAngle( self )
		
		local xMin, xMax, zMin, zMax = AutoSteeringEngine.getToolsTurnVector( self )
		if self.acParameters.leftAreaActive then 
			xMin = -xMin
			xMax = -xMax
			ta   = -ta
		end
		
		local a2
		detected, a2, border = AIVehicleExtension.detectAngle( self, AIVEGlobals.smoothMax )
		if not self.acParameters.leftAreaActive then
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
		
		angle  = AIVehicleExtension.getStraighBackwardsAngle( self, target )
		
		self:acDebugPrint( "T97: "..degToString( turnAngle ).." "..radToString( ta ).." "..radToString( a2 ).." "..degToString( target ).." "..string.format("%2.3fm %2.3fm / %2.3fm", x, z, -self.acDimensions.toolDistance) )
		
		if      x < -self.acDimensions.toolDistance 
				and ( detected or x < -15 ) 
			--and a2 <= 0
			--and turnAngle <= 90
				and not fruitsDetected then				
			if self.turnTimer < 0 then
				self.acTurnStage = -1
				self.waitForTurnTime = g_currentMission.time + self.turnTimer;
				angle = a2
			end
		else
			self.turnTimer = self.acDeltaTimeoutRun
		end

--==============================================================				
--==============================================================				
-- going back w/o reverse
	elseif self.acTurnStage == 100 then
		self.acTurnStage   = self.acTurnStage + 1;					
		self.turnTimer     = self.acDeltaTimeoutRun;
		angle              = AIVehicleExtension.getMaxAngleWithTool( self, false )

		AIVehicleExtension.setAIImplementsMoveDown(self,false,true);
	
--==============================================================				
-- turn 180° I
	elseif self.acTurnStage == 101 then
		angle = AIVehicleExtension.getMaxAngleWithTool( self, true )
			
		if math.abs( turnAngle ) > 180 - angleOffset then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutRun;
			angle              = 0
		end

--==============================================================				
-- turn 180° I
	elseif self.acTurnStage == 102 then
		angle = 0

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self );
		if z < -5 then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutRun;
			angle              = AIVehicleExtension.getMaxAngleWithTool( self, true )
		end
		
--==============================================================				
-- turn 180° II
	elseif self.acTurnStage == 103 then
		angle = AIVehicleExtension.getMaxAngleWithTool( self, true )
			
		if math.abs( turnAngle ) < angleOffset then
			self.acTurnStage   = -1				
			self.turnTimer     = self.acDeltaTimeoutRun;
			angle              = 0
		end

	
--==============================================================				
--==============================================================				
-- going back w/o reverse at the end of a turn
	elseif self.acTurnStage == 105 then
		self.acTurnStage   = self.acTurnStage + 1;					
		self.turnTimer     = self.acDeltaTimeoutRun;
		angle              = AIVehicleExtension.getMaxAngleWithTool( self, false )

		AIVehicleExtension.setAIImplementsMoveDown(self,false,true);
	
--==============================================================				
-- turn 180° I
	elseif self.acTurnStage == 106 then
		angle = AIVehicleExtension.getMaxAngleWithTool( self, true )
			
		if math.abs( turnAngle ) < angleOffset then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutRun;
			angle              = 0
		end

--==============================================================				
-- turn 180° I
	elseif self.acTurnStage == 107 then
		angle = 0

		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self );
		if z > 5 then
			self.acTurnStage   = self.acTurnStage + 1;					
			self.turnTimer     = self.acDeltaTimeoutRun;
			angle              = AIVehicleExtension.getMaxAngleWithTool( self, true )
		end
		
--==============================================================				
-- turn 180° II
	elseif self.acTurnStage == 108 then
		angle = AIVehicleExtension.getMaxAngleWithTool( self, true )
			
		if math.abs( turnAngle ) > 180 - angleOffset then
			self.acTurnStage   = -1				
			self.turnTimer     = self.acDeltaTimeoutRun;
			angle              = 0
		end

	
--==============================================================				
--==============================================================				
-- forward and reduce tool angle
	elseif  110 <= self.acTurnStage and self.acTurnStage < 125 then
		local turnStageMod = ( self.acTurnStage - 110 ) % 5
		local x,z, allowedToDrive = AIVehicleExtension.getTurnVector( self, true, self.acTurnStage >= 120 );
		if self.acParameters.leftAreaActive then x = -x end

		local turnMode, targetS, targetA, targetT
			
		if     self.acTurnStage < 115 then
			turnMode = 3
			targetS  = x
			targetT  = 180
		elseif self.acTurnStage < 120 then
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
		
			if self.turnTimer < 0 then
				AIVehicleExtension.setAIImplementsMoveDown(self,false,true);
			end
			
			local onTrack  = false
			angle2, onTrack = AutoSteeringEngine.navigateToSavePoint( self, turnMode )
			
			if      math.abs( targetS ) < 0.5
					and math.abs( targetA ) < angleOffset then
				if math.abs( math.deg( AIVehicleExtension.getToolAngle( self ) ) ) < angleOffsetStrict then
					self.acTurnStage = self.acTurnStage + 2;					
					self.turnTimer   = self.acDeltaTimeoutRun;
					angle            = 0
				elseif not onTrack then
					self.acTurnStage = self.acTurnStage + 1;					
					self.turnTimer   = self.acDeltaTimeoutRun;
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
				angle = Utils.clamp( a, AIVehicleExtension.getMaxAngleWithTool( self, true ), AIVehicleExtension.getMaxAngleWithTool( self, false ) ) 
			end
			
			AIVehicleExtension.debugPrint( self, tostring(self.acTurnStage).." "..tostring(onTrack).." "..degToString( targetA ).." "..tostring( targetS ).." "..radToString( angle2 ).." "..radToString( angle ).." "..tostring(x).." "..tostring(z) )
			
	--==============================================================				
	-- forward and reduce tool angle
		elseif turnStageMod == 1 then

			local newTurnAngle = math.rad( targetA )
			
			angle = Utils.clamp( newTurnAngle, AIVehicleExtension.getMaxAngleWithTool( self, true ), AIVehicleExtension.getMaxAngleWithTool( self, false ) )

			if      math.abs( math.deg( newTurnAngle ) ) < angleOffset
					and math.abs( math.deg( AIVehicleExtension.getToolAngle( self ) ) ) < angleOffsetStrict then
				AIVehicleExtension.setAIImplementsMoveDown(self,false);
				self.acTurnStage = self.acTurnStage + 1;					
				self.turnTimer   = self.acDeltaTimeoutRun;
				angle            = 0
			end
		
	--==============================================================				
	-- backwards and reduce tool angle
		elseif turnStageMod == 2 then
		
			moveForwards = false
			angle        = AIVehicleExtension.getStraighBackwardsAngle( self, targetT )
			
			if z < 0 and not fruitsDetected then
				detected = AIVehicleExtension.detectAngle( self )
				if detected then
					self.acTurnStage = self.acTurnStage + 1
					self.turnTimer   = self.acDeltaTimeoutRun;
				end
			end
		
	--==============================================================				
	-- backwards and reduce tool angle
		elseif turnStageMod == 3 then

			moveForwards     = false
			angle            = AIVehicleExtension.getStraighBackwardsAngle( self, targetT )
			detected         = AIVehicleExtension.detectAngle( self )
			if not detected then
				self.turnTimer   = self.acDeltaTimeoutRun;
			elseif self.turnTimer < 0 then
				self.acTurnStage = self.acTurnStage + 1
				self.turnTimer   = self.acDeltaTimeoutRun;
			end
		
	--==============================================================				
	-- forward and reduce tool angle
		else --if turnStageMod == 4 then

			moveForwards     = true
			detected, angle2 = AIVehicleExtension.detectAngle( self )
			if not detected then
				if self.turnTimer < 0 or fruitsDetected then
					AutoSteeringEngine.shiftTurnVector( self, 0.5 )
					self.acTurnStage = self.acTurnStage - 4
				end
			elseif fruitsDetected then
				if self.acTurnStage < 115 then
					self.acTurnStage = -2
				else
					self.acTurnStage = -1
				end
				self.turnTimer   = self.acDeltaTimeoutNoTurn;
				AIVehicleExtension.setAIImplementsMoveDown(self,true);
			else
				self.turnTimer   = self.acDeltaTimeoutRun;
			end
		end
--==============================================================				
--==============================================================				
-- searching...
	elseif ( -3 <= self.acTurnStage and self.acTurnStage < 0 )
			or (-13 <= self.acTurnStage and self.acTurnStage < -10 )then
		moveForwards     = true;

		if self.acTurnStage >= -3 then
			self.acTurnStage = self.acTurnStage -20;
			self.turnTimer   = self.acDeltaTimeoutNoTurn;
		
		elseif  fruitsAll 
				and detected 
				and self.acTurnInTheMiddle == nil
				and not ( self.acFullAngle ) then
			if self.acClearTraceAfterTurn then
				AutoSteeringEngine.clearTrace( self );
				AutoSteeringEngine.saveDirection( self, false, not turn2Outside );
			end
			AutoSteeringEngine.ensureToolIsLowered( self, true )
			self.acTurnStage        = 0;
			self.acTurn2Outside     = false;
			self.turnTimer          = self.acDeltaTimeoutNoTurn;
			self.acTurnOutsideTimer = math.max( self.turnTimer, self.acDeltaTimeoutNoTurn );
			self.aiRescueTimer      = self.acDeltaTimeoutStop;
		end;
		
--==============================================================				
	elseif -23 <= self.acTurnStage and self.acTurnStage < -20 then
		--AutoSteeringEngine.ensureToolIsLowered( self, true )
		AIVehicleExtension.setAIImplementsMoveDown(self,true);
		self.acTurnStage = self.acTurnStage + 10;					
				
--==============================================================				
-- threshing...					
	elseif self.acTurnStage == 0 then		
		moveForwards = true;
		
		local doTurn = false;
		local uTurn  = false;
		
		local turnTimer = self.turnTimer
	--if fruitsDetected and turn2Outside then
	--	turnTime = self.acTurnOutsideTimer 
	--end
		
		if     detected and ( fruitsDetected or turn2Outside ) then
			doTurn = false
			self.turnTimer   	      = math.max(self.turnTimer,self.acDeltaTimeoutRun);
			self.acTurnOutsideTimer = math.max( self.acTurnOutsideTimer, self.acDeltaTimeoutNoTurn );
		elseif turn2Outside then
			if fruitsDetected and turnTimer < 0 then
				doTurn = true
				uTurn  = false
				self.acClearTraceAfterTurn = true -- false
			end
		elseif fruitsDetected then		
			doTurn = false
		elseif turnTimer < 0 then 
			doTurn = true
			if     detected then
				doTurn                     = false
				self.acTurnStage           = -1
				self.aiRescueTimer         = 3 * self.acDeltaTimeoutStop;
				angle                      = 0			
				self.acClearTraceAfterTurn = false
				self.turnTimer             = self.acDeltaTimeoutWait;
				AutoSteeringEngine.initTurnVector( self, false, true )
				AIVehicleExtension.setAIImplementsMoveDown(self,false);
				AutoSteeringEngine.ensureToolIsLowered( self, false )
			elseif AutoSteeringEngine.getTraceLength(self) < 10 then		
				uTurn = false
				self.acClearTraceAfterTurn = false
			else
				uTurn = self.acParameters.upNDown
				self.acClearTraceAfterTurn = true
			end
		end
		
		if doTurn then		
			self.acTurn2Outside = false
			self.aiRescueTimer  = 3 * self.acDeltaTimeoutStop;
			angle               = 0
			
			AutoSteeringEngine.initTurnVector( self, uTurn, turn2Outside )

			if not turn2Outside then 
				local dist    = math.floor( 2.5 * math.max( 10, self.acDimensions.distance ) )
				local wx,_,wz = AutoSteeringEngine.getAiWorldPosition( self )
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
							if      AutoSteeringEngine.isChainPointOnField( self, lx-0.5, lz-0.5 ) 
									and AutoSteeringEngine.isChainPointOnField( self, lx-0.5, lz+0.5 ) 
									and AutoSteeringEngine.isChainPointOnField( self, lx+0.5, lz-0.5 ) 
									and AutoSteeringEngine.isChainPointOnField( self, lx+0.5, lz+0.5 ) 
									then
								local x = lx - 0.5
								local z1= lz - 0.5
								local z2= lz + 0.5
								if AutoSteeringEngine.hasFruitsSimple( self, x,z1,x,z2, 1 ) then
									stop = false
									break
								end
							end
						end
					end
				end
						
				if stop then
					self:stopAIVehicle()
					return
				end
			end
			
			if     uTurn               then
		-- the U turn
				--invert turn angle because we will swap left/right in about 10 lines
				
				turnAngle = -turnAngle;
				if     self.acTurnMode == "O" then				
					self.acTurnStage = 70				
				elseif self.acTurnMode == "8" then
					self.acTurnStage = 80				
				elseif self.acTurnMode == "A" then
					self.acTurnStage = 50;
				elseif self.acTurnMode == "Y" then
					self.acTurnStage = 40;
				else--if self.acTurnMode == "T" then
					self.acTurnStage = 20;
					
				--if noReverseIndex > 0 and AutoSteeringEngine.noTurnAtEnd( self ) then
				--	self.acTurn2Outside = true
				--end
				end
				self.turnTimer = self.acDeltaTimeoutWait;
				self.waitForTurnTime = g_currentMission.time + self.turnTimer;
				if self.acTurnStage == 20 and self.acTurn2Outside then
				else
					self.acParameters.leftAreaActive  = not self.acParameters.leftAreaActive;
					self.acParameters.rightAreaActive = not self.acParameters.rightAreaActive;
					AIVehicleExtension.sendParameters(self);
				end					
				AutoSteeringEngine.setChainStraight( self );	
			elseif turn2Outside then
				self.acTurn2Outside = true
		-- turn to outside because we are in the middle of the field
				if     self.acTurnMode == "C" 
						or self.acTurnMode == "8" 
						or self.acTurnMode == "O" then
					self.acTurnStage = 100
				else	
					self.acTurnStage = 120
				end
				self.turnTimer = self.acDeltaTimeoutWait;
			elseif self.acTurnMode == "C" 
					or self.acTurnMode == "8" 
					or self.acTurnMode == "O" then
		-- 90° turn w/o reverse
				self.acTurnStage = 5;
				self.turnTimer = self.acDeltaTimeoutWait;
				self.waitForTurnTime = g_currentMission.time + self.turnTimer;
				--if not self.acParameters.upNDown
				--		or AutoSteeringEngine.getTraceLength(self) < 10 then
					self.acTurn2Outside = false
				--else
				--	self.acTurn2Outside = true
				--	self.acParameters.leftAreaActive  = not self.acParameters.leftAreaActive;
				--	self.acParameters.rightAreaActive = not self.acParameters.rightAreaActive;
				--	AIVehicleExtension.sendParameters(self);
				--end
			elseif self.acTurnMode == "L" 
					or self.acTurnMode == "A" 
					or self.acTurnMode == "Y" then
		-- 90° turn with reverse
				self.acTurnStage = 1;
				self.turnTimer = self.acDeltaTimeoutWait;
			elseif self.acTurnMode == "7" then 
		-- 90° new turn with reverse
				self.acTurnStage = 90;
				self.turnTimer = self.acDeltaTimeoutWait;
			else
		-- 90° turn with reverse
				self.acTurnStage = 30;
				self.turnTimer = self.acDeltaTimeoutWait;
			end
		elseif detected or fruitsDetected then
			AutoSteeringEngine.saveDirection( self, true, not turn2Outside );
		end
		
--==============================================================				
--==============================================================				
-- error!!!
	else
		allowedToDrive = false;						
		self.atHud.InfoText = string.format(AIVEHud.getText("AUTO_TRACTOR_ERROR")..": %i",self.acTurnStage);
		print(self.atHud.InfoText);
		self:stopAIVehicle();
		return;
	end;                

	if lastAcTurnStage ~= self.acTurnStage then
		self.aiRescueTimer = math.max( self.aiRescueTimer, self.acDeltaTimeoutStop )
	end
	
--==============================================================				
--==============================================================				
	if math.abs( self.acAxisSide ) > 0.1 then --if AIVEGlobals.devFeatures > 0 and math.abs( self.acAxisSide ) > 0.3 then 
		detected = false
		border   = 0
		angle    = nil
		angle2   = - self.acAxisSide * self.acDimensions.maxSteeringAngle
		self.turnTimer = self.turnTimer + dt;
		self.waitForTurnTime = self.waitForTurnTime + dt;
		if self.acTurnStage <= 0 then
			self.aiRescueTimer = self.aiRescueTimer + dt;
		end			
	end			
--==============================================================				
--==============================================================				

	if      not self.acImplementsMoveDown 
			and ( not moveForwards or not allowedToDrive ) then
		AutoSteeringEngine.ensureToolIsLowered( self, false )
	end
			
--==============================================================				
	if self.acTurnStage > 0 then
		self.acFullAngle = true
	end

	if     self.acTurnStage == -3 and detected then
		AIVehicleExtension.setStatus( self, 2 )
	elseif self.acTurnStage == -3 then
		AIVehicleExtension.setStatus( self, 0 )
	elseif  self.acIamDetecting and detected then
		AIVehicleExtension.setStatus( self, 1 )
	elseif self.acTurnStage <= 0 then
		AIVehicleExtension.setStatus( self, 2 )
	elseif detected then
		AIVehicleExtension.setStatus( self, 2 )
	else
		AIVehicleExtension.setStatus( self, 0 )
	end
	
	local acceleration   = 0;					
	local slowAngleLimit = self.acDimensions.maxLookingAngle;
	local useReduceSpeed = false;
	
	if self.isMotorStarted and speedLevel ~= 0 and self.fuelFillLevel > 0 then
		acceleration = 1.0;
	end;		
	
	if      allowedToDrive
			and self.acIsAnimPlaying
			and AIVehicleExtension.waitForAnimTurnStage( self ) then
		AIVehicleExtension.setStatus( self, 3 )
		speedLevel = 5
	end
	
	if speedLevel == 0 then
		allowedToDrive = false
		speedLevel     = 1
	elseif self.acTurnStage > 0 then
		speedLevel = 4
		slowAngleLimit = self.acDimensions.maxSteeringAngle;
	elseif not detected and self.acTurnStage >= -2 then
		speedLevel = 1
		slowAngleLimit = self.acDimensions.maxSteeringAngle;
	end;
	
	if not allowedToDrive then
		self.acHighPrec = false
	elseif self.acTurnStage > 0 then
		self.acHighPrec = true
	end
	
	if self.acTurnStage > 0 then
		detected = false;
	end
	
	if angle == nil then
		if angle2 == nil then
			angle = 0;
		else
			angle = angle2;
		end
	elseif not self.acParameters.leftAreaActive then
		angle = -angle;		
	end
	
	if      self.waitForTurnTime > g_currentMission.time 
			and self.acLastSteeringAngle == nil then
		self.acLastSteeringAngle = angle 
	end
	
	if AIVEGlobals.devFeatures > 0 then
		self.atHud.InfoText = self.atHud.InfoText .. string.format(" a: %3i ",math.deg(angle))..tostring(detected)
	end

	local aiSteeringSpeed = self.aiSteeringSpeed;
	if detected and 
			--(  math.abs( angle ) > 0.5 * angleMax
			--or math.abs( angle - AutoSteeringEngine.currentSteeringAngle( self ) )  > 0.25 * angleMax
			(  math.abs( angle ) > 0.5 * self.acDimensions.maxSteeringAngle
			or math.abs( angle - AutoSteeringEngine.currentSteeringAngle( self ) )  > AIVEGlobals.maxToolAngleF * self.acDimensions.maxSteeringAngle
			--or self.acTurnStage == -3
			--or self.acTurnStage == -13
			--or -3 <= self.acTurnStage and self.acTurnStage < 0 ) then
			) then
		detected = false
	end	
	
	if not detected and 0 < speedLevel and speedLevel < 4 then
		speedLevel = 4
	elseif speedLevel ~= 2 and speedLevel ~= 3 and speedLevel ~= 4 then
		speedLevel = 1
	end
		
	if     speedLevel == 4 then
		aiSteeringSpeed = 0.5 * aiSteeringSpeed
	else
		aiSteeringSpeed = math.max( 1, speedLevelFactor ) * aiSteeringSpeed
	end
	
	angle = math.min( math.max( angle, -self.acDimensions.maxSteeringAngle ), self.acDimensions.maxSteeringAngle )
	
	if AIVEGlobals.devFeatures > 0 then
		self.atHud.InfoText = self.atHud.InfoText .." "..tostring(allowedToDrive).." "..tostring(moveForwards).." "..tostring(speedLevel)
	end

	AutoSteeringEngine.steer( self, dt, angle, aiSteeringSpeed, detected );
	AutoSteeringEngine.drive( self, dt, acceleration, allowedToDrive, moveForwards, speedLevel, useReduceSpeed, 0.75 );
	
  local colDirX = math.sin( angle );
	local colDirZ = math.cos( angle );

	if not moveForwards then
		colDirZ = -colDirZ;
	end

	if self.acParameters.inverted then
		colDirX = -colDirX;
		colDirZ = -colDirZ;
	end

	for triggerId, _ in pairs(self.numCollidingVehicles) do
		AIVehicleUtil.setCollisionDirection(self.aiTractorDirectionNode, triggerId, colDirX, colDirZ)
	end

end

------------------------------------------------------------------------
-- AIVehicleExtension:navigationFallbackRetry
------------------------------------------------------------------------
function AIVehicleExtension:navigationFallbackRetry( uTurn )
	local x, z, allowedToDrive = AIVehicleExtension.getTurnVector( self, uTurn )
	local a = AutoSteeringEngine.normalizeAngle( math.pi - AutoSteeringEngine.getTurnAngle( self )	)
	local angle = 0

	if z < 1 and math.abs( a ) > 0.9 * math.pi then
		angle = 0
	elseif x > 0 then
		-- D: turn away from target point for next try
		angle = -self.acDimensions.maxSteeringAngle
	else
		-- E: turn away from target point for next try
		angle =  self.acDimensions.maxSteeringAngle
	end
	
	return angle
end

------------------------------------------------------------------------
-- AIVehicleExtension:navigationFallbackRotateMinus
------------------------------------------------------------------------
function AIVehicleExtension:navigationFallbackRotateMinus( uTurn )
	local angle = -self.acDimensions.maxSteeringAngle					
	if not self.acParameters.leftAreaActive then
		angle = -angle;		
	end	
	return angle
end

------------------------------------------------------------------------
-- AIVehicleExtension:getTurnVector
------------------------------------------------------------------------
function AIVehicleExtension:getTurnVector( uTurn, turn2Outside )

	local x, z = AutoSteeringEngine.getTurnVector( self, Utils.getNoNil( uTurn, false ), Utils.getNoNil( turn2Outside, self.acTurn2Outside ) )
 
	return x, z, true
end

------------------------------------------------------------------------
-- AIVehicleExtension:getToolAngle
------------------------------------------------------------------------
function AIVehicleExtension:getToolAngle()

	local toolAngle = AutoSteeringEngine.getToolAngle( self )
	if not self.acParameters.leftAreaActive then
		toolAngle = -toolAngle;
	end
	
	return toolAngle
end
	
------------------------------------------------------------------------
-- AIVehicleExtension:getStraighBackwardsAngle
------------------------------------------------------------------------
function AIVehicleExtension:getStraighBackwardsAngle( iTarget )

	local target = math.rad( Utils.getNoNil( iTarget, 0 ) )

	local turnAngle = AutoSteeringEngine.getTurnAngle( self ) 
	if self.acParameters.leftAreaActive then
		turnAngle = -turnAngle
	end
	
	local ta  = turnAngle
	turnAngle = AutoSteeringEngine.normalizeAngle( turnAngle - target )
	
	AIVehicleExtension.debugPrint( self, "gSBA init: target: "..degToString( iTarget ).." current: "..radToString( ta ).." delta: "..radToString( turnAngle ))
	
	return AIVehicleExtension.getStraighBackwardsAngle2( self, turnAngle, target )
end

------------------------------------------------------------------------
-- AIVehicleExtension:getStraighBackwardsAngle2
------------------------------------------------------------------------
function AIVehicleExtension:getStraighBackwardsAngle2( turnAngle, iTarget )
	
	local taJoints = AutoSteeringEngine.getTaJoints1( self, self.acRefNode, self.acDimensions.zOffset )

	if 	 	 AutoSteeringEngine.tableGetN( taJoints  ) < 1
			or self.aseDirectionBeforeTurn   == nil
			or self.aseDirectionBeforeTurn.a == nil then
		AIVehicleExtension.debugPrint( self, "gSBA: no tools with joint found: "..radToString( -turnAngle ))
		return -turnAngle
	end

	local yv = -self.aseDirectionBeforeTurn.a - math.pi
	if iTarget ~= nil then
		if self.acParameters.leftAreaActive then
			yv = AutoSteeringEngine.normalizeAngle( yv + iTarget )
		else
			yv = AutoSteeringEngine.normalizeAngle( yv - iTarget )
		end
	end
	
	local yt = AutoSteeringEngine.getWorldYRotation( taJoints[1].nodeTrailer )
	
	local maxWorldRatio = 0.75 / AutoSteeringEngine.tableGetN( taJoints  )
	local ratio  = Utils.clamp( 3 * AutoSteeringEngine.normalizeAngle( yv - yt ) / AIVEGlobals.maxToolAngle, -maxWorldRatio, maxWorldRatio )
	local target = ratio

	local sumTargetFactors = 0
	for _,joint in pairs( taJoints ) do
		sumTargetFactors = sumTargetFactors + joint.targetFactor
	end
	
	local maxToolDegrees = AIVEGlobals.maxToolAngle / sumTargetFactors
	for _,joint in pairs( taJoints ) do
		target    = joint.targetFactor * ratio
		degree    = AutoSteeringEngine.getRelativeYRotation( joint.nodeVehicle, joint.nodeTrailer )
		if joint.otherDirection then
			degree  = AutoSteeringEngine.normalizeAngle( degree + math.pi )
		end
		angle     = Utils.clamp( degree / maxToolDegrees, -1, 1 )	
		ratio     = Utils.clamp( target + 1.5 * ( angle - ratio ), -1, 1 )
	end
	
	angle = ratio * self.acDimensions.maxSteeringAngle
	
	if not self.acParameters.leftAreaActive then
		angle = -angle 
	end
	
	AIVehicleExtension.debugPrint( self, "gSBA: current: "..radToString( yt ).." target: "..radToString( yv ).." => angle: "..radToString( angle ).." ("..tostring( self.acParameters.leftAreaActive ).." / "..tostring( iTarget ).." / "..radToString( self.aseDirectionBeforeTurn.a )..")")
	
	return angle 
end
	
------------------------------------------------------------------------
-- AIVehicleExtension:getToolAngle
------------------------------------------------------------------------
function AIVehicleExtension:getStraighForwardsAngle( iTarget )

	local target = math.rad( Utils.getNoNil( iTarget, 0 ) )

	local toolAngle = AutoSteeringEngine.getToolAngle( self )
	local turnAngle = AutoSteeringEngine.getTurnAngle( self ) 
	if self.acParameters.leftAreaActive then
		turnAngle = -turnAngle
	else
		toolAngle = -toolAngle
	end
	turnAngle = turnAngle - target 
	
	angle = 0
	
	if      math.abs( toolAngle ) > math.abs( turnAngle ) then
		angle = -toolAngle 
	else
		angle = turnAngle 
	end
	
	AIVehicleExtension.debugPrint( self, "gSFA: "..degToString( iTarget ).." "..radToString( toolAngle ).." "..radToString( turnAngle ).." => "..radToString( angle ))
	
	angle = Utils.clamp( angle, -self.acDimensions.maxSteeringAngle, self.acDimensions.maxSteeringAngle )

	return angle 
end
	
------------------------------------------------------------------------
-- AIVehicleExtension:getLimitedToolAngle
------------------------------------------------------------------------
function AIVehicleExtension:getLimitedToolAngle( iLimit )

	local toolAngle = AIVehicleExtension.getToolAngle( self )
	local limit     = Utils.getNoNil( iLimit, 0.5 * self.acDimensions.maxSteeringAngle )
	
	if     toolAngle >=  limit then
		toolAngle =  limit
	elseif toolAngle <= -limit then
		toolAngle = -limit
	else
		local x   = toolAngle / limit
		toolAngle = toolAngle * 2 / ( 1 + x^2 )
	end
	
	return toolAngle
end

