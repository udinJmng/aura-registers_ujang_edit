local QBCore = exports["qb-core"]:GetCoreObject()

local localeData = {}
local allLocales = {}

local supportedLocales = {"en", "es", "tr", "ar"}

for _, localeCode in ipairs(supportedLocales) do
    local localeFile = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. localeCode .. '.json')
    if localeFile then
        allLocales[localeCode] = json.decode(localeFile) or {}
    end
end

local playerLocale = GetConvar("locale", Config.DefaultLocale or "en")
local localeFile = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. playerLocale .. '.json')
if not localeFile then
    localeFile = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. (Config.DefaultLocale or "en") .. '.json')
    playerLocale = Config.DefaultLocale or "en"
end

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

local CASH_REGISTER_MODEL <const> = GetHashKey("prop_till_01")
local TARGET_DISTANCE <const> = 2.0

local activeTargets = {}
local activeZones = {}

local function unregisterAllTargets()
    for _, entity in ipairs(activeTargets) do
        if DoesEntityExist(entity) then
            exports['qb-target']:RemoveTargetEntity(entity)
        end
    end
    activeTargets = {}

    for _, zoneId in ipairs(activeZones) do
        exports['qb-target']:RemoveZone(zoneId)
    end
    activeZones = {}
end

local function registerTargetsForJob(playerJob)
    if not playerJob then return end

    unregisterAllTargets()

    lib.requestModel(CASH_REGISTER_MODEL)

    for registerName, registerConfig in pairs(Config.Registers) do
        if registerConfig.jobRequired == playerJob and registerConfig.locations then
            if registerConfig.openingMethod == "target" then
                for _, propData in ipairs(registerConfig.locations) do
                    local obj = CreateObject(CASH_REGISTER_MODEL, propData.coords.x, propData.coords.y, propData.coords.z, false, false, false)
                    SetEntityHeading(obj, propData.heading)
                    FreezeEntityPosition(obj, true)
                    SetEntityInvincible(obj, true)

                    exports['qb-target']:AddTargetEntity(obj, {
                        options = {{
                            type = "client",
                            event = "aura-registers:client:openRegister",
                            icon = "fas fa-cash-register",
                            label = locale("ui.open_register", registerConfig.label),
                            registerName = registerName
                        }},
                        distance = TARGET_DISTANCE
                    })

                    table.insert(activeTargets, obj)
                end
            elseif registerConfig.openingMethod == "boxzone" then
                for i, propData in ipairs(registerConfig.locations) do
                    local zoneId = string.format("%s_%d", registerName, i)
                    exports['qb-target']:AddBoxZone(zoneId, propData.coords, 1.5, 1.5, {
                        name = zoneId,
                        heading = propData.heading,
                        debugPoly = false,
                        minZ = propData.coords.z - 1.0,
                        maxZ = propData.coords.z + 1.0
                    }, {
                        options = {{
                            type = "client",
                            event = "aura-registers:client:openRegister",
                            icon = "fas fa-cash-register",
                            label = locale("ui.open_register", registerConfig.label),
                            registerName = registerName
                        }},
                        distance = TARGET_DISTANCE
                    })

                    table.insert(activeZones, zoneId)
                end
            end
        end
    end

    SetModelAsNoLongerNeeded(CASH_REGISTER_MODEL)
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Wait(1000)
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData and playerData.job then
            registerTargetsForJob(playerData.job.name)
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local playerData = QBCore.Functions.GetPlayerData()
    if playerData and playerData.job then
        registerTargetsForJob(playerData.job.name)
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    registerTargetsForJob(job.name)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        unregisterAllTargets()
    end
end)

local function openRegister(registerName)
    local playerData = QBCore.Functions.GetPlayerData()

    if not playerData or not playerData.job then
        lib.notify({
            title = "Error",
            description = "Unable to get player job data.",
            type = "error"
        })
        return
    end

    local playerJob = playerData.job.name

    if not registerName then
        for regName, regData in pairs(Config.Registers) do
            if regData.jobRequired == playerJob then
                registerName = regName
                break
            end
        end

        if not registerName then
            lib.notify({
                title = "Access Denied",
                description = "You do not have permission to access any register.",
                type = "error"
            })
            return
        end
    end

    if not Config.Registers[registerName] then
        lib.notify({
            title = "Invalid Register",
            description = string.format("Register '%s' not found in configuration.", registerName),
            type = "error"
        })
        return
    end

    local registerData = Config.Registers[registerName]

    if playerJob ~= registerData.jobRequired then
        lib.notify({
            title = "Access Denied",
            description = "You do not have permission to access this register.",
            type = "error"
        })
        return
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "ui:open",
        payload = {
            success = true,
            register = registerData,
            menuItems = registerData.menuItems,
            categories = registerData.categories,
            locales = allLocales,
            currentLocale = Config.DefaultLocale or "es"
        }
    })
end

RegisterNetEvent("aura-registers:client:openRegister", function(data)
    openRegister(data.registerName)
end)

RegisterCommand("viewinvoices", function()
    QBCore.Functions.TriggerCallback("aura-registers:server:GetInvoices", function(invoices)
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "ui:invoices",
            payload = {
                invoices = invoices,
                locales = allLocales,
                currentLocale = Config.DefaultLocale or "es"
            }
        })
    end)
end, false)

RegisterNUICallback("ui:closeNUI", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({type = "ui:close", payload = false})
    cb("ok")
end)

RegisterNUICallback("ui:billPlayer", function(data, cb)
    local playerData = QBCore.Functions.GetPlayerData()

    if not playerData or not playerData.job then
        cb({success = false, message = "No job data found"})
        return
    end

    if data.paymentMethod == "cash" and not data.customLabel then
        QBCore.Functions.TriggerCallback("aura-registers:server:PayCash", function(result)
            cb(result)
        end, {
            targetId = data.targetId,
            amount = data.amount,
            registerJob = playerData.job.name
        })
    else
        local invoiceItems = data.items or {}
        if data.customItem then
            invoiceItems = {{
                id = "custom",
                name = data.customItem,
                price = data.amount,
                quantity = 1
            }}
        end
        
        QBCore.Functions.TriggerCallback("aura-registers:server:CreateInvoice", function(result)
            cb(result)
        end, {
            targetId = data.targetId,
            amount = data.amount,
            items = invoiceItems,
            registerLabel = data.registerLabel,
            registerJob = playerData.job.name,
            customLabel = data.customLabel
        })
    end
end)

RegisterNUICallback("ui:payInvoice", function(data, cb)
    QBCore.Functions.TriggerCallback("aura-registers:server:PayInvoice", function(result)
        if not result or not result.success then
            cb({success = false, message = "Payment failed - please try again"})
            return
        end
        
        if result.success then
            QBCore.Functions.TriggerCallback("aura-registers:server:GetInvoices", function(invoices)
                if invoices then
                    SendNUIMessage({
                        type = "ui:invoices",
                        payload = {
                            invoices = invoices,
                            locales = allLocales,
                            currentLocale = Config.DefaultLocale or "es"
                        }
                    })
                end
                cb(result)
            end)
        else
            cb(result)
        end
    end, data.invoiceId)
end)
