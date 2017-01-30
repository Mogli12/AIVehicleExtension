
--
-- AITurnStrategyMogli_U_O
--

AITurnStrategyMogli_U_O = {}
local AITurnStrategyMogli_U_O_mt = Class(AITurnStrategyMogli_U_O, AITurnStrategyMogli)

function AITurnStrategyMogli_U_O:new(customMt)
	if customMt == nil then
		customMt = AITurnStrategyMogli_U_O_mt
	end
	local self = AITurnStrategy:new(customMt)
	return self
end

--============================================================================================================================
-- onStartTurn
--============================================================================================================================
function AITurnStrategyMogli_U_O:startTurn( ... )
	AITurnStrategyMogli_U_O:superClass().startTurn( self, ... )
	self.stages = nil
end

--============================================================================================================================
-- onEndTurn
--============================================================================================================================
function AITurnStrategyMogli_U_O:onEndTurn( ... )
	AITurnStrategyMogli_U_O:superClass().onEndTurn( self, ... )
	AIVehicleExtension.setAIImplementsMoveDown( self.vehicle, true, self.vehicle.aiveHas.combine )
	self.stages = nil
end

--============================================================================================================================
-- getNextStage
--============================================================================================================================
function AITurnStrategyMogli_U_O:getNextStage( dt, vX,vY,vZ, turnData, stageId )
	if stageId == 1 then
		self:fillStages( turnData )
	end
	
	if self.stages[stageId] ~= nil then
--	return self:getStageFromPoints( self.stages[stageId], true, 5 )
		return self:getStageCircle( unpack( self.stages[stageId] ) )
--elseif stageId == 2 then
--	return self:getStageFromFunction( AITurnStrategyMogli_U_O.getDD_moveForward, {} )
	end
end

--============================================================================================================================
-- getDD_moveForward
--============================================================================================================================
function AITurnStrategyMogli_U_O:getDD_moveForward( self, dt, vX,vY,vZ, turnData )
end

--============================================================================================================================
-- fillStages
--============================================================================================================================
function AITurnStrategyMogli_U_O:fillStages( turnData )
	self.stages = {}
	
	local vehicle = self.vehicle 
	local curX,_,curZ   = AutoSteeringEngine.getAiWorldPosition( vehicle )
	local finalX = vehicle.aiveChain.trace.ux
	local finalZ = vehicle.aiveChain.trace.uz
	local dirZx,_,dirZz = localDirectionToWorld( vehicle.aiveChain.headlandNode, 0, 0, 1 )	

	local rV = vehicle.acDimensions.radius * 1.2
	for _,implement in pairs(vehicle.aiImplementList) do
		rV = math.max(rV, AIVehicleUtil.getMaxToolRadius(implement));
	end
	
	local rT = rV
	for _,tool in pairs(vehicle.aiveChain.tools) do
		if tool.aiForceTurnNoBackward then
			local _,_,b1  = AutoSteeringEngine.getRelativeTranslation( vehicle.aiveChain.refNode, tool.refNode )
			b1            = math.max( 0, -b1 )
			local b2
			if tool.b2 == nil then
				b2          = math.max( 0, -tool.zb )
			else
				b2          = math.max( 0, -tool.b2 )
			end
			local b3 = 0
			if tool.doubleJoint then
				b3 = tool.b3
			end
			if b1 < 0 and b2 < -1 then
				b2 = b2 + 0.5
				b1 = b1 - 0.5
			end
			rT = math.min( rT, math.sqrt( math.max( rV*rV + b1*b1 - b2*b2 - b3*b3, 0 ) ) )
		end
	end
	
	local lX, lZ = worldDirectionToLocal( vehicle.aiveChain.headlandNode, finalX - curX, 0, finalZ - curZ )
	local dirXx, dirXz
	local rC = rV
	if lX < 0 then
		dirXx,_,dirXz = localDirectionToWorld( vehicle.aiveChain.headlandNode, -1, 0, 0 )
		lX = -lX
	else
		dirXx,_,dirXz = localDirectionToWorld( vehicle.aiveChain.headlandNode,  1, 0, 0 )	
		rC = -rV
	end

	local startAngle = math.acos( -dirXz )
	if dirXx > 0 then
		startAngle     = -startAngle 
	end
	local endAngle   = startAngle + math.pi

	
	local centerX = -rT
	local centerZ = math.max( lZ, 0 ) + 1 - vehicle.aiveChain.maxZ
	local shiftX  = 0
	local extraA  = 0
	local width   = rV + rT
	if     lX < width - 0.5 then
		local dx = math.min( 1, ( width - lX ) / ( rV + rV ) )
		extraA  = math.acos( 1 - dx )
		centerZ = centerZ + math.sin( extraA ) * ( rV + rV )
	elseif lX > width + 0.5 then
		shiftX = lX - width
	end

	self:addDebugText(string.format("%5.2f %5.2f",curX,curZ))
	self:addDebugText(string.format("%5.2f %5.2f",finalX,finalZ))
	self:addDebugText(string.format("%5.2f %5.2f",centerX,centerZ))
	self:addDebugText(string.format("%5.2f° %5.2f°",math.deg(startAngle),math.deg(endAngle)))
	
