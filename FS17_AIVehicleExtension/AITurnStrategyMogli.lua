
--
-- AITurnStrategyMogli
--

AITurnStrategyMogli = {}
local AITurnStrategyMogli_mt = Class(AITurnStrategyMogli, AITurnStrategy)

function AITurnStrategyMogli:new(customMt)
	if customMt == nil then
		customMt = AITurnStrategyMogli_mt
	end
	local self = AITurnStrategy:new(customMt)
	return self
end

--============================================================================================================================
-- setAIVehicle
--============================================================================================================================
function AITurnStrategyMogli:setAIVehicle(vehicle)
	self.vehicle = vehicle
end

--============================================================================================================================
-- addDebugText
--============================================================================================================================
function AITurnStrategyMogli:addDebugText( s )
	if self.vehicle ~= nil and type( self.vehicle.aiveAddDebugText ) == "function" then
		self.vehicle:aiveAddDebugText( s ) 
	end
end

--============================================================================================================================
-- startTurn
--============================================================================================================================
function AITurnStrategyMogli:startTurn( turnData )
	AITurnStrategyMogli:superClass().startTurn( self, turnData )

	self.lastDirection = nil
	
	self.vehicle.aiveChain.inField = false
	self.vehicle.aiveChain.isAtEnd = false
	
	AIVehicleExtension.setAIImplementsMoveDown(self.vehicle,false)
	
	self.lastDirection = nil
	self.stageId       = 0		
	self.dtSum         = 0
	self.activeStage   = nil
	self.animWaitTimer = nil
	self.noSneakTimer  = nil

end

--============================================================================================================================
-- onEndTurn
--============================================================================================================================
function AITurnStrategyMogli:onEndTurn( turnLeft )
	AITurnStrategyMogli:superClass().onEndTurn( self, turnLeft )

	local immediate = false
	if     self.vehicle.aiveHas.combine then
		immediate = true
	elseif AutoSteeringEngine.hasFruits( self.vehicle ) then
		immediate = true
	end
	
	AIVehicleExtension.setAIImplementsMoveDown( self.vehicle, true, immediate )
	
	self.lastDirection = nil
	self.stageId       = 0		
	self.dtSum         = 0
	self.activeStage   = nil
	self.animWaitTimer = nil
	self.noSneakTimer  = nil

end

--============================================================================================================================
-- update
--============================================================================================================================
function AITurnStrategyMogli:update(dt)
end

--============================================================================================================================
-- getPoint
--============================================================================================================================
function AITurnStrategyMogli:getPoint( wx, wz, dx, dz )
	local l = Utils.vector2Length( dx, dz )
	return { x=wx, z=wz, dx=dx/l, dz=dz/l }
end

--============================================================================================================================
-- fillQuot2Rad
--============================================================================================================================
function AITurnStrategyMogli.fillQuot2Rad()
	AITurnStrategyMogli.quot2Rad = AnimCurve:new(linearInterpolator1)
	
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=-22.9037655484312, v=-3.05432619099008 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=-7.59575411272514, v=-2.87979326579064 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=-4.51070850366206, v=-2.70526034059121 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=-3.17159480236321, v=-2.53072741539178 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=-2.41421356237309, v=-2.35619449019234 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=-1.92098212697117, v=-2.18166156499291 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=-1.56968557711749, v=-2.00712863979348 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=-1.30322537284121, v=-1.83259571459405 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=-1.09130850106927, v=-1.65806278939461 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=-0.916331174017423, v=-1.48352986419518 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=-0.76732698797896, v=-1.30899693899575 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=-0.637070260807493, v=-1.13446401379631 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=-0.520567050551746, v=-0.959931088596881 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=-0.414213562373095, v=-0.785398163397448 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=-0.315298788878984, v=-0.610865238198015 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=-0.22169466264294, v=-0.436332312998582 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=-0.131652497587396, v=-0.261799387799149 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=-0.0436609429085119, v=-0.0872664625997165 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=0.0436609429085119, v=0.0872664625997165 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=0.131652497587396, v=0.261799387799149 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=0.22169466264294, v=0.436332312998582 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=0.315298788878984, v=0.610865238198015 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=0.414213562373095, v=0.785398163397448 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=0.520567050551746, v=0.959931088596881 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=0.637070260807493, v=1.13446401379631 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=0.76732698797896, v=1.30899693899575 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=0.916331174017423, v=1.48352986419518 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=1.09130850106927, v=1.65806278939461 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=1.30322537284121, v=1.83259571459405 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=1.56968557711749, v=2.00712863979348 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=1.92098212697117, v=2.18166156499291 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=2.41421356237309, v=2.35619449019234 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=3.17159480236321, v=2.53072741539178 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=4.51070850366206, v=2.70526034059121 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=7.59575411272514, v=2.87979326579064 })
	AITurnStrategyMogli.quot2Rad:addKeyframe( { time=22.9037655484312, v=3.05432619099008 })
