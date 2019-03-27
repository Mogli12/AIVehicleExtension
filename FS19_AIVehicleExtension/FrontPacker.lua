FrontPacker = {}
FrontPacker_mt = { __index = function( table, key ) return Cultivator[key] end }
setmetatable( FrontPacker, FrontPacker_mt )
--FrontPacker = Cultivator

function FrontPacker:updateTick(dt)
	local backup        = CultivatorAreaEvent
	CultivatorAreaEvent = FrontPackerAreaEvent
	local state,result  = pcall( Cultivator.updateTick, self, dt )
	CultivatorAreaEvent = backup
	if state then
		return result
	else
		print("Error in FrontPacker.updateTick : "..tostring(result))
	end
end

FrontPackerAreaEvent = {}
FrontPackerAreaEvent_mt = Class(FrontPackerAreaEvent, Event)

InitEventClass(FrontPackerAreaEvent, "FrontPackerAreaEvent")

FrontPackerAreaEvent.emptyNew = function (self)
	local self = Event:new(FrontPackerAreaEvent_mt)

	return self
end
FrontPackerAreaEvent.new = function (self, workAreas, limitToField, limitGrassDestructionToField, angle)
	local self = FrontPackerAreaEvent:emptyNew()

	assert(0 < table.getn(workAreas))

	self.workAreas = workAreas
	self.limitToField = limitToField
	self.limitGrassDestructionToField = Utils.getNoNil(limitGrassDestructionToField, limitToField)
	self.angle = angle

	return self
end
FrontPackerAreaEvent.readStream = function (self, streamId, connection)
	local limitToField = streamReadBool(streamId)
	local limitGrassDestructionToField = streamReadBool(streamId)
	local angle = nil

	if streamReadBool(streamId) then
		angle = streamReadUIntN(streamId, g_currentMission.terrainDetailAngleNumChannels)
	end

	local numAreas = streamReadUIntN(streamId, 4)
	local refX = streamReadFloat32(streamId)
	local refY = streamReadFloat32(streamId)
	local values = Utils.readCompressed2DVectors(streamId, refX, refY, numAreas*3 - 1, 0.01, true)

	for i = 1, numAreas, 1 do
		local vi = i - 1
		local x = values[vi*3 + 1].x
		local z = values[vi*3 + 1].y
		local x1 = values[vi*3 + 2].x
		local z1 = values[vi*3 + 2].y
		local x2 = values[vi*3 + 3].x
		local z2 = values[vi*3 + 3].y

		if getfenv(0)["modSoilMod2"] == nil then
			FrontPackerAreaEvent.updateCultivatorArea(x, z, x1, z1, x2, z2, not limitToField, not limitGrassDestructionToField, angle)
		else
			FrontPackerAreaEvent.updateCultivatorAreaSoilMod(x, z, x1, z1, x2, z2, not limitToField, not limitGrassDestructionToField, angle)
		end
	end

	return 
end
FrontPackerAreaEvent.writeStream = function (self, streamId, connection)
	local numAreas = table.getn(self.workAreas)

	streamWriteBool(streamId, self.limitToField)
	streamWriteBool(streamId, self.limitGrassDestructionToField)

	if streamWriteBool(streamId, self.angle ~= nil) then
		streamWriteUIntN(streamId, self.angle, g_currentMission.terrainDetailAngleNumChannels)
	end

	streamWriteUIntN(streamId, numAreas, 4)

	local refX, refY = nil
	local values = {}

	for i = 1, numAreas, 1 do
		local d = self.workAreas[i]

		if i == 1 then
			refX = d[1]
			refY = d[2]

			streamWriteFloat32(streamId, d[1])
			streamWriteFloat32(streamId, d[2])
		else
			table.insert(values, {
				x = d[1],
				y = d[2]
			})
		end

		table.insert(values, {
			x = d[3],
			y = d[4]
		})
		table.insert(values, {
			x = d[5],
			y = d[6]
		})
	end

	assert(table.getn(values) == numAreas*3 - 1)
	Utils.writeCompressed2DVectors(streamId, refX, refY, values, 0.01)

	return 
end
FrontPackerAreaEvent.run = function (self, connection)
	print("Error: Do not run FrontPackerAreaEvent locally")

	return 
end

