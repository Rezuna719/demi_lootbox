local CASES = {}
local POOL_SIZE = 100
local activeRolls = {} --ガチャ実施中のプレイヤー情報（再使用禁止用）

math.randomseed(os.time()) --乱数シード値をサーバー起動時に設定して、ランダム性を上げる

local function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

local function tableConcat(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end 
    
    return t1 
end

--ガチャ毎に確率を定義する(data.luaで定義した名称と合わせて下さい。)
local lootboxRates = {
    ['027_gacha'] = {
        common = 60,
        uncommon = 30,
        rare = 7,
        epic = 2,
        legendary = 0,
    },
    ['027_gacha_limited'] = {
        common = 0,
        uncommon = 0,
        rare = 0,
        epic = 0,
        legendary = 100,
    },
}

-- ガチャの中身を作って返す処理
local function generateLootPool(caseName)
    local case = CASES[caseName]
    local pool = {}

    --ガチャ毎の確率を取ってくる
    local desiredCounts = table.clone(lootboxRates[caseName])

    --desiredCounts の中でレア度の決まった枠を数える
    local totalCount = 0
    for _, count in pairs(desiredCounts) do
        totalCount += count
    end

    -- 残りの枠が埋まるまでランダムでレジェンダリー、エピック、レアを追加する
    while totalCount < POOL_SIZE do
        local roll = math.random(100)
        if roll > 99 then desiredCounts.legendary = (desiredCounts.legendary or 0) + 1  --1%でレジェンダリーが入る
        elseif roll > 97 then desiredCounts.epic  = (desiredCounts.epic or 0) + 1       --2%でエピックが入る
        else desiredCounts.rare                   = (desiredCounts.rare or 0) + 1       --97％でレアが入る
        end
        totalCount += 1
    end

    -- desiredCounts の初期化後に 0 のレアリティを除去(アイテム割付時の混入防止)
    for rarity, count in pairs(desiredCounts) do
        if count <= 0 then
            desiredCounts[rarity] = nil
        end
    end

    --枠のレアリティに従ってガチャデータからアイテムを割り付ける
    for i = 1, POOL_SIZE do
        local rarity = next(desiredCounts)
        if not rarity then break end

        local items = case[rarity]
        if items and #items > 0 then
            local item = items[math.random(#items)]
            item.rarity = rarity
            pool[i] = item
            desiredCounts[rarity] -= 1
            if desiredCounts[rarity] <= 0 then desiredCounts[rarity] = nil end
        else
            -- レアリティが存在しない場合はスキップ
            desiredCounts[rarity] = nil
        end
    end

    shuffle(pool)

    --演出時間確保のためにプールを2倍にする
    local finalPool = tableConcat(pool, pool)

    return finalPool
end

local playerLootQueue = {}

-- ガチャを作って当選番号を返す処理
function GetCaseData(src, caseName)
    --標準ガチャが1%の確率で限定ガチャに変化する
    if caseName == "027_gacha" and math.random(100) == 1 then
        caseName = "027_gacha_limited"
    end

    -- CASESテーブルからガチャの種類（トリガーアイテム）を取得
    local case = CASES[caseName]

    -- ガチャの種類が存在しなければ終了
    if not case then
        print("[Lootbox] CASE not found:", caseName)
        return
    end

    -- アイテムプールを作成
    local pool = generateLootPool(caseName)
    if not pool or #pool == 0 then
        print("[Lootbox] Generated pool is empty")
        return
    end
    -- プールの後半部分からランダムに当選番号を選ぶ
    local winner = math.random(POOL_SIZE) + POOL_SIZE
    -- プレイヤーのソースIDをキーに当選アイテムをキューに保存
    playerLootQueue[src] = pool[winner]
    --print("[Lootbox] Queued item:", json.encode(pool[winner]))
    -- クライアントに渡すためにアイテムプールと当選番号を返す
    return pool, winner - 1
end

--地面にアイテムを置く処理
function DropItemAtPlayer(src, itemName, amount)
    --受け渡しの数が0の場合スキップ
    if not amount or tonumber(amount) <= 0 then return end

    local ped = GetPlayerPed(src)
    if not ped or not DoesEntityExist(ped) then return end

    local coords = GetEntityCoords(ped)

    exports.ox_inventory:CustomDrop('Lootbox Drop', { { itemName, tonumber(amount) } }, coords)
end

-- 当選アイテムを受け取る処理
RegisterNetEvent('demi_lootbox:getQueuedItem', function()
    local src = source
    local loot = playerLootQueue[src] --当選アイテムをキューから取得
    playerLootQueue[src] = nil        --当選アイテムのキューをクリア

    if not loot then
        print("^1[WARNING] Player", src, "triggered lootbox get item event while not in queue^7")
        return
    end

    -- 追加アイテムの受け取り処理
    if loot.additionalItems then
        for _, item in ipairs(loot.additionalItems) do
            local success = exports.ox_inventory:AddItem(src, item.name, item.amount)
            --インベントリに追加できなかったら地面に置く
            if not success then
                DropItemAtPlayer(src, item.name, item.amount)
            end
        end
    end

    -- メインアイテムの受け取り処理
    local success = exports.ox_inventory:AddItem(src, loot.name, loot.amount)
    --インベントリに追加できなかったら地面に置く
    if not success  then
        DropItemAtPlayer(src, loot.name, loot.amount)
    end
end)

--ガチャ演出を開始する。
RegisterNetEvent('demi_lootbox:useLootItem', function(itemName)
    local src = source

    --使用中なら処理をスキップする
    if activeRolls[src] then
        --print(("[Lootbox] Player %d tried to roll while animation active"):format(src))
        return
    end

    if exports.ox_inventory:RemoveItem(src, itemName, 1) then
        activeRolls[src] = true --再使用をロック

        local pool, winner = GetCaseData(src, itemName)
        if not pool then
            print("[Lootbox] GetCaseData returned nil pool for", itemName)
            activeRolls[src] = nil
            return
        end

        TriggerClientEvent('demi_lootbox:RollCase', src, pool, winner)
    end
end)

--再使用のロックを解除する
RegisterNetEvent('demi_lootbox:releaseRollLock', function()
    local src = source
    activeRolls[src] = nil
end)

--ガチャアイテムの登録・使用・演出・ラベル付与の初期化関数
exports('addNewLootBox', function(name, allCases, cb)
    local contents = allCases[name]
    if not contents then
        print(("[Lootbox] No case found for '%s' in provided data"):format(name))
        return
    end

    if CASES[name] then return end
    CASES[name] = contents

    for rarity, items in pairs(contents) do
        for i = 1, #items do
            local item = items[i]
            item.label = exports.ox_inventory:Items()[item.name]?.label or item.name
        end
    end
end)
