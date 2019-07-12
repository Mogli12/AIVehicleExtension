
AIVehicleExtensionRegister = {};
AIVehicleExtensionRegister.isLoaded = true;
AIVehicleExtensionRegister.g_currentModDirectory = g_currentModDirectory;
AIVehicleExtensionRegister.specName = "AIVehicleExtension"

source(Utils.getFilename("AIVehicleExtension.lua", g_currentModDirectory))
source(Utils.getFilename("AIVEScreen.lua", g_currentModDirectory));

function AIVehicleExtensionRegister:beforeFinalizeVehicleTypes()

	if AIVehicleExtension == nil then 
		print("Failed to add specialization AIVehicleExtension")
	else 
		for k, typeDef in pairs(g_vehicleTypeManager.vehicleTypes) do
			if typeDef ~= nil and k ~= "locomotive" then 
				local isAIVehicle, hasNotAIVE  = false, true
				for name, spec in pairs(typeDef.specializationsByName) do
					if name == "aiVehicle" then 
						isAIVehicle = true 
					end 
					if name == AIVehicleExtensionRegister.specName then 
						hasNotAIVE = false 
					end 
				end 
				if isAIVehicle and hasNotAIVE then 
					print("  adding AIVehicleExtension to vehicleType '"..tostring(k).."'")
					typeDef.specializationsByName[AIVehicleExtensionRegister.specName] = AIVehicleExtension
					table.insert(typeDef.specializationNames, AIVehicleExtensionRegister.specName)
					table.insert(typeDef.specializations, AIVehicleExtension)	
				end 
			end 
		end 	
	end 	
end 
VehicleTypeManager.finalizeVehicleTypes = Utils.prependedFunction(VehicleTypeManager.finalizeVehicleTypes, AIVehicleExtensionRegister.beforeFinalizeVehicleTypes)

function AIVehicleExtensionRegister:loadMap(name)		

	AIVehicleExtensionRegister.mogliTexts = {}
	for n,t in pairs( g_i18n.texts ) do
		AIVehicleExtensionRegister.mogliTexts[n] = t
	end

	local l10nFilenamePrefixFull = Utils.getFilename("modDesc_l10n", AIVehicleExtensionRegister.g_currentModDirectory);
	local l10nXmlFile;
	local l10nFilename
	local langs = {g_languageShort, "en", "de"};
	for _, lang in ipairs(langs) do
		l10nFilename = l10nFilenamePrefixFull.."_"..lang..".xml";
		if fileExists(l10nFilename) then
			l10nXmlFile = loadXMLFile("TempConfig", l10nFilename);
			break;
		end
	end
	if l10nXmlFile ~= nil then
		local textI = 0;
		while true do
			local key = string.format("l10n.longTexts.longText(%d)", textI);
			if not hasXMLProperty(l10nXmlFile, key) then
				break;
			end;
			local name = getXMLString(l10nXmlFile, key.."#name");
			local text = getXMLString(l10nXmlFile, key);
			if name ~= nil and text ~= nil then
				AIVehicleExtensionRegister.mogliTexts[name] = text:gsub("\r\n", "\n")
			end;
			textI = textI+1;
		end;
		delete(l10nXmlFile);
	end
end;

function AIVehicleExtensionRegister:saveSavegame( savegame )
end

function AIVehicleExtensionRegister:loadSavegame()
end

function AIVehicleExtensionRegister:deleteMap()
	if type( g_AIVEScreen ) == table and type( g_AIVEScreen.delete ) == "function" then 
		g_AIVEScreen:delete()
		g_AIVEScreen = nil 
	end 
end;

function AIVehicleExtensionRegister:mouseEvent(posX, posY, isDown, isUp, button)
	if 			type( g_currentMission.controlledVehicle ) == "table" then 
		AIVEHud.mouseEvent(g_currentMission.controlledVehicle, posX, posY, isDown, isUp, button)
	end 
end;

function AIVehicleExtensionRegister:keyEvent(unicode, sym, modifier, isDown)
end;

function AIVehicleExtensionRegister:update(dt)
	if      AIVehicleExtension.aiUpdateLowFrequencyDelay           ~= nil 
			and AIVehicleExtension.aiUpdateLowFrequencyDelay           ~= AIVehicleExtension.extendedFrequencyDelay 
			and AIVehicleExtension.numberOfExtendedWorkers             <= 0
			and AIVehicle.aiUpdateLowFrequencyDelay                    == AIVehicleExtension.extendedFrequencyDelay then 
		AIVehicle.aiUpdateLowFrequencyDelay = AIVehicleExtension.aiUpdateLowFrequencyDelay
	end 
end;

function AIVehicleExtensionRegister:draw()
end;

addModEventListener(AIVehicleExtensionRegister);
