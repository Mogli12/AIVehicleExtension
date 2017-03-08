AIVEScreen = {}

local AIVEScreen_mt = Class(AIVEScreen, ScreenElement)

function AIVEScreen:new(target, custom_mt)
	if custom_mt == nil then
		custom_mt = AIVEScreen_mt
	end	
	local self = ScreenElement:new(target, custom_mt)
	self.returnScreenName = "";
	self.vehicle = nil
	self.aiveElements = {}
	return self
end

function AIVEScreen:setVehicle( vehicle )
	self.vehicle = vehicle 
end

function AIVEScreen:onOpen()
	if self.vehicle == nil then
		print("Error: vehicle is empty")
	else
		for name,s in pairs( self.aiveElements ) do
			local element = s.element
			
			local struct 
			if self.vehicle.acParameters[name] == nil then
				struct = self.vehicle
			else
				struct = self.vehicle.acParameters
			end
			
			if     struct[name] == nil then
				print("Invalid UI element ID: "..tostring(name))
			elseif element:isa( ToggleButtonElement2 ) then
				local b = struct[name]
				if s.parameter then
					b = not b
				end
				element:setIsChecked( b )
			elseif element:isa( MultiTextOptionElement ) then
				local i = 1
				if     s.parameter == "percent10" then
					i = math.floor( struct[name] * 10 + 0.5 )
				elseif s.parameter == "percent5" then
					i = math.floor( struct[name] * 20 + 0.5 )
				elseif s.parameter == "distance_2_0125" then
					i = math.floor( struct[name] * 8 + 17.5 )
				elseif s.parameter == "distance" then
					i = table.getn(AIVEScreen.Distance)
					for j=1,i-1 do
						local d2 = 0.5 * ( AIVEScreen.Distance[j] + AIVEScreen.Distance[j+1] )
						if struct[name] < d2 then
							i = j
							break
						end
					end
				elseif s.parameter == "headland" then
					if not struct.headland then
						i = 1
					elseif not struct.bigHeadland then
						i = 2
					else
						i = 3
					end
					
					element:setTexts({ AIVEHud.getText("AUTO_TRACTOR_HEADLAND_ON"),
														 AIVEHud.getText("AUTO_TRACTOR_HEADLAND").." (-)",
														 AIVEHud.getText("AUTO_TRACTOR_HEADLAND").." (+)" })
				elseif s.parameter == "rightLeft" then
					if struct[name] then
						i = 2
					else
						i = 1
					end
				end			
				element:setState( i )
			end			
		end
	end
	
	AIVEScreen:superClass().onOpen(self)
end

function AIVEScreen:onClickOk()
	if self.vehicle == nil then
		print("Error: vehicle is empty")
	else
		for name,s in pairs( self.aiveElements ) do
			local element = s.element
			
			local struct 
			if self.vehicle.acParameters[name] == nil then
				struct = self.vehicle
			else
				struct = self.vehicle.acParameters
			end
			
			if     struct[name] == nil then
				print("Invalid UI element ID: "..tostring(name))
			elseif element:isa( ToggleButtonElement2 ) then
				local b = element:getIsChecked()
				if s.parameter then
					b = not b
				end
				if name == "acShowTrace" then
					self.vehicle.acShowTrace = b
				else
					struct[name] = b
				end
			elseif element:isa( MultiTextOptionElement ) then
				local i = element:getState()
				if     s.parameter == "percent10" then
					struct[name] = i / 10
				elseif s.parameter == "percent5" then
					struct[name] = i / 20
				elseif s.parameter == "distance_2_0125" then
					struct[name] = ( i - 17 ) / 8
				elseif s.parameter == "distance" then
					struct[name] = AIVEScreen.Distance[i]
				elseif s.parameter == "headland" then
					struct.headland    = ( i > 1 )
					struct.bigHeadland = ( i > 2 )
				elseif s.parameter == "rightLeft" then					
					struct.rightAreaActive = ( i ~= 1 )
					struct.leftAreaActive	= ( i == 1 )
				end			
			end
		end
	end
	
	AIVehicleExtension.sendParameters( self.vehicle )
	self:onClickBack()
end

function AIVEScreen:onClose()
	self.vehicle = nil
	AIVEScreen:superClass().onClose(self);
end

function AIVEScreen:onCreateSubElement( element, parameter )
	local checked = true
	if element.id == nil then
		checked = false
	end
	if     element:isa( ToggleButtonElement2 ) then
		if     parameter == nil then
			parameter = false
		elseif parameter == "inverted" then
			parameter = true
		else
			print("Invalid ToggleButtonElement2 parameter: <nil>")
			checked = false
		end
	elseif element:isa( MultiTextOptionElement ) then
		if     parameter == nil then
			print("Invalid MultiTextOptionElement parameter: <nil>")
			checked = false
		elseif parameter == "percent10" then
			local texts = {}
			for i=1,10 do
				table.insert( texts, string.format("%d%%",i*10) )
			end
			element:setTexts(texts)
		elseif parameter == "percent5" then
			local texts = {}
			for i=1,20 do
				table.insert( texts, string.format("%d%%",i*5) )
			end
			element:setTexts(texts)
		elseif parameter == "distance_2_0125" then
			local texts = {}
			for i=-16,16 do
				table.insert( texts, string.format("%5.3fm",i*0.125) )
			end
			element:setTexts(texts)
		elseif parameter == "distance" then
			
			if AIVEScreen.Distance == nil then
				AIVEScreen.Distance = {}
				for d=-10,-4 do
					table.insert( AIVEScreen.Distance, d )
				end
				for d=-3.5,-1.5,0.5 do
					table.insert( AIVEScreen.Distance, d )
				end
				for d=-1.25,1.25,0.25 do
					table.insert( AIVEScreen.Distance, d )
				end
				for d=1.5,3.5,0.5 do
					table.insert( AIVEScreen.Distance, d )
				end
				for d=4,10 do
					table.insert( AIVEScreen.Distance, d )
				end
			end
			
			local texts = {}
			for _,d in pairs(AIVEScreen.Distance) do
				table.insert( texts, string.format("%5.2fm",d) )
			end			
			
			element:setTexts(texts)
		elseif parameter == "headland" then
			element:setTexts({"off","small","big"})
		elseif parameter == "rightLeft" then
			element:setTexts({ AIVEHud.getText("AUTO_TRACTOR_ACTIVESIDELEFT"),  AIVEHud.getText("AUTO_TRACTOR_ACTIVESIDERIGHT") })
		else
			print("Invalid MultiTextOptionElement parameter: "..tostring(parameter))
			checked = false
		end
	end
	if checked then
		self.aiveElements[element.id] = { element=element, parameter=parameter }
	else	
		print("Error inserting UI element with ID: "..tostring(element.id))
	end
end
