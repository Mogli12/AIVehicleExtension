------------------------------------------------------------------------
-- AIVEParametersEvent
------------------------------------------------------------------------
AIVEParametersEvent = {}
AIVEParametersEvent_mt = Class(AIVEParametersEvent, Event)
InitEventClass(AIVEParametersEvent, "AIVEParametersEvent")
function AIVEParametersEvent:emptyNew()
  local self = Event:new(AIVEParametersEvent_mt)
  return self
end
function AIVEParametersEvent:new(object, parameters)
  local self = AIVEParametersEvent:emptyNew()
  self.object     = object;
  self.parameters = parameters;
  return self
end
function AIVEParametersEvent:readStream(streamId, connection)
  local id = streamReadInt32(streamId)
  self.object = networkGetObject(id)
	self.parameters = AIVEehicleExtension.readStreamHelper(streamId);
  self:run(connection)
end
function AIVEParametersEvent:writeStream(streamId, connection)
  streamWriteInt32(streamId, networkGetObjectId(self.object))
	AIVEehicleExtension.writeStreamHelper(streamId, self.parameters);
end
function AIVEParametersEvent:run(connection)
  AIVEehicleExtension.setParameters(self.object,self.parameters);
  if not connection:getIsServer() then
    g_server:broadcastEvent(AIVEParametersEvent:new(self.object, self.parameters), nil, connection, self.object)
  end
end

------------------------------------------------------------------------
-- AIVENextTSEvent
------------------------------------------------------------------------
AIVENextTSEvent = {}
AIVENextTSEvent_mt = Class(AIVENextTSEvent, Event)
InitEventClass(AIVENextTSEvent, "AIVENextTSEvent")
function AIVENextTSEvent:emptyNew()
  local self = Event:new(AIVENextTSEvent_mt)
  return self
end
function AIVENextTSEvent:new(object)
  local self = AIVENextTSEvent:emptyNew()
  self.object     = object;
  return self
end
function AIVENextTSEvent:readStream(streamId, connection)
  local id = streamReadInt32(streamId)
  self.object = networkGetObject(id)
  self:run(connection)
end
function AIVENextTSEvent:writeStream(streamId, connection)
  streamWriteInt32(streamId, networkGetObjectId(self.object))
end
function AIVENextTSEvent:run(connection)
  AIVEehicleExtension.setNextTurnStage(self.object,true);
  if not connection:getIsServer() then
    g_server:broadcastEvent(AIVENextTSEvent:new(self.object), nil, connection, self.object)
  end
end

------------------------------------------------------------------------
-- AIVEPauseEvent
------------------------------------------------------------------------
AIVEPauseEvent = {}
AIVEPauseEvent_mt = Class(AIVEPauseEvent, Event)
InitEventClass(AIVEPauseEvent, "AIVEPauseEvent")
function AIVEPauseEvent:emptyNew()
  local self = Event:new(AIVEPauseEvent_mt)
  return self
end
function AIVEPauseEvent:new(object,enabled)
  local self = AIVEPauseEvent:emptyNew()
  self.object     = object;
	self.enabled    = enabled
  return self
end
function AIVEPauseEvent:readStream(streamId, connection)
  local id = streamReadInt32(streamId)
  self.object  = networkGetObject(id)
	self.enabled = streamReadBool(streamId)
  self:run(connection)
end
function AIVEPauseEvent:writeStream(streamId, connection)
  streamWriteInt32(streamId, networkGetObjectId(self.object))
	streamWriteBool(streamId, self.enabled)
end
function AIVEPauseEvent:run(connection)
  self.object.acPause = self.enabled
  if not connection:getIsServer() then
    g_server:broadcastEvent(AIVEPauseEvent:new(self.object,self.enabled), nil, connection, self.object)
  end
end


------------------------------------------------------------------------
-- AIVEInt32Event
------------------------------------------------------------------------
local AIVESetInt32ValueLog = 0
function AIVehicleExtension:setInt32Value( name, value, noEventSend )
	
	if self == nil then
		if AIVESetInt32ValueLog < 10 then
			AIVESetInt32ValueLog = AIVESetInt32ValueLog + 1;
			print("------------------------------------------------------------------------");
			print("AIVEehicleExtension:setInt32Value: self == nil ( "..tostring(name).." / "..tostring(value).." )");
			AIVEHud.printCallstack();
			print("------------------------------------------------------------------------");
		end
		return
	end
			
	if noEventSend == nil or not noEventSend then
		if g_server ~= nil then
			g_server:broadcastEvent(AIVEInt32Event:new(self,name,value), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(AIVEInt32Event:new(self,name,value))
		end
	end
	
	if     name == "status" then
		if self.atMogliInitDone then
			AIVEHud.setStatus( self, value )		
		end
	elseif name == "turnStage" then
		self.acTurnStage     = value
		self.acTurnStageSent = value
	elseif name == "speed2Level" then
		self.speed2Level = value
	elseif name == "moveDown" then
		local moveDown, immediate
		if value >= 2 then
			moveDown = true
		else
			moveDown = false
		end
		if value == 1 or value == 3 then
			immediate = true
		else
			immediate = false
		end
		
	end
end


AIVEInt32Event = {}
AIVEInt32Event_mt = Class(AIVEInt32Event, Event)
InitEventClass(AIVEInt32Event, "AIVEInt32Event")
function AIVEInt32Event:emptyNew()
  local self = Event:new(AIVEInt32Event_mt)
  return self
end
function AIVEInt32Event:new(object,name,value)
  local self = AIVEInt32Event:emptyNew()
  self.object = object
	self.name   = name
	self.value  = value
  return self
end
function AIVEInt32Event:readStream(streamId, connection)
  local id = streamReadInt32(streamId)
  self.object = networkGetObject(id)
	self.name   = streamReadString(streamId)
	self.value 	= streamReadInt32(streamId)
  self:run(connection)
end
function AIVEInt32Event:writeStream(streamId, connection)
  streamWriteInt32(streamId, networkGetObjectId(self.object))
  streamWriteString(streamId,self.name)
  streamWriteInt32(streamId, self.value)
end
function AIVEInt32Event:run(connection)
  AIVEehicleExtension.setInt32Value( self.object, self.name, self.value, true )
  if not connection:getIsServer() then
    g_server:broadcastEvent(AIVEInt32Event:new(self.object,self.name,self.value), nil, connection, self.object)
  end
end

