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

source(Utils.getFilename("FieldBitmap.lua",        g_currentModDirectory))
source(Utils.getFilename("AITurnStrategy_C_7.lua", g_currentModDirectory))
source(Utils.getFilename("AITurnStrategy_C_C.lua", g_currentModDirectory))
source(Utils.getFilename("AITurnStrategy_C_L.lua", g_currentModDirectory))
source(Utils.getFilename("AITurnStrategy_U_8.lua", g_currentModDirectory))
source(Utils.getFilename("AITurnStrategy_U_A.lua", g_currentModDirectory))
source(Utils.getFilename("AITurnStrategy_U_O.lua", g_currentModDirectory))
source(Utils.getFilename("AITurnStrategy_U_T.lua", g_currentModDirectory))


function AIDriveStrategyMogli:setAIVehicle(vehicle)
	AIDriveStrategyMogli:superClass().setAIVehicle(self, vehicle)
	
	self.turnLeft           = self.vehicle.aiveState.turnLeft 	
	
	table.insert(self.turnStrategies, AITurnStrategy_C_7:new())
	table.insert(self.turnStrategies, AITurnStrategy_C_C:new())
	table.insert(self.turnStrategies, AITurnStrategy_C_L:new())
	table.insert(self.turnStrategies, AITurnStrategy_U_8:new())
	table.insert(self.turnStrategies, AITurnStrategy_U_A:new())
	table.insert(self.turnStrategies, AITurnStrategy_U_O:new())
	table.insert(self.turnStrategies, AITurnStrategy_U_T:new())

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

	-- during turn
	if self.activeTurnStrategy ~= nil then
		local tX, tZ, moveForwards, maxSpeed, distanceToStop = self.activeTurnStrategy:getDriveData(dt, vX,vY,vZ, self.turnData)
		if tX ~= nil then
			self:addDebugText( "===> distanceToStop = "..distanceToStop )
			return tX, tZ, moveForwards, maxSpeed, distanceToStop
		else
			for _,turnStrategy in pairs(self.turnStrategies) do
				turnStrategy:onEndTurn(self.activeTurnStrategy.turnLeft)
			end
			self.activeTurnStrategy = nil
		end
	end
	
	
	
	local tX, tZ, moveForwards, maxSpeed, distanceToStop = 0, 1, true, 0, math.huge		
		
		
	
	return tX, tZ, moveForwards, maxSpeed, distanceToStop
end


function AIDriveStrategyMogli:getAiWorldPosition()
	return unpack( self.position )
end


ASEStatus = {}
ASEStatus.initial  = 0
ASEStatus.steering = 1
ASEStatus.rotation = 2
ASEStatus.position = 3
ASEStatus.border   = 4

------------------------------------------------------------------------
-- setChainStatus
------------------------------------------------------------------------
function AIDriveStrategyMogli:setChainStatus( startIndex, newStatus )
	if not self.vehicle.isServer then return end
	
	if self.chainNodes ~= nil then
		local i = math.max(startIndex,1)
		while i <= self.chainMax + 1 do
			if self.chainNodes[i].status > newStatus then
				self.chainNodes[i].status = newStatus
				self.chainNodes[i].tool   = {}
			end
			i = i + 1
		end
	end
end

------------------------------------------------------------------------
-- getTurnDistanceSq
------------------------------------------------------------------------
function AIDriveStrategyMogli:getTurnDistanceSq()
	if     self.aseChain.refNode             == nil
			or self.trace       == nil
			or self.trace.nodes == nil 
			or self.trace.nodesIndex < 1 then
		return 0
	end
	local _,y,_ = self:getAiWorldPosition()
	local x,_,z = worldToLocal( self.refNode, self.trace.nodes[self.trace.nodesIndex].px, y, self.trace.nodes[self.trace.nodesIndex].pz )
	return x*x + z*z
end

------------------------------------------------------------------------
-- getTurnDistance
------------------------------------------------------------------------
function AIDriveStrategyMogli:getTurnDistance()
	return math.sqrt( self:getTurnDistanceSq() )
end

------------------------------------------------------------------------
-- getFirstTraceIndex
------------------------------------------------------------------------
function AIDriveStrategyMogli:getFirstTraceIndex()
	if     self.trace.nodes      == nil 
			or self.trace.nodesIndex == nil 
			or self.trace.nodesIndex < 1 then
		return nil
	end
	local l = table.getn(self.trace.nodes)
	if l < 1 then
		return nil
	end
	local i = self.trace.nodesIndex + 1
	if i > l then i = 1 end
	return i
end

------------------------------------------------------------------------
-- getTraceLength
------------------------------------------------------------------------
function AIDriveStrategyMogli:getTraceLength()
	if     self.refNode     == nil
			or self.trace       == nil then
		return 0
	end
	if     self.trace.sx    == nil
			or self.trace.sz    == nil
			or self.trace.nodes == nil then
		return 0
	end
	
	if table.getn(self.trace.nodes) < 2 then
		return 0
	end
		
	local i = self:getFirstTraceIndex()
	if i == nil then
		return 0
	end
	
	if self.trace.l == nil then
		local x = self.trace.nodes[self.trace.nodesIndex].px - self.trace.sx
		local z = self.trace.nodes[self.trace.nodesIndex].pz - self.trace.sz
		self.trace.l = math.sqrt( x*x + z*z )
	end
	
	return self.trace.l
end

------------------------------------------------------------------------
-- normalizeAngle
------------------------------------------------------------------------
function AIDriveStrategyMogli.normalizeAngle( b )
	local a = b
	while a >  math.pi do a = a - math.pi - math.pi end
	while a < -math.pi do a = a + math.pi + math.pi end
	return a
end