end

--============================================================================================================================
-- raiseOrLower
--============================================================================================================================
function AITurnStrategyMogli:raiseOrLower( moveForwards )
	if not moveForwards then
	-- make sure that tools are raised if going backwards
		AutoSteeringEngine.ensureToolIsLowered( self.vehicle, false )
	elseif self.vehicle.aiveHas.combine then
	-- lower tool on fruits if combine is going forwards
		if AutoSteeringEngine.hasFruits( self.vehicle, 0.8 ) then
			AIVehicleExtension.setAIImplementsMoveDown( self.vehicle, true, false )
		end
	end
end

--============================================================================================================================
-- getNextStage
--============================================================================================================================
function AITurnStrategyMogli:getNextStage( dt, vX,vY,vZ, turnData, stageId )
end

--============================================================================================================================
-- getDriveData
--============================================================================================================================
function AITurnStrategyMogli:getDriveData(dt, vX,vY,vZ, turnData)

	local vehicle = self.vehicle 
	
	if self.stageId == 0 then
		self.stageId     = 1
		self.activeStage = self:getNextStage( dt, vX,vY,vZ, turnData, 1 )
	end
	
	if self.activeStage == nil then
	-- end of turn
		return 
	end
	
	AIVehicleExtension.statEvent( vehicle, "t0", dt )

	AIVehicleExtension.checkState( vehicle )
	if not AutoSteeringEngine.hasTools( vehicle ) then
		vehicle:stopAIVehicle(AIVehicle.STOP_REASON_UNKOWN)
		return
	end
	
	self.dtSum = self.dtSum + dt
	
	local skip = true
	
	if	   self.lastDriveData == nil then
		skip = false
	elseif AIVEGlobals.maxDtSum <= 0 then
		skip = false
	elseif self.dtSum > AIVEGlobals.maxDtSum then 
		skip = false
	elseif Utils.vector2LengthSq( vehicle.acAiPos[1] - vX, vehicle.acAiPos[3] - vZ ) > AIVEGlobals.maxDtDistD then
		skip = false
	end 
	
	if skip then
		local tX, tZ, moveForwards, allowedToDrive, distanceToStop, angle, inactive = unpack( self.lastDriveData )
		if tX == nil and angle ~= nil then
			tX, tZ = AutoSteeringEngine.getWorldTargetFromSteeringAngle( vehicle, angle )
		end
		local maxSpeed = AutoSteeringEngine.getMaxSpeed( vehicle, dt, 1, allowedToDrive, moveForwards, 4, false, 0.7 )
		
		if allowedToDrive then
			self:raiseOrLower( moveForwards )
		elseif angle ~= nil then
			AutoSteeringEngine.steer( vehicle, dt, angle, vehicle.aiSteeringSpeed, false )		
		end
		
		return tX, tZ, moveForwards, maxSpeed, distanceToStop, not ( inactive )
	end
	
	while self.activeStage ~= nil do
		local tX, tZ, moveForwards, allowedToDrive, distanceToStop, angle, inactive = self.activeStage.getDriveData( self, dt, vX,vY,vZ, turnData, unpack( self.activeStage.parameter ) )
		
		if tX == nil and angle ~= nil then
			tX, tZ = AutoSteeringEngine.getWorldTargetFromSteeringAngle( vehicle, angle )
		end
		if tX ~= nil then
			local maxSpeed = AutoSteeringEngine.getMaxSpeed( vehicle, dt, 1, allowedToDrive, moveForwards, 4, false, 0.7 )
			
			if allowedToDrive then
				self:raiseOrLower( moveForwards )
			elseif angle ~= nil then
				AutoSteeringEngine.steer( vehicle, dt, angle, vehicle.aiSteeringSpeed, false )		
			end
			
			self.lastDriveData = { tX, tZ, moveForwards, allowedToDrive, distanceToStop, angle, inactive }
				
			return tX, tZ, moveForwards, maxSpeed, distanceToStop, not ( inactive )
		end
			
		-- go to next stage 		
		self.stageId     = self.stageId + 1		
		self.activeStage = self:getNextStage( dt, vX,vY,vZ, turnData, self.stageId )
			
		if AIVEGlobals.devFeatures > 0 then
			self:addDebugText("going to stage "..tostring(self.stageId))
		end
	end
	
	-- end of turn
