
AIVehicleExtensionRegister = {};
AIVehicleExtensionRegister.isLoaded = true;
AIVehicleExtensionRegister.g_currentModDirectory = g_currentModDirectory;

source(Utils.getFilename("AIVEScreen.lua", g_currentModDirectory));

if SpecializationUtil.specializations["AIVehicleExtension"] == nil then
	SpecializationUtil.registerSpecialization("AIVehicleExtension", "AIVehicleExtension", g_currentModDirectory.."AIVehicleExtension.lua")
	AIVehicleExtensionRegister.isLoaded = false;
end;

function AIVehicleExtensionRegister:loadMap(name)	
  if not AIVehicleExtensionRegister.isLoaded then	
		AIVehicleExtensionRegister:add();
    AIVehicleExtensionRegister.isLoaded = true;
		if not g_currentMission.missionInfo.isTutorial then
			g_careerScreen.saveSavegame = Utils.appendedFunction(g_careerScreen.saveSavegame, AIVehicleExtensionRegister.saveSavegame);
		end
  end;	
	
	-- GUI Stuff
	g_AIVEScreen = AIVEScreen:new();
	g_gui:loadGui(AIVehicleExtensionRegister.g_currentModDirectory .. "gui/AIVEScreen.xml", "AIVEScreen", g_AIVEScreen);	
end;

function AIVehicleExtensionRegister:saveSavegame( savegame )
end

function AIVehicleExtensionRegister:loadSavegame()
end

function AIVehicleExtensionRegister:deleteMap()
  --AIVehicleExtensionRegister.isLoaded = false;
	g_AIVEScreen:delete()
end;

function AIVehicleExtensionRegister:mouseEvent(posX, posY, isDown, isUp, button)
end;

function AIVehicleExtensionRegister:keyEvent(unicode, sym, modifier, isDown)
end;

function AIVehicleExtensionRegister:update(dt)
	if not g_currentMission.missionInfo.isTutorial and g_currentMission.missionInfo.isValid then
		if not ( self.isSavegameLoaded ) then
			AIVehicleExtensionRegister.loadSavegame( self )
			self.isSavegameLoaded = true
		end
	end
end;

function AIVehicleExtensionRegister:draw()
end;

function AIVehicleExtensionRegister:add()

	print("--- loading "..g_i18n:getText("AIVE_VERSION").." by mogli ---")

	local searchTable = { "Autopilot", "AutoTractor", "AutoCombine" };	
	
	for k, v in pairs(VehicleTypeUtil.vehicleTypes) do
		local modName         = string.match(k, "([^.]+)");
		local doNotAdd        = true;
		local correctLocation = false;
		local specMask        = 0
		
		for _, search in pairs(searchTable) do
			if SpecializationUtil.specializations[modName .. "." .. search] ~= nil then
				doNotAdd = false;
				break;
			end;
		end;
		
		for i = 1, table.maxn(v.specializations) do
			local vs = v.specializations[i];
			if      vs ~= nil 
					and vs == SpecializationUtil.getSpecialization("articulatedAxis") then
				doNotAdd = false;
				break;
			end;
		end;
		
		for i = 1, table.maxn(v.specializations) do
			local vs = v.specializations[i];
			if      vs ~= nil 
					and vs == SpecializationUtil.getSpecialization("aiVehicle") then
				correctLocation = true;
				specMask = specMask + 1
				break;
			elseif  vs ~= nil 
					and vs == SpecializationUtil.getSpecialization("hirable") then
				specMask = specMask + 2
			elseif  vs ~= nil 
					and vs == SpecializationUtil.getSpecialization("steerable") then
				specMask = specMask + 4
			elseif  vs ~= nil 
					and vs == SpecializationUtil.getSpecialization("drivable") then
				specMask = specMask + 8
			elseif  vs ~= nil 
					and vs == SpecializationUtil.getSpecialization("mower") then
				specMask = specMask + 16
			end;
		end;
		
		if doNotAdd and correctLocation then
			table.insert(v.specializations, SpecializationUtil.getSpecialization("AIVehicleExtension"));
		  print("  AIVehicleExtension was inserted on " .. k);
		elseif correctLocation and not doNotAdd then
			print("  Failed to inserting AIVehicleExtension on " .. k);
		end;
	end;
	
	-- make l10n global 
	for n,t in pairs( g_i18n.texts ) do
		if string.sub( n, 1, 4 ) == "AIVE" then
			g_i18n.globalI18N.texts[n] = t
		end
	end
end;

addModEventListener(AIVehicleExtensionRegister);
