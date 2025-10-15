-- FS25 Extended Input HUD
-- Author: Mirano (Port from FS22 Mod by HoFFi)
-- Expands the number of lines shown in the F1 Input Help menu

ExtendedInputHUD = {}

local function getUiScaleSafe()
    if g_gameSettings ~= nil and g_gameSettings.getValue ~= nil then
        local s = g_gameSettings:getValue("uiScale")
        if s ~= nil then return s end
    end
    return 1.0
end

function ExtendedInputHUD:computeExtraLines(scale)
    -- Conservative curve to avoid clipping outside the F1 frame at high scales
    if scale <= 0.8 then
        return 12
    elseif scale <= 1.0 then
        return 8
    elseif scale <= 1.2 then
        return 6
    elseif scale <= 1.4 then
        return 4
    else
        return 2
    end
end

function ExtendedInputHUD:getMaxEntryCountOverwritten(inputHelpDisplay, superFunc, ...)
    local base = superFunc(inputHelpDisplay, ...)
    local scale = getUiScaleSafe()
    local extra = self:computeExtraLines(scale)
    -- Always at least base, but add extra capacity
    local result = math.max(base, base + extra)
    return result
end

function ExtendedInputHUD:loadMap()
    if InputHelpDisplay ~= nil and Utils ~= nil and Utils.overwrittenFunction ~= nil then
        InputHelpDisplay.getMaxEntryCount = Utils.overwrittenFunction(
            InputHelpDisplay.getMaxEntryCount,
            function(inputHelpDisplay, superFunc, ...)
                return ExtendedInputHUD:getMaxEntryCountOverwritten(inputHelpDisplay, superFunc, ...)
            end
        )
        print("FS25_ExtendInputHUD: Overwrote InputHelpDisplay.getMaxEntryCount()")
    else
        print("FS25_ExtendInputHUD: WARNING - could not hook InputHelpDisplay.getMaxEntryCount()")
    end
end

addModEventListener(ExtendedInputHUD)