end

--============================================================================================================================
-- getStageCircle
--============================================================================================================================
function AITurnStrategyMogli:getStageCircle( centerX, centerZ, radius, endAngle, moveForwards, distanceToStop )
	local s          = {}	
	
	s.getDriveData   = AITurnStrategyMogli.getDD_circle
	s.parameter      = { centerX, centerZ, math.max( 5, radius ), endAngle, moveForwards, distanceToStop }
	
	return s
end

--============================================================================================================================
-- getDD_navigateAlongPoints
--============================================================================================================================
function AITurnStrategyMogli:getDD_circle( dt, vX,vY,vZ, turnData, centerX, centerZ, radius, endAngle, moveForwards, distanceToStop )
	local vehicle   = self.vehicle 
	local wx,wy,wz  = AutoSteeringEngine.getAiWorldPosition( vehicle )
	local twx       = centerX + math.sin( endAngle ) * radius 
	local twz       = centerZ + math.cos( endAngle ) * radius 
	local tdx,_,tdz = worldDirectionToLocal( vehicle.aiveChain.refNode, twx-wx, 0, twz-wz )
	
--local dx,_,dz   = localDirectionToWorld( vehicle.aiveChain.refNode, 0, 0, 1 )
--local r         = 1
	local dx        = wx - centerX
	local dz        = wz - centerZ
	local r         = Utils.vector2Length( dx, dz )
--local angle     = math.atan2( dx, dz )
                  
	if r < 0.5 then
		return twx, twz, moveForwards, true, distanceToStop, nil, false
	end
	
	if radius < 0 then
		dx = -dx
		dz = -dz
	end
	
	local angle     = math.acos( dz / r )
	if dx < 0 then
		angle         = -angle 
	end
	
	local diff = AutoSteeringEngine.normalizeAngle( endAngle - angle )

	self:addDebugText(tostring(self.stageId)..": "..AutoSteeringEngine.radToString(angle).." - "..AutoSteeringEngine.radToString(endAngle).." = "..AutoSteeringEngine.radToString(diff).." / "..tostring(tdz))

	if math.abs( diff ) < 0.25 * math.pi and tdz < 0 then
		return 
	end

	local dist = diff * radius + distanceToStop	
	local targetAngle = endAngle
	if math.abs( diff * radius )  > 1 then		
		diff = 1 / radius 
		targetAngle = angle + diff
	end
	
	dx = math.sin( targetAngle ) * radius 
	dz = math.cos( targetAngle ) * radius 
	
	wx = centerX+dx
	wz = centerZ+dz
	
	self:addDebugText(AutoSteeringEngine.radToString( angle ).." => "..AutoSteeringEngine.radToString( targetAngle ).." ("..AutoSteeringEngine.radToString( endAngle )..") => "..tostring(wx).." "..tostring(wz))
	
	return centerX+dx, centerZ+dz, moveForwards, true, dist, nil, false
end

--============================================================================================================================
-- getStageFromPoints
--============================================================================================================================
function AITurnStrategyMogli:getStageFromPoints( points, moveForwards, distanceToStop, inactive )
	local s          = {}	
	s.getDriveData   = AITurnStrategyMogli.getDD_navigateAlongPoints
	
	s.parameter      = { moveForwards, {}, inactive}
	
	local dts = Utils.getNoNil( distanceToStop, 0 )
	
	-- add points in reverse order (from last to first)
	for i,p in pairs( points ) do
		table.insert( s.parameter[2], 1, p )
		
		s.parameter[2][1].distanceToStop = dts
		
		if s.parameter[2][2] ~= nil then
			local d = Utils.vector2Length( p.x - s.parameter[2][2].x, p.z - s.parameter[2][2].z )
			for j=2,table.getn(s.parameter[2]) do
				s.parameter[2][j].distanceToStop = s.parameter[2][j].distanceToStop + d
			end
		end
	end	
	
	
	return s
end

--============================================================================================================================
-- getDD_navigateAlongPoints
--============================================================================================================================
function AITurnStrategyMogli:getDD_navigateAlongPoints( dt, vX,vY,vZ, turnData, moveForwards, points, inactive )
	local vehicle = self.vehicle 
	