------------------------------------------------------------------------
-- getTurnAngle
------------------------------------------------------------------------
function AIDriveStrategyMogli:getTurnAngle()
	if self.buffer == nil then
		self.buffer = {}
	elseif self.buffer.getTurnAngle ~= nil then
		return self.buffer.getTurnAngle
	end

	if     self.refNode         == nil
			or self.trace   == nil then
		self.buffer.getTurnAngle = 0
		return 0
	end
	if self.trace.a == nil then
		local i = self:getFirstTraceIndex()
		if i == nil then
			self.buffer.getTurnAngle = 0
			return 0
		end
		if i == self.trace.nodesIndex then
			self.buffer.getTurnAngle = 0
			return 0
		end
		local l = self:getTraceLength()
		if l < 2 then
			self.buffer.getTurnAngle = 0
			return 0
		end

		local vx = self.trace.nodes[self.trace.nodesIndex].px - self.trace.nodes[i].px
		local vz = self.trace.nodes[self.trace.nodesIndex].pz - self.trace.nodes[i].pz		
		self.trace.a = Utils.getYRotationFromDirection(vx,vz)
		
		if self.trace.a == nil then
			print("NIL!!!!")
		end
	end

	local x,y,z = localDirectionToWorld( self.refNode, 0,0,1 )
	
	local angle = AIDriveStrategyMogli.normalizeAngle( Utils.getYRotationFromDirection(x,z) - self.trace.a )	

	self.buffer.getTurnAngle = angle
	return angle
end	

------------------------------------------------------------------------
-- clearTrace
------------------------------------------------------------------------
function AIDriveStrategyMogli:clearTrace()
	self.trace = {}
	self.buffer = nil
end

------------------------------------------------------------------------
-- saveDirection
------------------------------------------------------------------------
function AIDriveStrategyMogli:saveDirection( cumulate, notOutside )

--self.aseChain.respectStartNode = false

	self.buffer = nil
	if self.trace == nil then
		self.trace = {}
	end

	self.trace.a           = nil
	self.trace.l           = nil
	self.trace.isUTurn     = nil
	self.trace.targetTrace = nil
	
	if not ( cumulate ) or self.trace.nodesIndex == nil or self.trace.nodes == nil then
		self.trace.nodes       = {}
		self.trace.nodesIndex  = 0
		self.trace.uTrace      = {}
		self.trace.uTraceIndex = 0
		self.trace.sx, _, self.trace.sz = AutoSteeringEngine.getAiWorldPosition( vehicle )
		self.trace.ux          = nil
		self.trace.uz          = nil
		self.trace.cx          = nil
		self.trace.cz          = nil
		self.trace.ox          = nil
		self.trace.oz          = nil
		self.trace.ax          = nil
		self.trace.az          = nil
		self.trace.rx          = nil
		self.trace.rz          = nil
		self.trace.tpBuffer    = {}
	end

	local wx,_,wz = localToWorld( self.refNode, vehicle.aseOtherX, 0 , vehicle.aseBack )
	
	local saveTurnPoint = nil
	if self.trace.ux == nil then
		saveTurnPoint = true
	elseif Utils.vector2LengthSq( self.trace.x - wx, self.trace.z - wz ) < 0.01 then
		saveTurnPoint = false
	end
	
	self.trace.x = wx
	self.trace.z = wz
	
	if vehicle.aseLRSwitch then
		self.trace.dx,_,self.trace.dz = localDirectionToWorld( self.refNode, 1, 0, 0 )
	else
		self.trace.dx,_,self.trace.dz = localDirectionToWorld( self.refNode,-1, 0, 0 )
	end	
	
	local turnXu, turnZc
	local turnZu = vehicle.aseStart
	local turnXc = vehicle.aseOtherX
		
	for i,tp in pairs(self.toolParams) do	
		local tpb
		if self.trace.tpBuffer[i] == nil then
			self.trace.tpBuffer[i] = { xA = tp.x, 
			                                               xO = tp.xOther, 
																										 zR = tp.zReal }
			tpb = self.trace.tpBuffer[i]
		else
			tpb = self.trace.tpBuffer[i]
			tpb.xA = tpb.xA + 0.05 * ( tp.x      - tpb.xA )
			tpb.xO = tpb.xO + 0.05 * ( tp.xOther - tpb.xO )
			tpb.zR = tpb.zR + 0.05 * ( tp.zReal  - tpb.zR )
		end
		
		local oxr,_,ozr = localToWorld( self.refNode, tpb.xO, 0 , tpb.zR )
		
		local ofs, idx
		if vehicle.aseLRSwitch	then
			ofs = tp.offset 
			idx = tp.nodeRight
		else
			ofs = -tp.offset 
			idx = tp.nodeLeft 
		end
		
		local ox,_,oz = localToWorld( idx, ofs, 0, 2 )
		
		if      not ( tp.skipOther and tp.skip ) 
				and ( saveTurnPoint == nil or saveTurnPoint == true )
				and ( ( ( vehicle.aseHeadland >= 1
					  and AutoSteeringEngine.isChainPointOnField( vehicle, ox, oz ) )
				   or ( vehicle.aseHeadland < 1
					  and AutoSteeringEngine.checkField( vehicle, ox, oz ) ) ) ) then
						
			local d = Utils.getNoNil( self.trace.lastD, 0.05 ) 
			local stp = false
			if saveTurnPoint then
				stp = true
			end
			
			while not ( stp ) do
				local a, t = AutoSteeringEngine.getFruitAreaWorldPositions( vehicle, vehicle.aseTools[tp.i], ox-d,oz-d,ox+d,oz-d,ox-d,oz+d )
				if a > 0 then
					stp = true
				elseif t > 0 then
					break
				end
				d = d + 0.05
				if d > 0.5 then
					break
				end
			end
			
			d = d - 0.05
			if     d <= 0.05 then
				self.trace.lastD = 0.05
			elseif d >= 0.45 then
				self.trace.lastD = 0.45
			else
				self.trace.lastD = d
			end				
						
			if stp then			
				saveTurnPoint = true

				self.trace.ox = ox
				self.trace.oz = oz
				local mx,_,mz = worldDirectionToLocal( self.refNode, ox - oxr, 0, oz - ozr )

				if not ( tp.skipOther ) then
					local txu = tpb.xO 				
					if AutoSteeringEngine.invertsMarkerOnTurn( vehicle, vehicle.aseTools[tp.i], not vehicle.aseLRSwitch ) then
						txu = -tpb.xA
					end
					txu = tpb.xO + txu + mx
					
					if     turnXu == nil then
						turnXu = txu 
						turnZu = vehicle.aseStart + mz
					elseif vehicle.aseLRSwitch then
						if turnXu > txu then
							turnXu = txu 
							turnZu = vehicle.aseStart + mz
						end
					else
						if turnXu < txu then
							turnXu = txu 
							turnZu = vehicle.aseStart + mz
						end
					end
				end
				
				if not ( tp.skip ) then
					local tzc = tpb.xA
					if vehicle.aseLRSwitch then
						tzc = -tzc
					end						
					tzc = tzc + tpb.zR + mz
					
					if     turnZc == nil then
						turnZc = tzc
						turnXc = vehicle.aseOtherX + mx
					elseif turnZc < tzc then
						turnZc = tzc
						turnXc = vehicle.aseOtherX + mx
					end
				end
			end
		end
	end
	
	if saveTurnPoint then
		if turnXu == nil and self.trace.ux == nil then
			turnXu = vehicle.aseOtherX
			if AITractor.invertsMarkerOnTurn( vehicle, not vehicle.aseLRSwitch ) then
				turnXu = -vehicle.aseActiveX
			end
			turnXu = turnXu + vehicle.aseOtherX
		end
		if turnZc == nil and self.trace.cx == nil then
			turnZc = vehicle.aseActiveX
			if vehicle.aseLRSwitch then
				turnZc = -turnZc 
			end
			turnZc = turnZc + vehicle.aseStart + 0.5
		end
		
		if turnXu ~= nil then
		--self.trace.ux, _, self.trace.uz = localToWorld( self.refNode, turnXu, 0, turnZu )
			self.trace.ux, _, self.trace.uz = localToWorld( self.headlandNode, turnXu, 0, turnZu )
		end
		if turnZc ~= nil then
		--self.trace.cx, _, self.trace.cz = localToWorld( self.refNode, turnXc, 0, turnZc )
			self.trace.cx, _, self.trace.cz = localToWorld( self.headlandNode, turnXc, 0, turnZc )
		end
	end
	
	if cumulate then
		local vector = {}	
		vector.dx,_,vector.dz = localDirectionToWorld( self.refNode, 0,0,1 )
		vector.px,_,vector.pz = AutoSteeringEngine.getAiWorldPosition( vehicle )
		
		local count = table.getn(self.trace.nodes)
		if count > 100 and self.trace.nodesIndex == count then
			local x = self.trace.nodes[self.trace.nodesIndex].px - self.trace.nodes[1].px
			local z = self.trace.nodes[self.trace.nodesIndex].pz - self.trace.nodes[1].pz		
		
			if x*x + z*z > 10000 then 
				self.trace.nodesIndex = 0
			end
		end
		self.trace.nodesIndex = self.trace.nodesIndex + 1
		
		self.trace.nodes[self.trace.nodesIndex] = vector
		
		AutoSteeringEngine.navigateToSavePoint( vehicle, 0 )

		if self.trace.ax == nil or notOutside then
			self.trace.ax, _, self.trace.az = localToWorld( self.refNode, vehicle.aseActiveX, 0 , vehicle.aseBack - 2 )
			self.trace.rx, _, self.trace.rz = localToWorld( self.refNode, 0, 0 , vehicle.aseBack - 2 )
		end
	end
