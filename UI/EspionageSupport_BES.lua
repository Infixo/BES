--------------------------------------------------------------
-- Better Espionage Screen
-- Author: Infixo, astog
-- 2022-12-31: Created
--------------------------------------------------------------

--[[
Mission history fields:
Operation
PlotIndex
LootInfo
LevelAfter
CityName
CompletionTurn
Name
InitialResult -> EspionageResultTypes
EscapeResult -> EspionageResultTypes

EspionageResultTypes
NO_RESULT				number	-1
KILLED					number	0
CAPTURED				number	1
FAIL_MUST_ESCAPE		number	2
FAIL_UNDETECTED			number	3
SUCCESS_MUST_ESCAPE   	number	4
SUCCESS_UNDETECTED    	number	5
NUM_ESPIONAGE_RESULTS 	number	6


--]]

-- debug routine - prints a table (no recursion)
function dshowtable(tTable:table)
	for k,v in pairs(tTable) do
		print(k, type(v), tostring(v));
	end
end

-- debug routine - prints a table, and tables inside recursively (up to 5 levels)
function dshowrectable(tTable:table, iLevel:number)
	local level:number = 0;
	if iLevel ~= nil then level = iLevel; end
	for k,v in pairs(tTable) do
		print(string.rep("---:",level), k, type(v), tostring(v));
		if type(v) == "table" and level < 5 then dshowrectable(v, level+1); end
	end
end

-- ===========================================================================
-- Author: astog
function hasDistrict(city:table, districtType:string)
    local hasDistrict:boolean = false;
    local cityDistricts:table = city:GetDistricts();
    for i, district in cityDistricts:Members() do
        if district:IsComplete() and not district:IsPillaged() then --ARISTOS: to only show available and valid targets in each city, both for espionage overview and selector
            --gets the district type of the currently selected district
            local districtInfo:table = GameInfo.Districts[district:GetType()];
            local currentDistrictType = districtInfo.DistrictType

            --assigns currentDistrictType to be the general type of district (i.e. DISTRICT_HANSA becomes DISTRICT_INDUSTRIAL_ZONE)
            local replaces = GameInfo.DistrictReplaces[districtInfo.Hash];
            if replaces then
                currentDistrictType = GameInfo.Districts[replaces.ReplacesDistrictType].DistrictType
            end

            if currentDistrictType == districtType then
                return true
            end
        end
    end

    return false
end


-- ===========================================================================
-- Read spy promotions, add icons and prepare a tooltip with details
-- Returns level:number, icons:string, tooltip:string

function GetSpyRankIconByLevel(level:number)
	if level  > 3 then return "[ICON_Army]";    end
	if level == 3 then return "[ICON_Corps]";   end
	if level == 2 then return "[ICON_Capital]"; end
	return "";
end

local PromotionIconsDef:table = {
	-- defensive
	PROMOTION_SPY_POLYGRAPH        = "[ICON_PressureDownLarge]",
	PROMOTION_SPY_QUARTERMASTER    = "[ICON_PressureUpLarge]",
	PROMOTION_SPY_SEDUCTION        = "[ICON_PressureHigh]",
	PROMOTION_SPY_SURVEILLANCE     = "[ICON_PROMOTION_SPY_SURVEILLANCE]", -- ICON_PressureMedium
};

local PromotionIconsOff:table = {
	-- offensive
	PROMOTION_SPY_ACE_DRIVER       = "[ICON_PROMOTION_SPY_ACE_DRIVER]",
	PROMOTION_SPY_CAT_BURGLAR      = "[ICON_GreatWork_Landscape_Themed]",
	PROMOTION_SPY_CON_ARTIST       = "[ICON_GoldLarge]",
	PROMOTION_SPY_COVERT_ACTION    = "[ICON_PROMOTION_SPY_COVERT_ACTION]", -- foment unrest
	PROMOTION_SPY_DEMOLITIONS      = "[ICON_DISTRICT_INDUSTRIAL_ZONE]",
	PROMOTION_SPY_DISGUISE         = "[ICON_PROMOTION_SPY_DISGUISE]",
	PROMOTION_SPY_GUERILLA_LEADER  = "[ICON_Barbarian]",
	PROMOTION_SPY_LICENSE_TO_KILL  = "[ICON_Governor]",
	PROMOTION_SPY_LINGUIST         = "[ICON_TradeRouteLarge]", --  ICON_LifeSpan ICON_Turn
	PROMOTION_SPY_ROCKET_SCIENTIST = "[ICON_DISTRICT_SPACEPORT]",
	PROMOTION_SPY_SATCHEL_CHARGES  = "[ICON_DISTRICT_DAM]",
	PROMOTION_SPY_SMEAR_CAMPAIGN   = "[ICON_PROMOTION_SPY_SMEAR_CAMPAIGN]", -- fabricate scandal
	PROMOTION_SPY_TECHNOLOGIST     = "[ICON_ScienceLarge]",
};

function GetSpyLevelAndPromotions(unit:table)
	--print("FUN GetSpyLevelAndPromotions", unit:GetName());
	local iLevel:number = unit:GetExperience():GetLevel();
	if iLevel < 2 then return "", "", "", Locale.Lookup("LOC_ESPIONAGE_LEVEL_1_NAME"); end -- Spy Recruit
	local sPromosD:string, sPromosO = "", "";
	local tPromoTT:table = {};
	table.insert(tPromoTT, Locale.Lookup("LOC_ESPIONAGE_LEVEL_"..tostring(iLevel).."_NAME")); -- level name
	for _,promo in ipairs(unit:GetExperience():GetPromotions()) do
		local promoInfo:table = GameInfo.UnitPromotions[promo];
		local icon:string = "?";
		if PromotionIconsDef[promoInfo.UnitPromotionType] then
			--icon = PromotionIconsDef[promoInfo.UnitPromotionType];
			icon = "[ICON_"..promoInfo.UnitPromotionType.."]";
			sPromosD = sPromosD..icon;
		elseif PromotionIconsOff[promoInfo.UnitPromotionType] then
			--icon = PromotionIconsOff[promoInfo.UnitPromotionType];
			icon = "[ICON_"..promoInfo.UnitPromotionType.."]";
			sPromosO = sPromosO..icon;
		else
			sPromosD = sPromosD..icon; sPromosO = sPromosO..icon;
		end
		table.insert(tPromoTT, icon.." "..Locale.Lookup(promoInfo.Name)..": "..Locale.Lookup(promoInfo.Description));
	end
	return GetSpyRankIconByLevel(iLevel), sPromosD, sPromosO, table.concat(tPromoTT, "[NEWLINE]"); -- level, promotion icons, tooltip
end
