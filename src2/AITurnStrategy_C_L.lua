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