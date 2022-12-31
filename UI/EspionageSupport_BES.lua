--------------------------------------------------------------
-- Better Espionage Screen
-- Author: Infixo, astog
-- 2022-12-31: Created
--------------------------------------------------------------

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
