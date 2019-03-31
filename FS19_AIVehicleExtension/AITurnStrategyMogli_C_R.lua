
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
-- onStartTurn
--============================================================================================================================
function AITurnStrategyMogli_C_R:startTurn( ... )
	AITurnStrategyMogli_C_R:superClass().startTurn( self, ... )
	self.stages = nil
end

--============================================================================================================================
-- onEndTurn
--============================================================================================================================
function AITurnStrategyMogli_C_R:onEndTurn( ... )
	AITurnStrategyMogli_C_R:superClass().onEndTurn( self, ... )
	self.stages = nil
end

--============================================================================================================================
-- getNextStage
--============================================================================================================================
function AITurnStrategyMogli_C_R:getNextStage( dt, vX,vY,vZ, turnData, stageId )
	local veh = self.vehicle 
	self:addDebugText(tostring(stageId))
	if     stageId == 1 then
		veh:aiTurnProgress( 0.01, veh.acParameters.leftAreaActive )
	--return self:getCombinedStage( self:getStageFromFunction( AITurnStrategyMogli.getDD_checkIsAnimPlaying, true ),
	--															self:getStageFromFunction( AITurnStrategyMogli.getDD_reduceTurnAngle, { true, 6 } ) )
		return self:getStageFromFunction( AITurnStrategyMogli.getDD_reduceTurnAngle, { true, 6 } )
	elseif stageId == 2 then
		veh:aiTurnProgress( 0.3, veh.acParameters.leftAreaActive )
		self:fillStages( turnData )
		return self:getStageFromPoints( self.stages[1], true, 0, true )
	elseif stageId == 3 then
		veh:aiTurnProgress( 0.6, veh.acParameters.leftAreaActive )
		return self:getStageWithPostCheck( self:getStageFromPoints( self.stages[2], false, 0, false ), AITurnStrategyMogli_C_R.detect4 )
	elseif stageId == 4 then
		veh:aiTurnProgress( 0.8, veh.acParameters.leftAreaActive )
		self.needsLowering = true	
		return self:getStageWithPostCheck( self:getStageFromPoints( self.stages[3], true, 3, false ), AITurnStrategyMogli_C_R.detect4 )
	elseif stageId == 5 then
		veh:aiTurnProgress( 0.99, veh.acParameters.leftAreaActive )
		return self:getStageFromFunction( AITurnStrategyMogli_C_R.detect5 )
	end
end

--============================================================================================================================
-- detect4
--============================================================================================================================
function AITurnStrategyMogli_C_R:detect4( dt, vX,vY,vZ, turnData, tX, tZ, moveForwards, allowedToDrive, distanceToStop, angle, inactive )
	local veh = self.vehicle 
	
	local checkIt = 0

	if self.needsLowering then
		self.needsLowering = nil
		AIVehicleExtension.setAIImplementsMoveDown( self.vehicle, true, veh.aiveHas.combine )
	end
	
	local turnAngle = AutoSteeringEngine.getTurnAngle( veh )
	if veh.acParameters.leftAreaActive then
		turnAngle = -turnAngle 
	end
	
	if self.stageId == 4 then
		if turnAngle >= 0.48333333 * math.pi then -- 3° tolerance
			checkIt = 2
		else
			checkIt = 1
		end
	elseif  turnAngle >= 0.45 * math.pi -- 9° tolerance
			and turnAngle >=  0.5 * math.pi - veh.acDimensions.maxSteeringAngle then
		checkIt = 1
	end
	
	if checkIt == 2 then
		local detected, angle2, border = AutoSteeringEngine.processChain( veh )
		if border > 0 then
			return 
		elseif detected then
			return 
		end
	elseif checkIt == 1 then
		if AutoSteeringEngine.processOneAngle( veh, 0 ) then
			return 
		end
	end
	
	return tX, tZ, moveForwards, allowedToDrive, distanceToStop, angle, inactive
end
	
--============================================================================================================================
-- detect5
--============================================================================================================================
function AITurnStrategyMogli_C_R:detect5( dt, vX,vY,vZ, turnData )
	local veh = self.vehicle 
		
	local detected, angle2, border = AutoSteeringEngine.processChain( veh )
	if border > 0 or math.abs( angle2 ) > veh.acDimensions.maxSteeringAngle then			
		return nil, nil, false, true, math.huge, 0, false
	end 
end

