
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

	print("--- loading "..g_i18n:getText("AUTO_TRACTOR_VERSION").." by mogli ---")

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
	g_i18n.globalI18N.texts["AUTO_TRACTOR_VERSION"]                  = g_i18n:getText("AUTO_TRACTOR_VERSION");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_START"]                    = g_i18n:getText("AUTO_TRACTOR_START");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_STOP"]                     = g_i18n:getText("AUTO_TRACTOR_STOP");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_WORKWIDTH"]                = g_i18n:getText("AUTO_TRACTOR_WORKWIDTH");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_ACTIVESIDELEFT"]           = g_i18n:getText("AUTO_TRACTOR_ACTIVESIDELEFT");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_ACTIVESIDERIGHT"]          = g_i18n:getText("AUTO_TRACTOR_ACTIVESIDERIGHT");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_STEERING_ON"]              = g_i18n:getText("AUTO_TRACTOR_STEERING_ON");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_STEERING_OFF"]             = g_i18n:getText("AUTO_TRACTOR_STEERING_OFF");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_CONTINUE"]                 = g_i18n:getText("AUTO_TRACTOR_CONTINUE");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_WAITMODE_ON"]              = g_i18n:getText("AUTO_TRACTOR_WAITMODE_ON");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_WAITMODE_OFF"]             = g_i18n:getText("AUTO_TRACTOR_WAITMODE_OFF");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_COLLISIONTRIGGERMODE_ON"]  = g_i18n:getText("AUTO_TRACTOR_COLLISIONTRIGGERMODE_ON");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_COLLISIONTRIGGERMODE_OFF"] = g_i18n:getText("AUTO_TRACTOR_COLLISIONTRIGGERMODE_OFF");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_TEXTHELPPANELOFF"]         = g_i18n:getText("AUTO_TRACTOR_TEXTHELPPANELOFF");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_TEXTHELPPANELON"]          = g_i18n:getText("AUTO_TRACTOR_TEXTHELPPANELON");
--g_i18n.globalI18N.texts["AUTO_TRACTOR_STARTSTOP"]                = g_i18n:getText("AUTO_TRACTOR_STARTSTOP");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_COLLISION_OTHER"]          = g_i18n:getText("AUTO_TRACTOR_COLLISION_OTHER");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_COLLISION_BACK"]           = g_i18n:getText("AUTO_TRACTOR_COLLISION_BACK");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_UTURN_ON"]                 = g_i18n:getText("AUTO_TRACTOR_UTURN_ON");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_UTURN_OFF"]                = g_i18n:getText("AUTO_TRACTOR_UTURN_OFF");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_REVERSE_ON"]               = g_i18n:getText("AUTO_TRACTOR_REVERSE_ON");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_REVERSE_OFF"]              = g_i18n:getText("AUTO_TRACTOR_REVERSE_OFF");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_INVERTED_ON"]              = g_i18n:getText("AUTO_TRACTOR_INVERTED_ON");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_INVERTED_OFF"]             = g_i18n:getText("AUTO_TRACTOR_INVERTED_OFF");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_WIDTH_OFFSET"]             = g_i18n:getText("AUTO_TRACTOR_WIDTH_OFFSET");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_TURN_OFFSET"]              = g_i18n:getText("AUTO_TRACTOR_TURN_OFFSET");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_ANGLE_OFFSET"]             = g_i18n:getText("AUTO_TRACTOR_ANGLE_OFFSET");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_SAFETY_FACTOR"]            = g_i18n:getText("AUTO_TRACTOR_SAFETY_FACTOR");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_ERROR"]                    = g_i18n:getText("AUTO_TRACTOR_ERROR");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_NEXTTURNSTAGE"]            = g_i18n:getText("AUTO_TRACTOR_NEXTTURNSTAGE");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_CP_ON"]                    = g_i18n:getText("AUTO_TRACTOR_CP_ON");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_CP_OFF"]                   = g_i18n:getText("AUTO_TRACTOR_CP_OFF");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_STEER_ON"]                 = g_i18n:getText("AUTO_TRACTOR_STEER_ON");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_STEER_OFF"]                = g_i18n:getText("AUTO_TRACTOR_STEER_OFF");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_HEADLAND_ON"]              = g_i18n:getText("AUTO_TRACTOR_HEADLAND_ON");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_HEADLAND_OFF"]             = g_i18n:getText("AUTO_TRACTOR_HEADLAND_OFF");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_FRONT_PACKER_ON"]          = g_i18n:getText("AUTO_TRACTOR_FRONT_PACKER_ON");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_FRONT_PACKER_OFF"]         = g_i18n:getText("AUTO_TRACTOR_FRONT_PACKER_OFF");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_COLLISION_ON"]             = g_i18n:getText("AUTO_TRACTOR_COLLISION_ON");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_COLLISION_OFF"]            = g_i18n:getText("AUTO_TRACTOR_COLLISION_OFF");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_HIRE_ON"]                  = g_i18n:getText("AUTO_TRACTOR_HIRE_ON");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_HIRE_OFF"]                 = g_i18n:getText("AUTO_TRACTOR_HIRE_OFF");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_HEADLAND"]                 = g_i18n:getText("AUTO_TRACTOR_HEADLAND");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_TURN_MODE_O"]              = g_i18n:getText("AUTO_TRACTOR_TURN_MODE_O");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_TURN_MODE_A"]              = g_i18n:getText("AUTO_TRACTOR_TURN_MODE_A");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_TURN_MODE_Y"]              = g_i18n:getText("AUTO_TRACTOR_TURN_MODE_Y");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_TURN_MODE_T"]              = g_i18n:getText("AUTO_TRACTOR_TURN_MODE_T");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_TURN_MODE_C"]              = g_i18n:getText("AUTO_TRACTOR_TURN_MODE_C");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_TURN_MODE_L"]              = g_i18n:getText("AUTO_TRACTOR_TURN_MODE_L");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_TURN_MODE_K"]              = g_i18n:getText("AUTO_TRACTOR_TURN_MODE_K");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_TURN_MODE_8"]              = g_i18n:getText("AUTO_TRACTOR_TURN_MODE_8");
	g_i18n.globalI18N.texts["AUTO_TRACTOR_PAUSE_ON"]                 = g_i18n:getText("AUTO_TRACTOR_PAUSE_ON");    
	g_i18n.globalI18N.texts["AUTO_TRACTOR_PAUSE_OFF"]                = g_i18n:getText("AUTO_TRACTOR_PAUSE_OFF");  
	g_i18n.globalI18N.texts["AUTO_TRACTOR_STEER_RAISE"]              = g_i18n:getText("AUTO_TRACTOR_STEER_RAISE"); 
	g_i18n.globalI18N.texts["AUTO_TRACTOR_STEER_LOWER"]              = g_i18n:getText("AUTO_TRACTOR_STEER_LOWER"); 
	g_i18n.globalI18N.texts["AUTO_TRACTOR_TRACE"]                    = g_i18n:getText("AUTO_TRACTOR_TRACE"); 
	g_i18n.globalI18N.texts["AUTO_TRACTOR_MAGIC"]                    = g_i18n:getText("AUTO_TRACTOR_MAGIC"); 
	
	g_i18n.globalI18N.texts["AUTO_TRACTOR_START_AIVE"]               = g_i18n:getText("AUTO_TRACTOR_START_AIVE"); 
	

	g_i18n.globalI18N.texts["AUTO_TRACTOR_STEERING"]                 = g_i18n:getText("AUTO_TRACTOR_STEERING");
end;

addModEventListener(AIVehicleExtensionRegister);