end

------------------------------------------------------------------------
-- getRelativeTranslation
------------------------------------------------------------------------
function AIDriveStrategyMogli.getRelativeTranslation(root,node)
	if root == nil or node == nil then
		return 0,0,0
	end
	local x,y,z
	local state,result = pcall( getParent, node )
	if not ( state ) then
		return 0,0,0
	elseif result==root then
		x,y,z = getTranslation(node)
	else
		x,y,z = worldToLocal(root,getWorldTranslation(node))
	end
	return x,y,z
end

------------------------------------------------------------------------
-- getRelativeYRotation
------------------------------------------------------------------------
function AIDriveStrategyMogli.getRelativeYRotation(root,node)
	if root == nil or node == nil then
		return 0
	end
	local x, y, z = worldDirectionToLocal(node, localDirectionToWorld(root, 0, 0, 1))
	local dot = z
	dot = dot / Utils.vector2Length(x, z)
	local angle = math.acos(dot)
	if x < 0 then
		angle = -angle
	end
	return angle
end

------------------------------------------------------------------------
-- getRelativeZRotation
------------------------------------------------------------------------
function AIDriveStrategyMogli.getRelativeZRotation(root,node)
	if root == nil or node == nil then
		return 0
	end
	local x, y, z = worldDirectionToLocal(node, localDirectionToWorld(root, 0, 1, 0))
	local dot = y
	dot = dot / Utils.vector2Length(x, y)
	local angle = math.acos(dot)
	if x < 0 then
		angle = -angle
	end
	return angle
end