--
--local lastX = curX
--local lastZ = curZ
--local s     = 0
--
--if extraA > 0 then
--	s = s + 1 
--	self.stages[s] = {}
--	for i=1,4 do
--		local a  = 0.2 * i * extraA  
--		local x = math.cos( a ) * rV - rV
--		local z = math.sin( a ) * rV 
--		local wx = curX + x * dirXx + z * dirZx
--		local wz = curZ + x * dirXz + z * dirZz 
--		
--		self:addDebugText(string.format("%5.2f %5.2f",wx,wz))
--		
--		table.insert( self.stages[s], self:getPoint( wx, wz, wx - lastX, wz - lastZ ) )
--		lastX = wx
--		lastZ = wz
--	end
--
--	s = s + 1
--	self.stages[s] = {}
--	for i=0,4 do
--		local a  = -math.pi * 0.5 - extraA + 0.2 * i * extraA  
--		local x  = centerX + math.sin( a ) * rV
--		local z  = centerZ + math.cos( a ) * rV
--		local wx = finalX + x * dirXx + z * dirZx
--		local wz = finalZ + x * dirXz + z * dirZz 
--		
--		self:addDebugText(string.format("%5.2f %5.2f",wx,wz))
--		
--		table.insert( self.stages[s], self:getPoint( wx, wz, wx - lastX, wz - lastZ ) )
--		lastX = wx
--		lastZ = wz
--	end			
--end
--
--s = s + 1
--self.stages[s] = {}
--
--for i=-10,10 do
--	local a  = math.pi * 0.05 * i
--	local x  = centerX + math.sin( a ) * rV
--	if i < 0 then
--		x = x - shiftX 
--	end
--	local z  = centerZ + math.cos( a ) * rV
--	local wx = finalX + x * dirXx + z * dirZx
--	local wz = finalZ + x * dirXz + z * dirZz 
--	
--	self:addDebugText(string.format("%5.2f %5.2f",wx,wz))
--	
--	if i == 0 then
--		s = s + 1
--		self.stages[s] = {}
--	end
--	
--	table.insert( self.stages[s], self:getPoint( wx, wz, wx - lastX, wz - lastZ ) )
--	lastX = wx
--	lastZ = wz
--end


	-- centerX, centerZ, radius, endAngle, moveForwards, distanceToStop
	local centerX2 = centerX - shiftX * dirXx
	local centerZ2 = centerZ - shiftX * dirXz
	
	local s = 0
	
--if extraA > 0 and extraA > 0.05 * math.pi then
--	local wx = curX - rV * dirXx
--	local wz = curZ - rV * dirXz
--
--	s = s + 1 
--	self.stages[s] = { wx, wz, -rC, startAngle - extraA, true, ( math.pi + extraA ) * rV }
--end
	
	local wx = finalX + centerX2 * dirXx + centerZ2 * dirZx
	local wz = finalZ + centerX2 * dirXz + centerZ2 * dirZz 
	
--if extraA > 0 and extraA > 0.05 * math.pi then
--	s = s + 1 
--	self.stages[s] = { wx, wz, rC, startAngle, true, math.pi * rV }
--end	

	s = s + 1 
	self.stages[s] = { wx, wz, rC, 0.5*( startAngle + endAngle ), true, 0.5 * math.pi * rV }
	
	wx = finalX + centerX * dirXx + centerZ * dirZx
	wz = finalZ + centerX * dirXz + centerZ * dirZz 
	
	s = s + 1 
	self.stages[s] = { wx, wz, rC, endAngle, true, 0 }
	
	self:addDebugText(tostring(table.getn(self.stages)))
	
	self.updateDebugPrint = true
end

--============================================================================================================================
-- update
--============================================================================================================================
function AITurnStrategyMogli_U_O:update(dt)
	if self.updateDebugPrint then
		self.updateDebugPrint = nil 
		for s=1,table.getn( self.stages ) do
			local centerX, centerZ, radius, endAngle, moveForwards, distanceToStop = unpack( self.stages[s] )
			
			local wx, wz
			if centerX ~= nil and centerZ ~= nil and endAngle ~= nil and radius ~= nil then
				wx = centerX + math.sin( endAngle ) * radius 
				wz = centerZ + math.cos( endAngle ) * radius 
			end
			
			self:addDebugText(tostring(s)..": "..
						tostring(centerX).." "..
						tostring(centerZ).." "..
						tostring(radius).." "..
						tostring(endAngle).." "..
						tostring(moveForwards).." "..
						tostring(distanceToStop).." => "..
						tostring(wx).." "..
						tostring(wz))
		end
	end
	
	if self.vehicle ~= nil and self.stages ~= nil then -- and self.vehicle.acShowTrace then
	
		for s=1,table.getn( self.stages ) do
			local centerX, centerZ, radius, endAngle, moveForwards, distanceToStop = unpack( self.stages[s] )
			
			local x = centerX 
			local z = centerZ 
			local y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, 1, z)			

			local dx = radius * math.sin( endAngle )
			local dz = radius * math.cos( endAngle )
			
			local cr = 0.5
			local cb = 0.5
			
			drawDebugLine(  x, y, z,cr,1,cb, x, y+4, z,cr,1,cb)
			drawDebugPoint( x, y+4, z	, 1, 1, 1, 1 )
			drawDebugLine(  x, y+2, z,cr,1,cb, x+dx, y+2, z+dz,cr,1,cb)				
			
			x = x + dx
			z = z + dz
			

			dx = radius * math.sin( endAngle - 1 / radius ) - dx
			dz = radius * math.cos( endAngle - 1 / radius ) - dz

			drawDebugLine(  x, y+2, z,cr,1,cb, x+dx, y+2, z+dz,cr,1,cb)				
		end
	end
	
	if self.lastDriveData ~= nil then
		local tX, tZ, moveForwards, allowedToDrive, distanceToStop, angle = unpack( self.lastDriveData )
		local y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, tX, 1, tZ)			
		drawDebugLine( tX, y, tZ, 1,0,0, tX, y+4, tZ, 1,0,0, 1 )
	end
	
	
end
