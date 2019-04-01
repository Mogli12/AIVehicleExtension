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
  self.object = NetworkUtil.readNodeObject( streamId )
	self.parameters = AIVehicleExtension.readStreamHelper(streamId);
  self:run(connection)
end
function AIVEParametersEvent:writeStream(streamId, connection)
  NetworkUtil.writeNodeObject( streamId, self.object )
	AIVehicleExtension.writeStreamHelper(streamId, self.parameters);
end
function AIVEParametersEvent:run(connection)
  AIVehicleExtension.setParameters(self.object,self.parameters);
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
  self.object = NetworkUtil.readNodeObject( streamId )
  self:run(connection)
end
function AIVENextTSEvent:writeStream(streamId, connection)
  NetworkUtil.writeNodeObject( streamId, self.object )
end
function AIVENextTSEvent:run(connection)
  AIVehicleExtension.setNextTurnStage(self.object,true);
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
  self.object = NetworkUtil.readNodeObject( streamId )
	self.enabled = streamReadBool(streamId)
  self:run(connection)
end
function AIVEPauseEvent:writeStream(streamId, connection)
  NetworkUtil.writeNodeObject( streamId, self.object )
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
			print("AIVehicleExtension:setInt32Value: self == nil ( "..tostring(name).." / "..tostring(value).." )");
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
	elseif name == "speed2Level" then
		self.speed2Level = value
	elseif name == "aiveCanStartArtAxis" then
		self.aiveCanStartArtAxis = ( value > 0 )
	elseif name == "moveDown" then
		if self.isServer then
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
			AIVehicleExtension.setAIImplementsMoveDown( self, moveDown, immediate )
		end
	elseif name == "axisSide" then
		self.acAxisSide = 1e-6 * ( value - 1e6 )
	elseif name == "lowered" then
		self.acIsLowered = value
	elseif name == "autoSteer" then 
		if value > 1 then
			self.aiveAutoSteer = false
			self.aiveIsStarted = true 
		else
			if self.isServer then
				AutoSteeringEngine.invalidateField( self, self.acParameters.useAIFieldFct )
				AutoSteeringEngine.initFruitBuffer( self )
				self.acLastSteeringAngle = nil
			end
			if value > 0 then 
				AIVehicleExtension.initMogliHud(self)
				if not self.aiveAutoSteer  then 
					self.aiveRequestActionEventUpdate = true 
				end 
				self.stopMotorOnLeave  = false 
				self.deactivateOnLeave = false
				self.acTurnStage       = 198
				self.aiveAutoSteer     = true
			else 
				if self.aiveAutoSteer  then 
					self.aiveRequestActionEventUpdate = true 
				end 
				self.stopMotorOnLeave  = true
				self.deactivateOnLeave = true
				self.acTurnStage       = 0
				self.aiveAutoSteer     = false
			end
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
  self.object = NetworkUtil.readNodeObject( streamId )
	self.name   = streamReadString(streamId)
	self.value 	= streamReadInt32(streamId)
  self:run(connection)
end
function AIVEInt32Event:writeStream(streamId, connection)
  NetworkUtil.writeNodeObject( streamId, self.object )
  streamWriteString(streamId,self.name)
  streamWriteInt32(streamId, self.value)
end
function AIVEInt32Event:run(connection)
  AIVehicleExtension.setInt32Value( self.object, self.name, self.value, true )
  if not connection:getIsServer() then
    g_server:broadcastEvent(AIVEInt32Event:new(self.object,self.name,self.value), nil, connection, self.object)
  end
end

------------------------------------------------------------------------
-- AIVEWarningEvent
------------------------------------------------------------------------
function AIVehicleExtension:showWarning( text, wait, noEventSend )
	
	if self == nil then
		if AIVESetInt32ValueLog < 10 then
			AIVESetInt32ValueLog = AIVESetInt32ValueLog + 1;
			print("------------------------------------------------------------------------");
			print("AIVehicleExtension:showWarning: self == nil ( "..tostring(text).." / "..tostring(wait).." )");
			AIVEHud.printCallstack();
			print("------------------------------------------------------------------------");
		end
	
		g_currentMission:showBlinkingWarning( text, wait )
		return 
	end
	
	if noEventSend == nil or not noEventSend then
		if g_server ~= nil then
			g_server:broadcastEvent(AIVEWarningEvent:new(self,text,wait), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(AIVEWarningEvent:new(self,text,wait))
		end
	end
	
	if self.isClient and self.isEntered then
		g_currentMission:showBlinkingWarning( text, wait )
	end
end


AIVEWarningEvent = {}
AIVEWarningEvent_mt = Class(AIVEWarningEvent, Event)
InitEventClass(AIVEWarningEvent, "AIVEWarningEvent")
function AIVEWarningEvent:emptyNew()
  local self = Event:new(AIVEWarningEvent_mt)
  return self
end
function AIVEWarningEvent:new(object,text,wait)
  local self = AIVEWarningEvent:emptyNew()
  self.object = object
	self.text = text
	self.wait = wait
  return self
end
function AIVEWarningEvent:readStream(streamId, connection)
  self.object = NetworkUtil.readNodeObject( streamId )
	self.text   = streamReadString(streamId)
	self.wait 	= streamReadInt32(streamId)
  self:run(connection)
end
function AIVEWarningEvent:writeStream(streamId, connection)
  NetworkUtil.writeNodeObject( streamId, self.object )
  streamWriteString(streamId,self.text)
  streamWriteInt32(streamId, self.wait)
end
function AIVEWarningEvent:run(connection)
  AIVehicleExtension.showWarning( self.object, self.text, self.wait, true )
  if not connection:getIsServer() then
    g_server:broadcastEvent(AIVEWarningEvent:new(self.object,self.text,self.wait), nil, connection, self.object)
  end
end



