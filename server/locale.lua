local localeData = {}
local allLocales = {}

local supportedLocales = {"en", "es", "tr", "ar"}

for _, localeCode in ipairs(supportedLocales) do
    local localeFile = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. localeCode .. '.json')
    if localeFile then
        allLocales[localeCode] = json.decode(localeFile) or {}
    end
end

local localeFile = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. (Config.DefaultLocale or "en") .. '.json')
if localeFile then
    localeData = json.decode(localeFile) or {}
end

_G.locale = function(key, ...)
    local keys = {}
    for k in string.gmatch(key, "([^%.]+)") do
        table.insert(keys, k)
    end

    local current = localeData
    for _, k in ipairs(keys) do
        if current and type(current) == "table" and current[k] then
            current = current[k]
        else
            return key
        end
    end

    if type(current) == "string" then
        if ... then
            return current:format(...)
        end
        return current
    end

    return key
end