------------------------------------------------------------------------
-- applyRotation
------------------------------------------------------------------------
function AIDriveStrategyMogli:applyRotation( toIndex )

	local cumulRot, turnAngle = 0, 0
	if self.inField then
		turnAngle = Utils.clamp( self:getTurnAngle( ), -ASEGlobals.maxRotation, ASEGlobals.maxRotation )
		cumulRot  = turnAngle
	end 

	if not vehicle.isServer then return end
	
	AutoSteeringEngine.applySteering( vehicle, toIndex )

	local j0 = self.chainMax+2
	local jMax = self.chainMax
	if toIndex ~= nil and toIndex < self.chainMax then 
		jMax = toIndex 
	end
	for j=1,jMax do 
		if j0 > j and self.chainNodes[j].status < ASEStatus.rotation then
			j0 = j
		end
		if j >= j0 then
			self.chainNodes[j].tool = {}		
		
			--self.chainNodes[j].rotation = math.tan( self.chainNodes[j].steering ) * self.invWheelBase
			local length = self.chainNodes[j].length		
			local updateSteering

			if toIndex ~= nil and j > toIndex then
				self.chainNodes[j].rotation = 0
				updateSteering = true
			else
				self.chainNodes[j].rotation = 2 * math.asin( Utils.clamp( length * 0.5 * self.chainNodes[j].invRadius, -1, 1 ) )
				updateSteering = false
			end
			
			--if self.isInverted then
			--	self.chainNodes[j].rotation = -self.chainNodes[j].rotation
			--end
			
			local oldCumulRot = cumulRot
			cumulRot = cumulRot + self.chainNodes[j].rotation
			
			if self.smooth ~= nil then
				local restRot = ( 1 - self.smooth ) * self.chainNodes[j].rotation
				
				if     ( self.chainNodes[j].rotation > 0 
						 and turnAngle + cumulRot > 0
						 and not ( vehicle.aseLRSwitch ) )
						or ( self.chainNodes[j].rotation < 0 
						 and turnAngle + cumulRot < 0
						 and vehicle.aseLRSwitch ) then
					updateSteering = true
					if math.abs( turnAngle + cumulRot ) > math.abs( restRot ) then	
						self.chainNodes[j].rotation = self.chainNodes[j].rotation - restRot
					else
						self.chainNodes[j].rotation = self.chainNodes[j].rotation - turnAngle + cumulRot						
					end
				end
			end

			if     cumulRot >  vehicle.aseMaxRotation then
				self.chainNodes[j].rotation = self.chainNodes[j].rotation + vehicle.aseMaxRotation - cumulRot
				updateSteering                     = true
			elseif cumulRot < vehicle.aseMinRotation then
				self.chainNodes[j].rotation = self.chainNodes[j].rotation + vehicle.aseMinRotation - cumulRot
				updateSteering                     = true
			end
			
			if updateSteering then
				cumulRot = oldCumulRot + self.chainNodes[j].rotation
				self.chainNodes[j].invRadius  = math.sin( 0.5 * self.chainNodes[j].rotation ) * 2 / self.chainNodes[j].length
				if self.chainNodes[j].invRadius > 1E-6 then
					self.chainNodes[j].radius   = 1 / self.chainNodes[j].invRadius
					self.chainNodes[j].steering = math.atan2( self.wheelBase, self.chainNodes[j].radius )
				else
					self.chainNodes[j].radius   = 1E+6
					self.chainNodes[j].steering = 0
				end
				self.chainNodes[j].tool     = {}
			end

			self.chainNodes[j].cumulRot = cumulRot
			
			setRotation( self.chainNodes[j].index2, 0, self.chainNodes[j].rotation, 0 )
			self.chainNodes[j].status   = ASEStatus.rotation
		else
			cumulRot = cumulRot + self.chainNodes[j].rotation
		end
	end 
end

------------------------------------------------------------------------
-- setChainAngles
------------------------------------------------------------------------
function AIDriveStrategyMogli:setChainAngles( chainAngles, startIndex, mergeFactor )
	self:setChainInt( startIndex, "angles", nil, mergeFactor, chainAngles )
end

------------------------------------------------------------------------
-- setChainStraight
------------------------------------------------------------------------
function AIDriveStrategyMogli.setChainStraight( startIndex, startAngle )	
	self:setChainInt( startIndex, "straight", startAngle )
end

------------------------------------------------------------------------
-- setChainOutside
------------------------------------------------------------------------
function AIDriveStrategyMogli.setChainOutside( startIndex, angleSafety, smooth )
	self:setChainInt(  startIndex, "outside", angleSafety, smooth )
end

------------------------------------------------------------------------
-- setChainContinued
------------------------------------------------------------------------
function AIDriveStrategyMogli.setChainContinued( startIndex )
	self:setChainInt( startIndex, "continued" )
end

------------------------------------------------------------------------
-- setChainInside
------------------------------------------------------------------------
function AIDriveStrategyMogli.setChainInside( startIndex )
	self:setChainInt( startIndex, "inside" )	
end

------------------------------------------------------------------------
-- setChainInt
------------------------------------------------------------------------
function AIDriveStrategyMogli:setChainInt( startIndex, mode, angle, factor, chainAngles )
	
	local j0=1
	if startIndex ~= nil and 1 < startIndex and startIndex <= self.chainMax+1 then
		j0 = startIndex
	end

	local a  = 0 
	local af = self.angleFactor
	
	local angleSafety = Utils.getNoNil( angle, ASEGlobals.angleSafety )
	
	for j=j0,self.chainMax+1 do 
		local old = self.chainNodes[j].angle

		if     	mode  == "straight" 
				and angle ~= nil
				and j     == j0 then
			self.chainNodes[j].angle = angle
		elseif  mode ~= "straight" 
				and AutoSteeringEngine.isNotHeadland( vehicle, self.chainNodes[j].distance ) then
		
			if     mode == "outside" then
			-- setChainOutside
				self.chainNodes[j].angle = angleSafety 
			elseif mode == "inside" then
			-- setChainInside
				self.chainNodes[j].angle = -ASEGlobals.angleSafety 
			elseif mode == "continued" then
			-- setChainContinued
				self.chainNodes[j].angle = 0
			elseif mode == "angles" then
			-- setChainAngles
				if chainAngles == nil then
					print("Error: AutoSteeringEngine.setChainInt mode angles with empty chainAngles")				
				else
					self.chainNodes[j].angle = Utils.getNoNil( chainAngles[j], 0 )
				end
			else
				print("Error: AutoSteeringEngine.setChainInt wrong mode: "..tostring(mode))				
			end
			
			if factor ~= nil then
				if     mode == "outside" then
					if j <= self.chainMax then
						old = 0.8 * old + 0.2 * self.chainNodes[j+1].angle
					end
					self.chainNodes[j].angle = self.chainNodes[j].angle + factor * ( old - self.chainNodes[j].angle )
					if self.chainNodes[j].angle < 0 then
						self.chainNodes[j].angle = 0
					end
				else
					self.chainNodes[j].angle = self.chainNodes[j].angle + factor * ( old - self.chainNodes[j].angle )
				end			
			end
		elseif self.chainNodes[j].length > 1E-3 then 
			local targetRot = 0
------if ASEGlobals.straightTA > 0 and self.inField then
------	targetRot = -AutoSteeringEngine.getTurnAngle( vehicle )				
------end
			
			local m  = 5
			local a2 = 1+2^(-m)
			local a1 = -a2
			local steps = 0
			for step=1,m do
				steps = step
				local a = 0.5 * ( a1 + a2 )
				local b 
				if vehicle.aseLRSwitch then
					b =  a
				else
					b = -a
				end
				
				self.chainNodes[j].angle = b
				self:setChainStatus( j, ASEStatus.initial )
				self:applyRotation( j )	
				if math.abs( self.chainNodes[j].cumulRot - targetRot ) < 1E-4 then
					break
				elseif self.chainNodes[j].cumulRot > targetRot then
					a2 = a
				else
					a1 = a
				end
			end
		--if j == j0+1 then
		--	print(string.format("s: %d t: %3.0f° c: %3.0f° a: %4f lr: %s",
		--											steps,
		--											math.deg(targetRot),
		--											math.deg(self.chainNodes[j].cumulRot),
		--											self.chainNodes[j].angle,
		--											tostring(vehicle.aseLRSwitch) 
		--											))
		--end
			old = self.chainNodes[j].angle
		end
		
		if math.abs( self.chainNodes[j].angle - old ) > 1E-5 then
			self:setChainStatus( j, ASEStatus.initial )
		end
	end 
	self:applyRotation()			