function FrontPackerAreaEvent.updateDestroyCommonArea(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, limitToField)	
	g_currentMission.tyreTrackSystem:eraseParallelogram(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ)
end

function FrontPackerAreaEvent.updateCultivatorArea(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, forced, commonForced, angle)

	forced = Utils.getNoNil(forced, true)
	commonForced = Utils.getNoNil(commonForced, true)
	local detailId = g_currentMission.terrainDetailId

	FrontPackerAreaEvent.updateDestroyCommonArea(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, not commonForced)

	local x, z, widthX, widthZ, heightX, heightZ = Utils.getXZWidthAndHeight(detailId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ)
	
	--start insert
	local plantValue = 1
	for fruitId,ids in pairs(g_currentMission.fruits) do
		if fruitId ~= FruitUtil.FRUITTYPE_GRASS and ids.id > 0 then
			setDensityCompareParams(ids.id, "greater", plantValue)
			setDensityMaskedParallelogram(ids.id, x, z, widthX, widthZ, heightX, heightZ, 0, g_currentMission.numFruitDensityMapChannels, detailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, plantValue)	
			setDensityCompareParams(ids.id, "greater", -1)
		end
	end
	--end insert

	local value = 2^g_currentMission.cultivatorChannel

	setDensityCompareParams(detailId, "greater", 0, 0, value, 0)

	local _, areaBefore, _ = getDensityParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels)

	setDensityCompareParams(detailId, "greater", -1)

	local area = 0
	local realArea = 0

	--start insert
	setDensityMaskParams(detailId, "between", 1, 2 ^ g_currentMission.cultivatorChannel + 2 ^ g_currentMission.ploughChannel )	
	--end insert

	if forced then
		area = area + setDensityParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, value)

		if angle ~= nil then
			setDensityParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailAngleFirstChannel, g_currentMission.terrainDetailAngleNumChannels, angle)
		end
	else
		area = area + setDensityMaskedParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, detailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, value)

		if angle ~= nil then
			setDensityMaskedParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailAngleFirstChannel, g_currentMission.terrainDetailAngleNumChannels, detailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, angle)
		end
	end
	
	--start insert
	setDensityMaskParams(detailId, "greater", 0)
	--end insert

	setDensityCompareParams(detailId, "greater", 0, 0, value, 0)

	local _, areaAfter, _ = getDensityParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels)

	setDensityCompareParams(detailId, "greater", -1)

	realArea = areaAfter - areaBefore

	return realArea, area
	
end