-- navigate using points 
	local distanceToStop = 0

	if AITurnStrategyMogli.quot2Rad == nil then
		AITurnStrategyMogli.fillQuot2Rad()
	end

	n     = 0
	angle = nil
	bestD = nil
	bestB = nil
	bestX = nil
	bestZ = nil
	
	local score = {}
	for i=1,3 do
		score[i] = { score = math.huge }
	end
	
	for i,p in pairs( points ) do
	--local x,_,z   = worldToLocal( vehicle.aiveChain.refNode, p.x, wy, p.z )
		local x,_,z   = worldDirectionToLocal( vehicle.aiveChain.refNode, p.x-vX, 0, p.z-vZ )
		local dx,_,dz = worldDirectionToLocal( vehicle.aiveChain.refNode, p.dx, 0, p.dz )
		
		if not moveForwards then
			x  = -x
			z  = -z
		end
		
		if AIVEGlobals.devFeatures > 0 then
			self:addDebugText(string.format("%2d: (%4f, %4f) (%4f, %4f)",i,x,z,dx,dz))
		end
		
		if i == 1 and z >= 0 then
			distanceToStop = z
			bestX = p.x
			bestZ = p.z
			angle = 0
			bestD = 0
			bestB = 0
		end
		
		if z >= 1 then	
			if distanceToStop < p.distanceToStop then
				distanceToStop = p.distanceToStop
			end
				
			if math.abs( x ) <= 22.9 * math.abs( z ) then
				local alpha = AITurnStrategyMogli.quot2Rad:get( x/z )					
				local beta  = math.atan2( dx, dz )
									
				if math.abs(x) < math.abs(z) then
					a = math.atan2( vehicle.aiveChain.wheelBase * math.sin( alpha ), z )					
				else
					a = math.atan2( vehicle.aiveChain.wheelBase * (1-math.cos( alpha )), math.abs(x) )					
					if x < 0 then
						a = -a
					end
				end
				
				a = a + 0.5 * ( alpha - beta )
				
				if math.abs( a ) <= 1.25 * vehicle.aiveChain.maxSteering then
					local d = x*x+z*z 						
					local s = math.abs( 4 - d )
					local b = math.abs( alpha - beta ) 
			
					for j=1,table.getn( score ) do
						if s <= score[j].score then
							for k=table.getn( score )-1, j,-1 do
								if score[k].angle ~= nil then
									score[k+1].score = score[k].score
									score[k+1].angle = score[k].angle
									score[k+1].dist  = score[k].dist 
									score[k+1].beta  = score[k].beta 
									score[k+1].tX    = score[k].tX   
									score[k+1].tZ    = score[k].tZ
								end
							end
							score[j].score = s
							score[j].angle = a
							score[j].dist  = d
							score[j].beta  = b
							score[j].tX    = p.x
							score[j].tZ    = p.z
							break
						end
					end
				end			
			end				
		end
	end
	
	for j=1,table.getn( score ) do
		if score[j].angle == nil then
			break
		else--if score[j].score < 10 then
			if n > 0 then
				n     = n + 1
				angle = angle + score[j].angle
				bestD = bestD + score[j].dist 
				bestB = bestB + score[j].beta 
				bestX = bestX + score[j].tX
				bestZ = bestZ + score[j].tZ
			else
				n     = 1
				angle = score[j].angle
				bestD = score[j].dist 
				bestB = score[j].beta 						
				bestX = score[j].tX
				bestZ = score[j].tZ
			end
		end
	end
	
	if n > 1 then
		angle = angle / n
		bestD = bestD / n
		bestB = bestB / n
		bestX = bestX / n
		bestZ = bestZ / n
	end
	
	if bestX == nil then		
		return 
	end

	distanceToStop = distanceToStop + math.sqrt( bestD )
	
	return bestX, bestZ, moveForwards, true, distanceToStop, nil, inactive
end

--============================================================================================================================
-- getStageFromFunction
--============================================================================================================================
function AITurnStrategyMogli:getStageFromFunction( fct, params )
	local s          = {}	

	if type( params ) == "table" then
		s.parameter = {}
		for n,p in pairs( params ) do
			s.parameter[n] = p
		end
	elseif params ~= nil then
		s.parameter = { params }
	else
		s.parameter = {}
	end
	
	s.getDriveData = fct 
	
	return s