end

------------------------------------------------------------------------
-- getParallelogram
------------------------------------------------------------------------
function AIDriveStrategyMogli:getParallelogram( xs, zs, xh, zh, diff, noMinLength )
	local xw, zw, xd, zd
	
	xd = zh - zs
	zd = xs - xh
	
	local l = math.sqrt( xd*xd + zd*zd )
	
	if l < 1E-3 then
		xw = xs
		zw = zs
	elseif noMinLength then
	elseif l < ASEGlobals.minLength then
		local f = ASEGlobals.minLength / l
		local x2 = xh - xs
		local z2 = zh - zs
		--xs = xs - f * x2
		--zs = zs - f * z2
		xh = xh + f * x2
		zh = zh + f * z2
		xd = zh - zs
		zd = xs - xh
		l  = math.sqrt( xd*xd + zd*zd )
	end
	
	if 0.999 < l and l < 1.001 then
		xw = xs + diff * xd
		zw = zs + diff * zd
	elseif l > 1E-3 then
		xw = xs + diff * xd / l
		zw = zs + diff * zd / l
	else
		xw = xs
		zw = zs
	end
	
	return xs, zs, xw, zw, xh, zh
end

------------------------------------------------------------------------
-- getChainPoint
------------------------------------------------------------------------
function AIDriveStrategyMogli:getChainPoint( i, tp )
	
	local tpx    = tp.x
	local dtpx   = 0
	
	if i > 1 and vehicle.aseWidthDec ~= 0 then
		local w = tp.width
		if 0 < ASEGlobals.widthMaxDec and ASEGlobals.widthMaxDec < w then
			w = ASEGlobals.widthMaxDec
		end
		dtpx = w * vehicle.aseWidthDec * self.chainNodes[i].distance
	end
	
	if vehicle.aseLRSwitch then
		tpx = tpx - dtpx
	else
		tpx = tpx + dtpx
	end
	
	if     self.chainNodes[i].status < ASEStatus.position
		--or i == 1
      or self.chainNodes[i].tool[tp.i]   == nil 
			or self.chainNodes[i].tool[tp.i].x == nil 
			or self.chainNodes[i].tool[tp.i].z == nil then

	--if math.abs( self.chainNodes[i].rotation ) > 1E-3 then
	--	local test1 = math.sin( 0.5 * self.chainNodes[i].rotation ) * 2 / self.chainNodes[i].length
	--	local test2 = self.chainNodes[i].radius * test1
	--	
	--	if math.abs( test2-1 ) > 1E-2 then
	--		print(string.format("Wrong rotation: %d, %3.1f° (%3.1f°), %3.1fm, %3.1fm, %3.1fm, %3.1f", 
	--												i, 
	--												math.deg( self.chainNodes[i].rotation ), 
	--												math.deg( self.chainNodes[i].cumulRot ), 
	--												self.chainNodes[i].radius,
	--												self.chainNodes[i].invRadius,
	--												test1,
	--												test2 ))
	--	end
	--end
				
		self.chainNodes[i].tool[tp.i] = {}
		self.chainNodes[i].tool[tp.i].a = tp.angle 

		setTranslation( self.chainNodes[i].index3, 0, 0, tp.b1 )
		setTranslation( self.chainNodes[i].index4, 0, 0, tp.z - tp.b1 )
			
		if i > 1 and math.abs( tp.b2 + tp.b3 ) > 1E-3 then
			if self.chainNodes[i-1].status < ASEStatus.position then
				self:getChainPoint( i-1, tp )
			end
			
			local dx, dy, dz = AIDriveStrategyMogli.getRelativeTranslation( self.chainNodes[i].index, self.chainNodes[i-1].index4 )
				
			self.chainNodes[i].tool[tp.i].a = math.atan2( dx, -dz )			
		end	
			
		setRotation( self.chainNodes[i].index3, 0, -self.chainNodes[i].tool[tp.i].a, 0 )
			
		local idx = self.chainNodes[i].index4
		local ofs = tpx
		
		if i == 1 and ( vehicle.aseTools[tp.i].aiForceTurnNoBackward or ASEGlobals.shiftFixZ <= 0 ) then
			if vehicle.aseLRSwitch	then
				ofs = -tp.offset 
				idx = tp.nodeLeft 
			else
				ofs = tp.offset 
				idx = tp.nodeRight
			end
		end
		
		self.chainNodes[i].tool[tp.i].x, self.chainNodes[i].tool[tp.i].y, self.chainNodes[i].tool[tp.i].z = localToWorld( idx, ofs, 0, 0 )
		self.chainNodes[i].status = ASEStatus.position
	end

	
	return self.chainNodes[i].tool[tp.i].x, self.chainNodes[i].tool[tp.i].y, self.chainNodes[i].tool[tp.i].z
	
end

