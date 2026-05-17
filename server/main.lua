local Ox = exports.ox_inventory
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

lib.callback.register("aura-registers:server:CreateInvoice", function(source, data)
    local creator = Ox.GetPlayer(source)
    local target = Ox.GetPlayer(tonumber(data.targetId))

    if not creator or not target then
        return {success = false, message = locale("notifications.invalid_players")}
    end

    if creator.getJob() ~= data.registerJob then
        return {success = false, message = locale("notifications.unauthorized")}
    end

    local invoiceId = generateInvoiceId()
    local creatorName = creator.getName(true)
    local targetName = target.getName(true)

    local invoice = {
        id = invoiceId,
        fromId = source,
        fromName = creatorName,
        toId = tonumber(data.targetId),
        toName = targetName,
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

    TriggerEvent('ox_lib:notify', tonumber(data.targetId), {
        title = locale("notifications.invoice_received_title"),
        description = locale("notifications.invoice_received", creatorName, data.amount),
        type = 'success'
    })

    return {success = true, invoiceId = invoiceId}
end)

lib.callback.register("aura-registers:server:GetInvoices", function(source)
    return ActiveInvoices[source] or {}
end)

lib.callback.register("aura-registers:server:PayInvoice", function(source, invoiceId)
    local player = Ox.GetPlayer(source)

    if not player then
        return {success = false, message = locale("notifications.invalid_players")}
    end

    local playerInvoices = ActiveInvoices[source]
    if not playerInvoices then
        return {success = false, message = locale("notifications.no_invoices")}
    end

    for i, invoice in ipairs(playerInvoices) do
        if invoice.id == invoiceId and invoice.status == INVOICE_STATUS_PENDING then
            local cashCount = Ox.GetItemCount(source, 'money')
            if cashCount < invoice.amount then
                TriggerEvent('ox_lib:notify', source, {
                    title = locale("notifications.insufficient_funds_title"),
                    description = locale("notifications.insufficient_funds"),
                    type = 'error'
                })
                return {success = false, message = locale("notifications.insufficient_funds")}
            end

            Ox.RemoveItem(source, 'money', invoice.amount)
            Ox.AddItem(invoice.fromId, 'money', invoice.amount)

            invoice.status = INVOICE_STATUS_PAID
            invoice.paidAt = os.time()

            TriggerEvent('ox_lib:notify', source, {
                title = locale("notifications.invoice_paid_title"),
                description = locale("notifications.invoice_paid"),
                type = 'success'
            })

            local sender = Ox.GetPlayer(invoice.fromId)
            if sender then
                TriggerEvent('ox_lib:notify', invoice.fromId, {
                    title = locale("notifications.invoice_paid_to_sender_title"),
                    description = locale("notifications.invoice_paid_to_sender", invoiceId, player.getName(true)),
                    type = 'success'
                })
            end

            return {success = true}
        end
    end

    return {success = false, message = locale("notifications.invoice_not_found")}
end)

lib.callback.register("aura-registers:server:PayCash", function(source, data)
    local giver = Ox.GetPlayer(source)
    local receiver = Ox.GetPlayer(tonumber(data.targetId))

    if not giver or not receiver then
        return {success = false, message = locale("notifications.invalid_players")}
    end

    if giver.getJob() ~= data.registerJob then
        return {success = false, message = locale("notifications.unauthorized")}
    end

    local cashCount = Ox.GetItemCount(tonumber(data.targetId), 'money')
    if cashCount < data.amount then
        return {success = false, message = locale("notifications.insufficient_cash")}
    end

    Ox.RemoveItem(tonumber(data.targetId), 'money', data.amount)
    Ox.AddItem(source, 'money', data.amount)

    TriggerEvent('ox_lib:notify', source, {
        title = locale("notifications.payment_received_title"),
        description = locale("notifications.payment_received", data.amount),
        type = 'success'
    })

    TriggerEvent('ox_lib:notify', tonumber(data.targetId), {
        title = locale("notifications.cash_payment_made_title"),
        description = locale("notifications.cash_payment_made", data.amount),
        type = 'success'
    })

    return {success = true}
end)
