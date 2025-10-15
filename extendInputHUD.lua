-- Extended Input HUD (FS25 port)
extendInputHUD = {}

local function computeExtraByUiScale()
    local s = g_gameSettings and g_gameSettings.uiScale or 1.0
    -- conservative increments so we don't overflow the frame in FS25
    if s < 0.76 then return 10
    elseif s <= 0.80 then return 9
    elseif s <= 0.85 then return 8
    elseif s <= 0.90 then return 7
    elseif s <= 0.95 then return 6
    elseif s <= 1.00 then return 5
    elseif s <= 1.05 then return 4
    elseif s <= 1.15 then return 3
    else return 1
    end
end

local function overwrittenGetMaxEntryCount(self, superFunc, prio, ignoreLive)
    local count = superFunc(self, prio, ignoreLive)
    local extra = computeExtraByUiScale()

    -- Respect FS25 internal reductions if fields exist (defensive checks)
    if self ~= nil then
        if self.hasComboCommands then
            count = count - 1
        end
        if self.extraHelpTexts ~= nil then
            count = count - #self.extraHelpTexts
        end
        if self.vehicleHudExtensions ~= nil then
            for _, hudExtension in pairs(self.vehicleHudExtensions) do
                if hudExtension.getHelpEntryCountReduction ~= nil then
                    count = count - hudExtension:getHelpEntryCountReduction()
                end
            end
        end
    end

    -- Add our extra entries but keep a small safety margin to avoid drawing outside the frame
    return math.max(1, count + extra - 4)
end

function extendInputHUD:loadMap()
    if InputHelpDisplay ~= nil and Utils ~= nil and Utils.overwrittenFunction ~= nil then
        InputHelpDisplay.getMaxEntryCount = Utils.overwrittenFunction(InputHelpDisplay.getMaxEntryCount, overwrittenGetMaxEntryCount)
    end
end

function extendInputHUD.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "loadMap", extendInputHUD)
end

addModEventListener(extendInputHUD)