------------------------------------------------------------------------
-- getChainBorder
------------------------------------------------------------------------
function AIDriveStrategyMogli:getChainBorder( i1, i2, toolParam, detectWidth )
	local b,t    = 0,0
	local bo,to  = 0,0
	local bw,tw  = 0,0
	local d      = false
	local i      = i1
	local count  = 0
	local offsetOutside = -1
	
	if vehicle.aseLRSwitch	then
		offsetOutside = 1
	end

	local fcOffset = -offsetOutside * toolParam.width
	local detectedBefore = false
	local dx, _, dz = localDirectionToWorld( self.refNode, -offsetOutside, 0, 0 )
	
	if 1 <= i and i <= self.chainMax then
		local xp,yp,zp = self:getChainPoint( i, toolParam )
		
		while i<=i2 and i<=self.chainMax do			
			local x2,y2,z2 = self:getChainPoint( i+1, toolParam )
			local xc       = x2
			local yc       = y2
			local zc       = z2
			
			if self.chainNodes[i].tool[toolParam.i] == nil then
				AutoTractor.printCallstack()
				AITractor.stopAITractor(vehicle)
			end
			
			local bi, ti = 0, 0
			local bj, tj = 0, 0
			local bk, tk = 0, 0
			local fi     = false
			
			if  		ASEGlobals.borderBuffer > 0
					and self.chainNodes[i].status >= ASEStatus.border
					and self.chainNodes[i].tool[toolParam.i].b ~= nil
					and self.chainNodes[i].tool[toolParam.i].t ~= nil then
					
				if self.chainNodes[i].tool[toolParam.i].t >= 0 then
					fi = true
					bi = self.chainNodes[i].tool[toolParam.i].b
					ti = self.chainNodes[i].tool[toolParam.i].t
					bj = self.chainNodes[i].tool[toolParam.i].bo
					tj = self.chainNodes[i].tool[toolParam.i].to

					if bi <= 0 then					
						if detectWidth and self.chainNodes[i].tool[toolParam.i].tw < 0 then
							local xkw       = xp + toolParam.offsetStd * dx
							local zkw       = zp + toolParam.offsetStd * dz
							
							for m=1,10 do
								local xm = xp + 0.1 * m * toolParam.width * dx
								local zm = zp + 0.1 * m * toolParam.width * dz
								if AutoSteeringEngine.isChainPointOnField( vehicle, xm, zm ) then
									xkw = xm
									zkw = zm
								end
							end
							
							bk, tk = AutoSteeringEngine.getFruitAreaWorldPositions( vehicle, vehicle.aseTools[toolParam.i], xp, zp ,xkw, zkw, xc, zc )
							
							if self.collectCbr then
								table.insert( self.cbr, { xp, zp ,xkw, zkw, xc, zc, bk, tk } )
							end
							
							self.chainNodes[i].tool[toolParam.i].bw = bk
							self.chainNodes[i].tool[toolParam.i].tw = tk
						end
					end
					
					bk = self.chainNodes[i].tool[toolParam.i].bw
					tk = self.chainNodes[i].tool[toolParam.i].tw
				end
				
			else			
				self.chainNodes[i].status = ASEStatus.border
				self.chainNodes[i].tool[toolParam.i].t  = -1
				self.chainNodes[i].tool[toolParam.i].b  = 0
				self.chainNodes[i].tool[toolParam.i].bo = 0
				self.chainNodes[i].tool[toolParam.i].to = 0
				self.chainNodes[i].tool[toolParam.i].bw = 0
				self.chainNodes[i].tool[toolParam.i].tw = 0
				
				if      not AutoSteeringEngine.hasCollision( vehicle, self.chainNodes[i].index )
						and not AutoSteeringEngine.hasCollision( vehicle, self.chainNodes[i+1].index )
						and AutoSteeringEngine.isChainPointOnField( vehicle, xp, zp ) then
						
					local f = 1
					while f > 0.01 do
						xc = xp + f*(x2-xp)
						yc = yp + f*(y2-yp)
						zc = zp + f*(z2-zp)
						if AutoSteeringEngine.isChainPointOnField( vehicle, xc, zc ) then
							fi = true
							break
						end
						f = f - 0.334
					end
					
					if      fi
							and self.respectStartNode 
							and ( AutoSteeringEngine.getRelativeZTranslation( self.startNode, self.chainNodes[i].index )   < 0
								 or AutoSteeringEngine.getRelativeZTranslation( self.startNode, self.chainNodes[i+1].index ) < 0 ) then
					--print("respecting start node "..tostring(i))
						fi = false
					end
					
					if fi then	
						self.chainNodes[i].tool[toolParam.i].t  = 0
						
						bi, ti  = AutoSteeringEngine.getFruitArea( vehicle, xp, zp, xc, zc, offsetOutside, toolParam.i )		
						if toolParam.offsetStd > 0 and bi <= 0 then
							bj, tj  = AutoSteeringEngine.getFruitArea( vehicle, xp, zp, xc, zc, -toolParam.offsetStd * offsetOutside, toolParam.i )			
						end
						if bi <= 0 then
							if detectWidth then
								local xkw       = xp + toolParam.offsetStd * dx
								local zkw       = zp + toolParam.offsetStd * dz
								
								for m=1,10 do
									local xm = xp + 0.1 * m * toolParam.width * dx
									local zm = zp + 0.1 * m * toolParam.width * dz
									if AutoSteeringEngine.isChainPointOnField( vehicle, xm, zm ) then
										xkw = xm
										zkw = zm
									end
								end
								
								bk, tk = AutoSteeringEngine.getFruitAreaWorldPositions( vehicle, vehicle.aseTools[toolParam.i], xp, zp ,xkw, zkw, xc, zc )
								
								if self.collectCbr then
									table.insert( self.cbr, { xp, zp ,xkw, zkw, xc, zc, bk, tk } )
								end
							else
								tk = -1
							end
						end
						
						if self.collectCbr then
							local cbr = { AutoSteeringEngine.getParallelogram( xp, zp, xc, zc, offsetOutside ) }
							cbr[7]    = bi
							cbr[8]    = ti
							if self.cbr == nil then
								self.cbr = {}
							end							
							table.insert( self.cbr, cbr )
						end
						
						self.chainNodes[i].tool[toolParam.i].b  = bi
						self.chainNodes[i].tool[toolParam.i].t  = ti
						self.chainNodes[i].tool[toolParam.i].bo = bj
						self.chainNodes[i].tool[toolParam.i].to = tj
						self.chainNodes[i].tool[toolParam.i].bw = bk
						self.chainNodes[i].tool[toolParam.i].tw = tk
					end
				end
			end

			if fi then
				b  = b  + bi
				t  = t  + ti
				bo = bo + bj
				to = to + tj
				
				if tk >= 0 then
					bw = bw + bk
					tw = tw + tk
				end
				
				self.chainNodes[i].isField = true
				if b > 0 then
					self.chainNodes[i].hasBorder = true
				end
				if bi > 0 or bj > 0 or bk > 0 then
					self.chainNodes[i].detected = true
					detectedBefore = true
				end
			end
			
			if self.completeTrace then
			-- continue...
			elseif b > 0 then
				return b, t, bo, to, bw, tw
			elseif ASEGlobals.maxOutside >= 0.1 and self.inField and bi <= 0 and bj <= 0 and i > self.chainStep0 then
				local bt, tt = 0, 1
				if fi then
					bt, tt = AutoSteeringEngine.getFruitArea( vehicle, xp, zp, xc, zc, -offsetOutside * ASEGlobals.maxOutside, toolParam.i )
				end
				if bt <= 0 and tt > 0 then
					return b, t, bo, to, bw, tw
				end
			end
			
			i = i + 1
			xp = x2
			yp = yc
			zp = z2
		end
	end
	
	return b, t, bo, to, bw, tw
