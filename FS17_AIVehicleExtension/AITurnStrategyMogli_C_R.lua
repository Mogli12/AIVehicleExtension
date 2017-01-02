
--
-- AITurnStrategyMogli_C_R
--

AITurnStrategyMogli_C_R = {}
local AITurnStrategyMogli_C_R_mt = Class(AITurnStrategyMogli_C_R, AITurnStrategyMogli)

function AITurnStrategyMogli_C_R:new(customMt)
	if customMt == nil then
		customMt = AITurnStrategyMogli_C_R_mt
	end
	local self = AITurnStrategy:new(customMt)
	return self
end

--============================================================================================================================
-- fillStages
--============================================================================================================================
function AITurnStrategyMogli_C_R:detect( dt, vX,vY,vZ, turnData, stage, tX, tZ, maxSpeed, distanceToStop )

	local veh = self.vehicle 
	
	local moveForwards = stage.moveForwards
	
	if     stage.id == self.finalStage1 then
		AutoSteeringEngine.syncRootNode( veh, true )
		AutoSteeringEngine.setChainStraight( veh )
		local m = math.min( veh.aiveChain.chainMax, veh.aiveChain.chainStep2 )
		if      veh.aiveChain.chainStep1 > 0 
				and veh.aiveChain.chainStep1 < m then
			m = veh.aiveChain.chainStep1
		end
		if AutoSteeringEngine.getAllChainBorders( veh, 1, m ) > 0 then
		-- end the turn
			return
		end
	elseif stage.id == self.finalStage2 then
		moveForwards = false 
		
		local detected, angle2, border, tX2, _, tZ2 = AutoSteeringEngine.processChain( veh )
		if border > 0 then			
			tX2, tZ2 = AutoSteeringEngine.getWorldTargetFromSteeringAngle( veh, 0 )
			return tX2, tZ2, false, maxSpeed, math.huge
		else
			return 
		end 
	else
		print("ERROR in AITurnStrategyMogli_C_R: unknown turn stage!!!")
	end
	
	return tX, tZ, moveForwards, maxSpeed, distanceToStop
end

--============================================================================================================================
-- fillStages
--============================================================================================================================
function AITurnStrategyMogli_C_R:fillStages( turnData )

	local vehicle = self.vehicle 
	local points 
	local extraF  = 1
	local factor  = 1
	if vehicle.aiveChain.leftActive then
		factor = -1
	end
	
	local finalX = vehicle.aiveChain.trace.cx
	local finalZ = vehicle.aiveChain.trace.cz
	
	local dirCX,_,dirCZ = localDirectionToWorld( vehicle.aiveChain.headlandNode, 0, 0, 1 )	
	local dirFX,_,dirFZ = localDirectionToWorld( vehicle.aiveChain.headlandNode, factor, 0, 0 )			

	finalX = finalX - ( vehicle.aiveChain.maxZ + extraF ) * dirFX + 0.5 * dirCX
	finalZ = finalZ - ( vehicle.aiveChain.maxZ + extraF ) * dirFZ + 0.5 * dirCZ

	local curX,_,curZ   = AutoSteeringEngine.getAiWorldPosition( vehicle )
	
	local deltaX,_,deltaZ = worldDirectionToLocal( vehicle.aiveChain.headlandNode, finalX-curX, 0, finalZ-curZ )
	deltaX = factor * deltaX
	
	local pi2 = 0.5 * math.pi
	local alpha, s, c
	local r = vehicle.acDimensions.radius
	local offsetX = 0
	
	if     deltaX < -r then
		alpha   = pi2
		offsetX = -deltaX 
	elseif deltaX < r then
		alpha = math.acos( 0.5 * ( deltaX / r + 1 ) )
	else
		alpha = 0
	end
	
--print(string.format("%4f %4f, %4f, %4f°", r, deltaX, deltaZ, math.deg(alpha) ))
	
	points = {}
	
	s = math.sin( alpha )
	c = math.cos( alpha )
	
	local c2x = finalX - r * dirCX - offsetX * dirFX
	local c2z = finalZ - r * dirCZ - offsetX * dirFZ
	
	s = math.sin( pi2-alpha )
	c = math.cos( pi2-alpha )
	local wx  = c2x + r * ( c * dirCX - s * dirFX )
	local wz  = c2z + r * ( c * dirCZ - s * dirFZ )
	
	s = math.sin( alpha )
	c = math.cos( alpha )
	local c1x = wx - r * c * dirFX + r * s * dirCX
	local c1z = wz - r * c * dirFZ + r * s * dirCZ
	
--local t1X, _, t1Z = worldToLocal( vehicle.aiveChain.headlandNode, c1x + r * dirFX, vehicle.acAiPos[2], c1z + r * dirFZ )
--local t2X, _, t2Z = worldToLocal( vehicle.aiveChain.headlandNode, wx, vehicle.acAiPos[2], wz )
--local t3X, _, t3Z = worldToLocal( vehicle.aiveChain.headlandNode, c2x, vehicle.acAiPos[2], c2z )
--print(string.format("%4f, %4f / %4f, %4f / %4f, %4f", t1X, t1Z, t2X, t2Z, t3X, t3Z))
	
	local steps = 5
	
	for i=steps,0,-1 do
		local x = c1x + r * dirFX - i * dirCX
		local z = c1z + r * dirFZ - i * dirCZ
		table.insert( points, self:getPoint( x, z, dirCX, dirCZ ) )	
	end
	
	self:addStageWithPoints( true, points )
		
	points = {}
	
	steps = 1 + math.floor( r * alpha )

	for i=0,steps do
		local a = i * alpha / steps
		local s = math.sin( a )
		local c = math.cos( a ) 
		local dx,_,dz = localDirectionToWorld( vehicle.aiveChain.headlandNode, factor * s, 0, c )		
		local x = c1x + r * ( c * dirFX - s * dirCX )
		local z = c1z + r * ( c * dirFZ - s * dirCZ )
		table.insert( points, self:getPoint( x, z, dx, dz ) )	
		if i == steps then
			table.insert( points, self:getPoint( x-dx, z-dz, dx, dz ) )	
		end
	end
	
	self:addStageWithPoints( false, points )
	
	points = {}	
	
	steps = 1 + math.floor( r * ( pi2-alpha ) )
	
	for i=steps,0,-1 do
		local a = i * ( pi2-alpha ) / steps
		local s = math.sin( a )
		local c = math.cos( a ) 
		local dx,_,dz = localDirectionToWorld( vehicle.aiveChain.headlandNode, factor * c, 0, s )		
		local x = c2x + r * ( c * dirCX - s * dirFX )
		local z = c2z + r * ( c * dirCZ - s * dirFZ )
		table.insert( points, self:getPoint( x, z, dx, dz ) )	
	end

	if offsetX > 0 then
		table.insert( points, self:getPoint( finalX, finalZ, dirFX, dirFZ ) )	
	end
	
	table.insert( points, self:getPoint( finalX + extraF * dirFX, finalZ + extraF * dirFZ, dirFX, dirFZ ) )	
	
	self.finalStage1 = self:addStageWithPoints( true, points, AITurnStrategyMogli_C_R.detect )
	self.finalStage2 = self:addStageWithFunction( true, points, AITurnStrategyMogli_C_R.detect )
	
end