end

--============================================================================================================================
-- getDD_reduceTurnAngle
--============================================================================================================================
function AITurnStrategyMogli:getDD_reduceTurnAngle( dt, vX,vY,vZ, turnData, moveForwards, maxAngle )

	local vehicle = self.vehicle 
	
	local angle  = AutoSteeringEngine.getTurnAngle( vehicle )
	
	
	if math.abs( angle ) < math.rad( maxAngle ) then
		self:addDebugText(string.format("math.abs( %4.1f° ) < math.abs( %4.1f° )",math.deg(angle),maxAngle ))
		return 
	end
	
	local angle2 = Utils.clamp( -angle, -vehicle.acDimensions.maxSteeringAngle, vehicle.acDimensions.maxSteeringAngle )

	self:addDebugText(string.format("math.abs( %4.1f° ) => math.abs( %4.1f° ) => %4.1f°",math.deg(angle),maxAngle,math.deg(angle2) ))

	return nil, nil, moveForwards, true, 1, angle2, true
end

--============================================================================================================================
-- getDD_checkIsAnimPlaying
--============================================================================================================================
function AITurnStrategyMogli:getDD_checkIsAnimPlaying( dt, vX,vY,vZ, turnData, moveForwards )
	local vehicle = self.vehicle 
	
	local allowedToDrive =  AutoSteeringEngine.checkAllowedToDrive( vehicle, not ( vehicle.acParameters.isHired  ) )
	if not allowedToDrive then
		AIVehicleExtension.setStatus( self, 0 )
	end
	
	self.noSneak = false

	local isPlaying, noSneak = AutoSteeringEngine.checkIsAnimPlaying( vehicle, vehicle.acImplementsMoveDown )
	
	if isPlaying then
		if    self.animWaitTimer == nil then
			self.animWaitTimer = vehicle.acDeltaTimeoutWait
		elseif self.animWaitTimer > 0 then
			self.animWaitTimer = self.animWaitTimer - dt
		end
	else
		self.animWaitTimer = nil
		noSneak            = false
	end
	
	if noSneak then
		if    self.noSneakTimer == nil then
			self.noSneakTimer = vehicle.acDeltaTimeoutWait
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
		AIVehicleExtension.setStatus( vehicle, 3 )
		allowedToDrive = false
	end
	
	if not allowedToDrive then
		AIVehicleExtension.statEvent( vehicle, "tS", dt )
		vehicle.isHirableBlocked = true		
		return vX, vZ, Utils.getNoNil( moveForwards, true ), false, 0, true
	end
	
end

--============================================================================================================================
-- getCombinedStage
--============================================================================================================================
function AITurnStrategyMogli:getCombinedStage( s1, s2 )
	local s        = {}	
	s.parameter    = { s1, s2 }
	s.getDriveData = AITurnStrategyMogli.getDD_combinedStage
	return s
end

--============================================================================================================================
-- getDD_combinedStage
--============================================================================================================================
function AITurnStrategyMogli:getDD_combinedStage( dt, vX,vY,vZ, turnData, s1, s2 )
	local tX, tZ, moveForwards, allowedToDrive, distanceToStop, angle, inactive = s1.getDriveData( self, dt, vX,vY,vZ, turnData, unpack( s1.parameter ) )
	
	if tX ~= nil or angle ~= nil then
		return tX, tZ, moveForwards, allowedToDrive, distanceToStop, angle, inactive
	end

	return s2.getDriveData( self, dt, vX,vY,vZ, turnData, unpack( s2.parameter ) )
end

--============================================================================================================================
-- getStageWithPostCheck
--============================================================================================================================
function AITurnStrategyMogli:getStageWithPostCheck( s1, fct )
	local s        = {}	
	s.parameter    = { s1, fct }
	s.getDriveData = AITurnStrategyMogli.getDD_withPostCheck
	return s
end

--============================================================================================================================
-- getDD_withPostCheck
--============================================================================================================================
function AITurnStrategyMogli:getDD_withPostCheck( dt, vX,vY,vZ, turnData, s1, fct )
	local tX, tZ, moveForwards, allowedToDrive, distanceToStop, angle, inactive = s1.getDriveData( self, dt, vX,vY,vZ, turnData, unpack( s1.parameter ) )

	return fct( self, dt, vX,vY,vZ, turnData, tX, tZ, moveForwards, allowedToDrive, distanceToStop, angle, inactive )
end