end

------------------------------------------------------------------------
-- getAllChainBorders
------------------------------------------------------------------------
function AIDriveStrategyMogli:getAllChainBorders( i1, i2, detectWidth )
	local b,t   = 0,0
	local bo,to = 0,0
	local bw,tw = 0,0
	
	if i1 == nil then i1 = 1 end
	if i2 == nil then i2 = self.chainMax end
	
	local i      = i1
	if 1 <= i and i <= self.chainMax then
		while i<=i2 and i<=self.chainMax do				
			self.chainNodes[i].hasBorder = false
			i = i + 1
		end
	end
		
	for _,tp in pairs(self.toolParams) do	
		if not ( tp.skip ) then
			local bi,ti,bj,tj,bk,tk = self:getChainBorder( i1, i2, tp, detectWidth )				
			b  = b  + bi
			t  = t  + ti
			bo = bo + bj
			to = to + tj
			bw = bw + bk
			tw = tw + tk
		end
	end
	
	return b,t,bo,to,bw,tw
end

------------------------------------------------------------------------
-- processChainGetScore
------------------------------------------------------------------------
function AIDriveStrategyMogli:processChainGetScore( a, bi, ti, bo, to )
	if     bi > 0 then
		--if bi >= ti then
		--	return 4
		--end
		--return 3 + bi / ti
		return 5 - a
	elseif bo > 0 then
		if bo >= to then
			return 3 
		end
		return 2 + bo / to
	end
	return 1+a
end

------------------------------------------------------------------------
-- processChainSetAngle
------------------------------------------------------------------------
function AIDriveStrategyMogli:processChainSetAngle( a, j, indexMax )
	local indexStraight = indexMax + 1
	if     a == 0 then
		for i=1,indexMax do
			if math.abs( self.chainNodes[i].angle ) > 1E-5 then
				self:setChainStatus( i, ASEStatus.initial )
			end
			self.chainNodes[i].angle = 0
		end
	elseif a > 0 then
		for i=1,j do
			if math.abs( self.chainNodes[i].angle ) > 1E-5 then
				self:setChainStatus( i, ASEStatus.initial )
			end
			self.chainNodes[i].angle = 0
		end
		for i=j+1,indexMax do
			if math.abs( self.chainNodes[i].angle - a ) > 1E-5 then
				self:setChainStatus( i, ASEStatus.initial )
			end
			self.chainNodes[i].angle = a
		end		
	else
		for i=1,j do
			if math.abs( self.chainNodes[i].angle - a ) > 1E-5 then
				self:setChainStatus( i, ASEStatus.initial )
			end
			self.chainNodes[i].angle = a
		end
		indexStraight = j+1
		if indexStraight <= indexMax then
			if math.abs( self.chainNodes[indexStraight].angle + a ) > 1E-5 then
				self:setChainStatus( indexStraight, ASEStatus.initial )
			end
			self.chainNodes[indexStraight].angle = -a
		end
		indexStraight = indexStraight + 1
	end

	self:setChainStraight( indexStraight )
	self:applyRotation()	
end

