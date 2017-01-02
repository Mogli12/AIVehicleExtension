
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
-- startTurn
--============================================================================================================================
function AITurnStrategyMogli:startTurn( turnData )
	self.lastDirection = nil
	
	self.vehicle.aiveChain.inField = false
	self.vehicle.aiveChain.isAtEnd = false
	
	AIVehicleExtension.setAIImplementsMoveDown(self.vehicle,false)
	
	self.stages = {}
	self.stage  = 1 
	self:fillStages( turnData )
end

--============================================================================================================================
-- onEndTurn
--============================================================================================================================
function AITurnStrategyMogli:onEndTurn( turnLeft )
	self.lastDirection = nil
	AIVehicleExtension.setAIImplementsMoveDown(self.vehicle,true)
end

--============================================================================================================================
-- update
--============================================================================================================================
function AITurnStrategyMogli:update(dt)
	if self.vehicle ~= nil and self.stages ~= nil and self.vehicle.acShowTrace then
		local c  = table.getn( self.stages )		
		local c1 = 1
		if c > 1 then
			c1 = 1 / ( c - 1 )
		end
		
		for i,s in pairs( self.stages ) do
			local cr = c1 * i
			local cb = 1 - cr
			
			if s.points ~= nil then for j,p in pairs( s.points ) do
				local y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, p.x, 1, p.z)					
				drawDebugLine(  p.x, y, p.z,cr,1,cb, p.x, y+4, p.z,cr,1,cb)
				drawDebugPoint( p.x, y+4, p.z	, 1, 1, 1, 1 )
				drawDebugLine(  p.x, y+2, p.z,cr,1,cb, p.x+p.dx, y+2, p.z+p.dz,cr,1,cb)				
			end end
		end
	end
end

--============================================================================================================================
-- fillStages
--============================================================================================================================
function AITurnStrategyMogli:fillStages( turnData )
	print("ERROR: AITurnStrategyMogli:fillStages")
end

--============================================================================================================================
-- fillStageDuringTurn
--============================================================================================================================
function AITurnStrategyMogli:fillStageDuringTurn( index, stage )
end

--============================================================================================================================
-- addStageLateFill
--============================================================================================================================
function AITurnStrategyMogli:addStageFillDuringTurn()
	local s = table.getn( self.stages ) + 1
	
	self.stages[s] = {}
	self.stages[s].id  = s
	self.stages[s].fillDuringTurn = true
	
	return s
end

--============================================================================================================================
-- addStageWithPoints
--============================================================================================================================
function AITurnStrategyMogli:addStageWithPoints( moveForwards, points, fct )
	local s = table.getn( self.stages ) + 1
	
	self.stages[s] = {}
	self.stages[s].id  = s
	self.stages[s].moveForwards = moveForwards
	self.stages[s].fct          = fct
	self.stages[s].points       = {}
	
	-- add points in reverse order (from last to first)
	for i,p in pairs( points ) do
		table.insert( self.stages[s].points, 1, p )
		
		self.stages[s].points[1].distanceToStop = 0
		
		if self.stages[s].points[2] ~= nil then
			local d = Utils.vector2Length( p.x - self.stages[s].points[2].x, p.z - self.stages[s].points[2].z )
			for j=2,table.getn(self.stages[s].points) do
				self.stages[s].points[j].distanceToStop = self.stages[s].points[j].distanceToStop + d
			end
		end
	end	
	
	return s
end

--============================================================================================================================
-- addStageWithFunction
--============================================================================================================================
function AITurnStrategyMogli:addStageWithFunction( fct )
	local s = table.getn( self.stages ) + 1
	
	self.stages[s] = {}
	self.stages[s].id  = s
	self.stages[s].fct = fct
	
	return s
end

--============================================================================================================================
-- getPoint
--============================================================================================================================
function AITurnStrategyMogli:getPoint( wx, wz, dx, dz )
	return { x=wx, z=wz, dx=dx, dz=dz }
