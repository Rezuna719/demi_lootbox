local pendingRolls = 0
local currentGachaName = nil

local function SendReactMessage(action, data)
  SendNUIMessage({
    action = action,
    data = data
  })
end

-- ガチャのアイテムプールと当選番号を受け取ってクライアント側で実行する処理
RegisterNetEvent("demi_lootbox:RollCase", function(lootpool, winner)
    SendReactMessage('setLootData', { pool = lootpool, winner = winner })
end)

--10連処理
RegisterNetEvent('demi_lootbox:RollCase10', function(pools, winners)
    for i = 1, #pools do
        local pool = pools[i]
        local winner = winners[i]
        -- 既存の演出処理を使い回す
        TriggerEvent('demi_lootbox:RollCase', pool, winner)
        Wait(500)
    end
end)

--ガチャ演出完了時の処理
RegisterNUICallback("finished", function(winner, cb)
    TriggerServerEvent("demi_lootbox:getQueuedItem")
    TriggerServerEvent("demi_lootbox:releaseRollLock")

    --残りガチャ回数があれば継続
    pendingRolls = (pendingRolls or 0) - 1

    if pendingRolls > 0 then
        TriggerServerEvent('demi_lootbox:useLootItem', currentGachaName)
    else
        currentGachaName = nil
        pendingRolls = 0
    end
    cb({})
end)

--アイテムが使用されるとこれが動いてサーバーにガチャが動き出す
RegisterNetEvent('demi_lootbox:useGacha', function(item)
    if not item or not item.name then return end

    --既に何かしらのガチャを実行中なら引かせない。
    if pendingRolls and pendingRolls > 0 then
        lib.notify({
            type = 'error',
            icon = 'hourglass-half',
            description = 'ガチャを実行中です。演出が完了するまでお待ちください。'
        })
        return
    end

    local count = exports.ox_inventory:GetItemCount(item.name)
    if count <= 0 then
        lib.notify({ type = 'error', description = 'このアイテムを持っていません。' })
        return
    end

    if count == 1 then
        pendingRolls = 1
    else
        local input = lib.inputDialog('ガチャ回数を入力', {
            { type = 'number', label = '何回回しますか？',
              description = 'ESCキーで連続ガチャをキャンセルできます',
              min = 1, default = math.min(10, count) }
        })
        if not input or not input[1] then return end
        pendingRolls = math.min(tonumber(input[1]), count)
    end

    currentGachaName = item.name
    TriggerServerEvent('demi_lootbox:useLootItem', currentGachaName)
end)

CreateThread(function()
    while true do
        Wait(0)
        if pendingRolls > 0 and IsControlJustPressed(0, 322) then -- 322 = ESCキー
            TriggerEvent('demi_lootbox:cancelRolls')
            lib.notify({ type = 'success', icon = 'share', description = '次のガチャをキャンセルしました。' })
        end
    end
end)

RegisterNetEvent('demi_lootbox:cancelRolls', function()
    currentItemName = nil
    pendingRolls = 0
end)