function FrontPackerAreaEvent.updateCultivatorAreaSoilMod(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, forced, commonForced, angle)

   local dataStore = {}
   dataStore.forced        = Utils.getNoNil(forced, true);
   dataStore.commonForced  = Utils.getNoNil(commonForced, true);
   dataStore.angle         = angle
   dataStore.area          = 0;
   dataStore.includeMask   = 2^g_currentMission.cultivatorChannel;
    
   local sx,sz,wx,wz,hx,hz = Utils.getXZWidthAndHeight(nil, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);

   -- Setup phase - If any plugin needs to modify anything in dataStore
	 local backup 
	 if Utils.fmcUpdateDestroyCommonArea ~= nil and Utils.fmcUpdateDestroyDynamicFoliageLayers ~= nil then	 
		 backup = Utils.fmcUpdateDestroyCommonArea
		 Utils.fmcUpdateDestroyCommonArea = Utils.fmcUpdateDestroyDynamicFoliageLayers
	 end
	 
   for _,callFunc in pairs(Utils.fmcPluginsUpdateCultivatorAreaSetup) do
      callFunc(sx,sz,wx,wz,hx,hz, dataStore, nil)
   end

  -- FS15 addition
  setDensityCompareParams(g_currentMission.terrainDetailId, "greater", 0, 0, dataStore.includeMask, 0);
  _,dataStore.areaBefore,_ = getDensityParallelogram(
      g_currentMission.terrainDetailId, 
      sx,sz,wx,wz,hx,hz, 
      g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels
  );
  setDensityCompareParams(g_currentMission.terrainDetailId, "greater", -1);
	
  -- Before phase - Give plugins the possibility to affect foliage-layer(s) and dataStore, before the default "cultivating" occurs.
  for _,callFunc in pairs(Utils.fmcPluginsUpdateCultivatorAreaPreFuncs) do
    callFunc(sx,sz,wx,wz,hx,hz, dataStore, nil)
  end

	--start insert
	local detailId = g_currentMission.terrainDetailId
	setDensityMaskParams(detailId, "between", 1, 2 ^ g_currentMission.cultivatorChannel + 2 ^ g_currentMission.ploughChannel )	
	--end insert

  -- Default "cultivating"
  if dataStore.forced then
    dataStore.area = dataStore.area + setDensityParallelogram(
            g_currentMission.terrainDetailId, 
            sx,sz,wx,wz,hx,hz, 
            g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, 
            2^g_currentMission.cultivatorChannel
        );
    if dataStore.angle ~= nil then
      setDensityParallelogram(
                g_currentMission.terrainDetailId, 
                sx,sz,wx,wz,hx,hz, 
                g_currentMission.terrainDetailAngleFirstChannel, g_currentMission.terrainDetailAngleNumChannels, 
                dataStore.angle
            );
    end
  else
    dataStore.area = dataStore.area + setDensityMaskedParallelogram(
            g_currentMission.terrainDetailId, 
            sx,sz,wx,wz,hx,hz, 
            g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, 
            g_currentMission.terrainDetailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, 
            2^g_currentMission.cultivatorChannel
        );
    if dataStore.angle ~= nil then
      setDensityMaskedParallelogram(
                g_currentMission.terrainDetailId, 
                sx,sz,wx,wz,hx,hz, 
                g_currentMission.terrainDetailAngleFirstChannel, g_currentMission.terrainDetailAngleNumChannels, 
                g_currentMission.terrainDetailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, 
                dataStore.angle
            );
    end
  end

	--start insert
	setDensityMaskParams(detailId, "greater", 0)
	--end insert
	
  -- FS15 addition
  setDensityCompareParams(g_currentMission.terrainDetailId, "greater", 0, 0, dataStore.includeMask, 0);
  _,dataStore.areaAfter,_ = getDensityParallelogram(
        g_currentMission.terrainDetailId, 
        sx,sz,wx,wz,hx,hz, 
        g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels
  );
  setDensityCompareParams(g_currentMission.terrainDetailId, "greater", -1);
    
  -- After phase - Give plugins the possibility to affect foliage-layer(s) and dataStore, after the default "cultivating" have been done.
  for _,callFunc in pairs(Utils.fmcPluginsUpdateCultivatorAreaPostFuncs) do
    callFunc(sx,sz,wx,wz,hx,hz, dataStore, nil)
  end
	
	if backup ~= nil then
		Utils.fmcUpdateDestroyCommonArea = backup
	end
    
  return (dataStore.areaAfter - dataStore.areaBefore), dataStore.area;
end

FrontPackerAreaEvent.runLocally = function (workAreas, limitToField, limitGrassDestructionToField, angle)
	local numAreas = table.getn(workAreas)
	local refX, refY = nil
	local values = {}

	for i = 1, numAreas, 1 do
		local d = workAreas[i]

		if i == 1 then
			refX = d[1]
			refY = d[2]
		else
			table.insert(values, {
				x = d[1],
				y = d[2]
			})
		end

		table.insert(values, {
			x = d[3],
			y = d[4]
		})
		table.insert(values, {
			x = d[5],
			y = d[6]
		})
	end

	assert(table.getn(values) == numAreas*3 - 1)

	local values = Utils.simWriteCompressed2DVectors(refX, refY, values, 0.01, true)
	local areaSum = 0

	for i = 1, numAreas, 1 do
		local vi = i - 1
		local x = values[vi*3 + 1].x
		local z = values[vi*3 + 1].y
		local x1 = values[vi*3 + 2].x
		local z1 = values[vi*3 + 2].y
		local x2 = values[vi*3 + 3].x
		local z2 = values[vi*3 + 3].y
		if getfenv(0)["modSoilMod2"] == nil then
			areaSum = areaSum + FrontPackerAreaEvent.updateCultivatorArea(x, z, x1, z1, x2, z2, not limitToField, not limitGrassDestructionToField, angle)
		else
			areaSum = areaSum + FrontPackerAreaEvent.updateCultivatorAreaSoilMod(x, z, x1, z1, x2, z2, not limitToField, not limitGrassDestructionToField, angle)
		end
	end

	return areaSum
end