end

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
function AITurnStrategyMogli:raiseOrLower( tX, tZ, moveForwards, maxSpeed, distanceToStop )
	if not moveForwards then
	-- make sure that tools are raised if going backwards
		AutoSteeringEngine.ensureToolIsLowered( self.vehicle, false )
	elseif self.vehicle.aiveHas.combine then
	-- lower tool on fruits if combine is going forwards
		if AutoSteeringEngine.hasFruits( self.vehicle, 0.8 ) then
			AIVehicleExtension.setAIImplementsMoveDown( self.vehicle, false )
		end
	end
end

--============================================================================================================================
-- getDriveData
--============================================================================================================================
function AITurnStrategyMogli:getDriveData(dt, vX,vY,vZ, turnData)
	
	if self.stage <= table.getn( self.stages ) then
		local vehicle = self.vehicle 
		
		while self.stage <= table.getn( self.stages ) do
			local stage = self.stages[self.stage]
			
			if stage.fct == nil and stage.points == nil and stage.fillDuringTurn then
				self:fillStageDuringTurn( self.stage, stage )
			end
			
			local r1,r2,r3,r4,r5 = nil,nil,nil,nil,nil
							
			if type( stage.points) == "table" then
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
				
				for i,p in pairs( stage.points ) do
				--local x,_,z   = worldToLocal( vehicle.aiveChain.refNode, p.x, wy, p.z )
					local x,_,z   = worldDirectionToLocal( vehicle.aiveChain.refNode, p.x-vX, 0, p.z-vZ )
					local dx,_,dz = worldDirectionToLocal( vehicle.aiveChain.refNode, p.dx, 0, p.dz )
					
					if not stage.moveForwards then
						x  = -x
						z  = -z
					end
					
					if AIVEGlobals.devFeatures > 0 then
						print(string.format("%2d: (%4f, %4f) (%4f, %4f)",i,x,z,dx,dz))
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
				
				if bestX ~= nil then		
					distanceToStop = distanceToStop + math.sqrt( bestD )
					
					if AIVEGlobals.devFeatures > 0 then
						print(tostring(math.deg(angle)).."° "..tostring(n).." "..tostring(bestD).." "..tostring(bestB))
					end
					
					local maxSpeed = AutoSteeringEngine.getMaxSpeed( vehicle, dt, 1, true, stage.moveForwards, 1, false, 0.7 )
					
					if type( stage.fct ) == "function" then
					--print("Calling function (1)...")
						r1,r2,r3,r4,r5 = stage.fct( self, dt, vX,vY,vZ, turnData, stage, bestX, bestZ, maxSpeed, distanceToStop )
					else
						r1 = bestX
						r2 = bestZ
						r3 = stage.moveForwards
						r4 = maxSpeed
						r5 = distanceToStop
					end
				else
					if AIVEGlobals.devFeatures > 0 then
						print(tostring(n))
					end
					
					if type( stage.fct ) == "function" then
					--print("Calling function (2)...")
						r1,r2,r3,r4,r5 = stage.fct( self, dt, vX,vY,vZ, turnData, stage )
					end
				end
								
			elseif type( stage.fct ) == "function" then
			-- navigate using stage specific function 
			--print("Calling function (3)...")
				r1,r2,r3,r4,r5 = stage.fct( self, dt, vX,vY,vZ, turnData, stage )
			end	
			
			if r1 ~= nil then
				self:raiseOrLower( r1,r2,r3,r4,r5 )
				return r1,r2,r3,r4,r5
			end
			
			-- go to next stage 		
			self.stage = self.stage + 1
			
			if AIVEGlobals.devFeatures > 0 then
				print("going to stage "..tostring(self.stage).."/"..tostring(table.getn( self.stages )))
			end
		end
	end
	
	-- end of turn
--return 0, 0, true, 0, 0	
end