--============================================================================================================================
-- fillStages
--============================================================================================================================
function AITurnStrategyMogli_C_R:fillStages( turnData )

	self.stages = { {}, {}, {} }

	local vehicle = self.vehicle 
	local extraF  = 2
	local factor  = 1
	if vehicle.aiveChain.leftActive then
		factor = -1
	end
	
	local finalX = vehicle.aiveChain.trace.cx
	local finalZ = vehicle.aiveChain.trace.cz
	
	local dirCX,_,dirCZ = localDirectionToWorld( vehicle.aiveChain.headlandNode, 0, 0, 1 )	
	local dirFX,_,dirFZ = localDirectionToWorld( vehicle.aiveChain.headlandNode, factor, 0, 0 )			

	finalX = finalX - ( vehicle.aiveChain.maxZ + extraF ) * dirFX
	finalZ = finalZ - ( vehicle.aiveChain.maxZ + extraF ) * dirFZ

	local curX,_,curZ   = AutoSteeringEngine.getAiWorldPosition( vehicle )
	
	local deltaX,_,deltaZ = worldDirectionToLocal( vehicle.aiveChain.headlandNode, finalX-curX, 0, finalZ-curZ )
	deltaX = factor * deltaX
	
	local pi2 = 0.5 * math.pi
	local alpha, s, c
	local r = 1.1*vehicle.acDimensions.radius
	local offsetX = 0
	
	if     deltaX < -r then
		alpha   = pi2
		offsetX = -deltaX-r 
	elseif deltaX < r then
		alpha = math.acos( 0.5 * ( deltaX / r + 1 ) )
	else
		alpha = 0
	end
	
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
	
	-- stage 2 => straight forward
	local steps = 5
	
	for i=steps,-1,-1 do
		local x = c1x + r * dirFX - i * dirCX
		local z = c1z + r * dirFZ - i * dirCZ
		table.insert( self.stages[1], self:getPoint( x, z, dirCX, dirCZ ) )	
	end
	
	-- stage 3 => curved backward
	steps = 1 + math.floor( r * alpha )

	for i=0,steps do
		local a = i * alpha / steps
		local s = math.sin( a )
		local c = math.cos( a ) 
		local dx,_,dz = localDirectionToWorld( vehicle.aiveChain.headlandNode, factor * s, 0, c )		
		local x = c1x + r * ( c * dirFX - s * dirCX )
		local z = c1z + r * ( c * dirFZ - s * dirCZ )
		table.insert( self.stages[2], self:getPoint( x, z, dx, dz ) )	
		if i == steps then
			table.insert( self.stages[2], self:getPoint( x-dx, z-dz, dx, dz ) )	
		end
	end 
	
	-- stage 4 => curved forward
	steps = 1 + math.floor( r * ( pi2-alpha ) )
	
	for i=steps,0,-1 do
		local a = i * ( pi2-alpha ) / steps
		local s = math.sin( a )
		local c = math.cos( a ) 
		local dx,_,dz = localDirectionToWorld( vehicle.aiveChain.headlandNode, factor * c, 0, s )		
		local x = c2x + r * ( c * dirCX - s * dirFX )
		local z = c2z + r * ( c * dirCZ - s * dirFZ )
		table.insert( self.stages[3], self:getPoint( x, z, dx, dz ) )	
	end

	if offsetX > 0 then
		table.insert( self.stages[3], self:getPoint( finalX, finalZ, dirFX, dirFZ ) )	
	end
	
	table.insert( self.stages[3], self:getPoint( finalX + extraF * dirFX, finalZ + extraF * dirFZ, dirFX, dirFZ ) )	
	table.insert( self.stages[3], self:getPoint( finalX + ( 1 + extraF ) * dirFX, finalZ + ( 1 + extraF ) * dirFZ, dirFX, dirFZ ) )	
end

--============================================================================================================================
-- update
--============================================================================================================================
function AITurnStrategyMogli_C_R:update(dt)
	if      AIVEGlobals.showTrace > 0
			and self.vehicle ~= nil
			and self.vehicle:getIsEntered()
			and self.stages ~= nil
			and self.vehicle.acParameters.showTrace then
		local c  = table.getn( self.stages )		
		local c1 = 1
		if c > 1 then
			c1 = 1 / ( c - 1 )
		end
		
		for i,s in pairs( self.stages ) do
			local cr = c1 * (i-1)
			local cb = 1 - cr
			
			for j,p in pairs( s ) do
				local y = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, p.x, 1, p.z)					
				AIVEDrawDebugLine(  self.vehicle, p.x, y, p.z,cr,1,cb, p.x, y+4, p.z,cr,1,cb)
				AIVEDrawDebugPoint( self.vehicle, p.x, y+4, p.z	, 1, 1, 1, 1 )
				AIVEDrawDebugLine(  self.vehicle, p.x, y+2, p.z,cr,1,cb, p.x+p.dx, y+2, p.z+p.dz,cr,1,cb)				
			end
		end
	end
end
