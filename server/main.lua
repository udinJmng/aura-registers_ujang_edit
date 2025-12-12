local QBCore = exports["qb-core"]:GetCoreObject()
local INVOICE_PREFIX = "INV_"
local INVOICE_STATUS_PENDING = "pending"
local INVOICE_STATUS_PAID = "paid"
local RANDOM_MIN = 1000
local RANDOM_MAX = 9999

local ActiveInvoices = {}

local function generateInvoiceId()
    return INVOICE_PREFIX .. os.time() .. "_" .. math.random(RANDOM_MIN, RANDOM_MAX)
end

if Config.VersionCheck then
    lib.versionCheck('auradevelopment5m/aura-registers')
end

QBCore.Functions.CreateCallback("aura-registers:server:CreateInvoice", function(source, cb, data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local targetPlayer = QBCore.Functions.GetPlayer(tonumber(data.targetId))

    if not player or not targetPlayer then
        cb({success = false, message = locale("notifications.invalid_players")})
        return
    end

    if player.PlayerData.job.name ~= data.registerJob then
        cb({success = false, message = locale("notifications.unauthorized")})
        return
    end

    local invoiceId = generateInvoiceId()

    local invoice = {
        id = invoiceId,
        fromId = src,
        fromName = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname,
        toId = tonumber(data.targetId),
        toName = targetPlayer.PlayerData.charinfo.firstname .. " " .. targetPlayer.PlayerData.charinfo.lastname,
        amount = data.amount,
        items = data.items,
        registerLabel = data.customLabel or data.registerLabel,
        registerJob = data.registerJob,
        created = os.time(),
        status = INVOICE_STATUS_PENDING
    }

    if not ActiveInvoices[tonumber(data.targetId)] then
        ActiveInvoices[tonumber(data.targetId)] = {}
    end
    table.insert(ActiveInvoices[tonumber(data.targetId)], invoice)

    TriggerClientEvent("QBCore:Notify", tonumber(data.targetId), locale("notifications.invoice_received", invoice.fromName, data.amount), "success")

    cb({success = true, invoiceId = invoiceId})
end)

QBCore.Functions.CreateCallback("aura-registers:server:GetInvoices", function(source, cb)
    local src = source
    local invoices = ActiveInvoices[src] or {}
    cb(invoices)
end)

QBCore.Functions.CreateCallback("aura-registers:server:PayInvoice", function(source, cb, invoiceId)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)

    if not player then
        cb({success = false, message = locale("notifications.invalid_players")})
        return
    end

    local playerInvoices = ActiveInvoices[src]
    if not playerInvoices then
        cb({success = false, message = locale("notifications.no_invoices")})
        return
    end

    for i, invoice in ipairs(playerInvoices) do
        if invoice.id == invoiceId and invoice.status == INVOICE_STATUS_PENDING then
            if player.PlayerData.money.bank < invoice.amount then
                cb({success = false, message = locale("notifications.insufficient_funds")})
                return
            end

            player.Functions.RemoveMoney("bank", invoice.amount)

            local bankingSuccess = false
            local bankingError = nil
            if GetResourceState('qb-banking') == 'started' then
                local success, result = pcall(function()
                    return exports['qb-banking']:AddMoney(invoice.registerJob, invoice.amount, "Invoice Payment")
                end)

                bankingSuccess = success and (result == nil or result == true)
                if not success then
                    bankingError = result
                end
            end

            if not bankingSuccess then
                local fromPlayer = QBCore.Functions.GetPlayer(invoice.fromId)
                if fromPlayer then
                    fromPlayer.Functions.AddMoney("bank", invoice.amount)
                else
                    player.Functions.AddMoney("bank", invoice.amount)
                    cb({success = false, message = locale("notifications.payment_failed")})
                    return
                end
            end

            invoice.status = INVOICE_STATUS_PAID
            invoice.paidAt = os.time()

            TriggerClientEvent("QBCore:Notify", src, locale("notifications.invoice_paid"), "success")

            local fromPlayer = QBCore.Functions.GetPlayer(invoice.fromId)
            if fromPlayer then
                TriggerClientEvent("QBCore:Notify", invoice.fromId, locale("notifications.invoice_paid_to_sender", invoiceId, player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname), "success")
            end

            cb({success = true})
            return
        end
    end

    cb({success = false, message = locale("notifications.invoice_not_found")})
end)

QBCore.Functions.CreateCallback("aura-registers:server:PayCash", function(source, cb, data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local targetPlayer = QBCore.Functions.GetPlayer(tonumber(data.targetId))

    if not player or not targetPlayer then
        cb({success = false, message = locale("notifications.invalid_players")})
        return
    end

    if player.PlayerData.job.name ~= data.registerJob then
        cb({success = false, message = locale("notifications.unauthorized")})
        return
    end

    if targetPlayer.PlayerData.money.cash < data.amount then
        cb({success = false, message = locale("notifications.insufficient_cash")})
        return
    end

    targetPlayer.Functions.RemoveMoney("cash", data.amount)
    player.Functions.AddMoney("cash", data.amount)

    TriggerClientEvent("QBCore:Notify", src, locale("notifications.payment_received", data.amount), "success")

    TriggerClientEvent("QBCore:Notify", tonumber(data.targetId), locale("notifications.cash_payment_made", data.amount), "success")

    cb({success = true})
end)