------------------------------------------------------------------------
-- processChain
------------------------------------------------------------------------
function AIDriveStrategyMogli:processChain( smooth, useBuffer, inField )

	if self.toolParams == nil or table.getn( self.toolParams ) < 1 then
		return false, 0,0
	end

	local s = 1 
	if smooth ~= nil and smooth > 0 then
		s = Utils.clamp( 1 - smooth, 0.1, 1 ) 
	end 
	
	AutoSteeringEngine.initSteering( vehicle )	
	self.IamDetecting = true

	self.valid   = false
	self.smooth  = nil
	self.inField = false
	
	if s < 1 then
		self.smooth      = s
		self.angleFactor = self.angleFactor * self.smooth
	end
	
	if inField then
		self.inField = true
	end
	
	if ASEGlobals.collectCbr > 0 then
		self.collectCbr	= true
		self.cbr	      = {} 
		self.pcl        = {}
	else
		self.collectCbr	= nil
		self.cbr	      = nil
		self.pcl        = nil
	end		

	local detected    = false
	local angle       = 0
	local border      = 0
	local indexMax0   = math.min( self.chainMax, self.chainStep2 )

	while   indexMax0 < self.chainMax
			and self.chainNodes[indexMax0].distance < vehicle.aseWidth do
		indexMax0 = indexMax0 + 1
	end
	
	local indexMax    = indexMax0
	local chainBorder
	
	vehicle.aseProcessChainInfo = ""
		
	if      self.inField
			and self.chainStep1 > 0 
			and self.chainStep1 < indexMax 
			and vehicle.aseMaxLooking > 0.1 then
		local turnAngle = self:getTurnAngle()
		if vehicle.aseLRSwitch then
			turnAngle = -turnAngle
		end
		
		local ma = 0.2 * vehicle.aseMaxLooking
		if -vehicle.aseMaxLooking < turnAngle and turnAngle < ma then
			local im
			if AutoSteeringEngine.hasFruits( vehicle, -1 ) then
				im = self.chainStep1
			else
				im = math.max( 1, ASEGlobals.chainBorder )
			end
		
			if turnAngle > -ma then
				im = math.min( indexMax, im + math.floor( ( indexMax - self.chainStep1 ) * ( turnAngle + ma ) / ( ma + ma ) + 0.5 ) )
			end
			local tl = self:getTraceLength()
			local ml = math.max( self.chainNodes[indexMax].distance - tl, math.max( vehicle.aseWidth, self.radius ) )
			while   indexMax > im
 			    and self.chainNodes[indexMax-1].distance >= ml do
				indexMax = indexMax - 1
			end
		end
		
	--print(tostring(math.floor( math.deg( turnAngle ) + 0.5 )).." => "..tostring( indexMax ).." / "..tostring( self.chainStep2 ))
		
		chainBorder = Utils.clamp( ASEGlobals.chainBorder, 1, indexMax )
	else
		chainBorder = indexMax
	end
	
	AutoSteeringEngine.syncRootNode( vehicle, true )
	local best

	local j0 = Utils.clamp( self.chainStep0, 1, indexMax )
	local j1 = Utils.clamp( self.chainStep4, 1, indexMax )
	
	for i=1,self.chainMax do
		self.chainNodes[i].detected = false
	end
			
	while true do

		self:setChainStatus(1, ASEStatus.initial )
		self:processChainSetAngle( 0, indexMax, indexMax )
		local bi, ti, bo, to, bw, tw = self:getAllChainBorders(ASEGlobals.chainStart, indexMax, true )
		
		if bi > 0 or bo > 0 or bw > 0 then
			detected = true
		end

		best = { self:processChainGetScore( 0, bi, ti, bo, to ), indexMax, indexMax, 0, bi }
		
		if bi > 0 or bo > 0 then
			-- maybe we are too close
			detected = true
			
			for step=1,ASEGlobals.chainDivideOut do
				local exitLoop = false
				local a2 = step / ASEGlobals.chainDivideOut	
			--local a = math.min( 0.6*a2*(a2+0.666666667), 1 )
				local a = 1-math.sin( 0.5*math.pi*(1-a2) )
				
				local m = 0
				while m < indexMax do
					self:processChainSetAngle( a, m, indexMax )
					bi, ti, bo, to = self:getAllChainBorders(ASEGlobals.chainStart, indexMax )
					
					local s = self:processChainGetScore( a, bi, ti, bo, to )
					
					if best[1] >= s then
						best  = { s, m, indexMax, a, bi }
					end
					
					if     bi >  0 then
						break
					elseif bo <= 0 then
					-- not s < 0 (50% border) but s < a => the bigger the angle the close we may get to the border
						exitLoop = true
					end
					
					if m > 0 or j1 < 1 then
						m = m + 1
					else
						m = j1
					end
				end

				if exitLoop then
					break
				end
			end
						
		else
			self:processChainSetAngle( -1, indexMax, indexMax )
			bi, ti, bo, to = self:getAllChainBorders(ASEGlobals.chainStart, indexMax )
		
			if bi <= 0 and bo <= 0 then
				-- there is nothing
				vehicle.aseProcessChainInfo = "nothing found"
				best  = { -1.4, indexMax, indexMax, -1, 0 }
			else
				-- get closer to border
				detected = true
				
				for step=1,ASEGlobals.chainDivideIn do
					local exitLoop = false
					local a2 = step / ASEGlobals.chainDivideIn	
				--local a = - math.min( a2*a2, 1 )
				--local a = - math.min( 0.6*a2*(a2+0.666666667), 1 )
					local a = math.sin( 0.5*math.pi*(1-a2) )-1
					
					self:setChainStatus(1, ASEStatus.initial )
					for j=j0,indexMax do
						self:processChainSetAngle( a, j, indexMax )
						bi, ti, bo, to = self:getAllChainBorders(ASEGlobals.chainStart, indexMax )
						
						if bi > 0 or bo > 0 then
							detected = true
						end
						
						if bi > 0 then		
							local k1 = -1
							for k=1,indexMax do
								if self.chainNodes[k].hasBorder then
									k1 = k
									break
								end
							end
							vehicle.aseProcessChainInfo = vehicle.aseProcessChainInfo..string.format("bi>0: %2d %2d %2d %2d %2d\n",step,j,bi,bo,k1)
							if j == j0 and ASEGlobals.debug1 > 0 then
								-- exit completely
								exitLoop = true
							end
							break
						end
						
						local s = self:processChainGetScore( a, bi, ti, bo, to )
												
						if best[1] >= s then
							best  = { s, j, indexMax, a, bi }
						end
						if bo > 0 then
							vehicle.aseProcessChainInfo = vehicle.aseProcessChainInfo..string.format("bo>0: %2d %2d %2d %2d\n",step,j,bi,bo)
							if j == j0 then
								-- too close to border => it will not get better
								exitLoop = true
							end
							break
						end
					end

					if exitLoop then
						break
					end
				end
			end
		end
		
		if detected or indexMax >= self.chainMax then
			break
		end
		
		indexMax  = indexMax + 1 
	end
	
	local j  = best[2]
	indexMax = best[3]
	local a  = best[4]
	border   = best[5]
	
	self:processChainSetAngle( a, j, indexMax )	
--border, total = self:getAllChainBorders(ASEGlobals.chainStart, indexMax )
		
	while border > 0 and indexMax > chainBorder do 
		indexMax      = indexMax - 1 
		border, total = self:getAllChainBorders(ASEGlobals.chainStart, indexMax )
		if total <= 0 then
			indexMax      = indexMax + 1 
			border, total = self:getAllChainBorders(ASEGlobals.chainStart, indexMax )
			break
		end 
	end
	
	angle = self.chainNodes[1].steering
	for i=2,j do
		if math.abs( angle ) < math.abs( self.chainNodes[j].steering ) then
			angle = self.chainNodes[j].steering
		end
	end
	
	AutoSteeringEngine.processIsAtEnd( vehicle, a )	
--print(tostring(best[1]).." / "..tostring(j).." / "..tostring(indexMax).." / "..tostring(a).." / "..tostring(math.floor( math.deg( angle ) + 0.5 ) ).." / "..tostring(border).." / "..tostring(detected))
	
	vehicle.aseLastIndexMax = indexMax 	
		
	local c = 1
	if     a > 0 then
		c = ASEGlobals.correctionOut
	elseif a < 0 then
		c = ASEGlobals.correctionIn 
	end
	if math.abs( c ) > 1E-3 and math.abs( c - 1 ) > 1E-3 then
		angle = angle ^ c
	end
	
	self.completeTrace   = nil	
	self.lastAngleFactor = a
	
	return detected, angle, border
end




