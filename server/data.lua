--[[
    if not using ox_inventory, you will need to manually add the inventory image links to the items in this list.
        {
            name = 'WEAPON_PISTOL',
            amount = 1,
            imageUrl = 'https://image.png'
        },

]]

local lootboxData = {
    -- ガチャを実行するトリガーのアイテムを設定
    ['027_gacha'] = { -- this index should be the name of the item used if you are triggering this through using an item
        --標準ガチャの収録リスト
        common = {
            {
                name = '027_sakura_common',
                amount = 1,
                imageUrl = '',
                additionalItems = {
                    { name = '027_gacha', amount = 1 },
                }
            },
        },
        uncommon = {
            {
                name = '027_sakura_uncommon',
                amount = 1,
                imageUrl = '',
                additionalItems = {
                    { name = '027_gacha', amount = 1 },
                }
            },
        },
        rare = {
            {
                name = '027_sakura_rare',
                amount = 1,
                imageUrl = '',
                additionalItems = {
                    { name = '027_gacha', amount = 1 },
                }
            },
        },
        epic = {
            {
                name = '027_sakura_epic',
                amount = 1,
                imageUrl = '',
                additionalItems = {
                    { name = '027_gacha', amount = 1 },
                }
            },
        },
        legendary = {
            {
                name = '027_sakura_legendary',
                amount = 1,
                imageUrl = '',
                additionalItems = {
                    { name = '027_gacha', amount = 1 },
                }
            },
        },
    },

    --限定ガチャの収録リスト
    ['027_gacha_limited'] = {
        common = {
            {
                name = '027_sakura_common',
                amount = 1,
                imageUrl = '',
                additionalItems = {
                    { name = '027_gacha_limited', amount = 1 },
                }
            },
        },
        uncommon = {
            {
                name = '027_sakura_uncommon',
                amount = 1,
                imageUrl = '',
                additionalItems = {
                    { name = '027_gacha_limited', amount = 1 },
                }
            },
        },
        rare = {
            {
                name = '027_sakura_rare',
                amount = 1,
                imageUrl = '',
                additionalItems = {
                    { name = '027_gacha_limited', amount = 1 },
                }
            },
        },
        epic = {
            {
                name = '027_sakura_epic',
                amount = 1,
                imageUrl = '',
                additionalItems = {
                    { name = '027_gacha_limited', amount = 1 },
                }
            },
        },
        legendary = {
            {
                name = '027_sakura_legendary',
                amount = 1,
                imageUrl = '',
                additionalItems = {
                    { name = '027_gacha_limited', amount = 1 },
                }
            },
        },
    },
}

--ガチャの種類ごとに個別のexportsを作成してください
exports["demi_lootbox"]:addNewLootBox("027_gacha", lootboxData)
exports["demi_lootbox"]:addNewLootBox("027_gacha_limited", lootboxData)

--別のガチャを作れば以下のように追加
--exports["demi_lootbox"]:addNewLootBox("027_gacha_new", lootboxData)