
--
-- AITurnStrategyMogli_C_RS
--

AITurnStrategyMogli_C_RS = {}
local AITurnStrategyMogli_C_RS_mt = Class(AITurnStrategyMogli_C_RS, AITurnStrategyMogli)

function AITurnStrategyMogli_C_RS:new(customMt)
	if customMt == nil then
		customMt = AITurnStrategyMogli_C_RS_mt
	end
	local self = AITurnStrategy:new(customMt)
	return self
end

--============================================================================================================================
-- fillStages
--============================================================================================================================
function AITurnStrategyMogli_C_RS:detect( dt, vX,vY,vZ, turnData, stage, tX, tZ, maxSpeed, distanceToStop )

	local veh = self.vehicle 
	
	local moveForwards = stage.moveForwards
	
	if     stage.id == self.finalStage1 then
	-- adjust angle during reverse?
	elseif stage.id == self.finalStage2 then
		moveForwards = false 
		
		local detected, angle2, border, tX2, _, tZ2 = AutoSteeringEngine.processChain( veh )
		if border > 0 then	
			
			local angle = AIVehicleExtension.getStraighBackwardsAngle( veh, 0 )
			if veh.acParameters.leftAreaActive then
				angle2 =  angle
			else
				angle2 = -angle
			end
			
			tX2, tZ2 = AutoSteeringEngine.getWorldTargetFromSteeringAngle( veh, angle2 )
			return tX2, tZ2, false, maxSpeed, math.huge
		else
			-- end turn
			return 
		end 
	else
		print("ERROR in AITurnStrategyMogli_C_RS: unknown turn stage!!!")
	end
	
	return tX, tZ, moveForwards, maxSpeed, distanceToStop
end

--============================================================================================================================
-- fillStages
--============================================================================================================================
function AITurnStrategyMogli_C_RS:fillStages( turnData )

	local vehicle = self.vehicle 
	local points 
	local factor  = 1
	if vehicle.aiveChain.leftActive then
		factor = -1
	end
	
	local finalX = vehicle.aiveChain.trace.cx
	local finalZ = vehicle.aiveChain.trace.cz
	
	local dirCX,_,dirCZ = localDirectionToWorld( vehicle.aiveChain.headlandNode, 0, 0, 1 )	
	local dirFX,_,dirFZ = localDirectionToWorld( vehicle.aiveChain.headlandNode, factor, 0, 0 )			

	local rV = vehicle.acDimensions.radius
	for _,implement in pairs(self.vehicle.aiImplementList) do
		rV = math.max( rV, AIVehicleUtil.getMaxToolRadius(implement) )
	end	
	rT = AutoSteeringEngine.getMinToolRadius( vehicle, rV )
	
	finalX = finalX - ( vehicle.aiveChain.maxZ + extraF ) * dirFX + 0.5 * dirCX
	finalZ = finalZ - ( vehicle.aiveChain.maxZ + extraF ) * dirFZ + 0.5 * dirCZ

	local curX,_,curZ   = AutoSteeringEngine.getAiWorldPosition( vehicle )
	
	local deltaX,_,deltaZ = worldDirectionToLocal( vehicle.aiveChain.headlandNode, finalX-curX, 0, finalZ-curZ )
	deltaX = factor * deltaX
	
	
end

