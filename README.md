# demi_lootbox - README.md

## 改造内容（by レズナ）

このリポジトリは、元の `demi_lootbox` スクリプトをベースに、Qbox環境での使用を想定して以下の改造を加えたものです：

1. Qboxでの使用を想定して `client.lua`、`data.lua`、`server.lua` を編集しました。  
2. `bridge.lua` は使用しないため削除しました。  
3. 使用中に再使用不可の状態とし、再使用によるアイテムロストを防止しました。  
4. ガチャアイテムを複数所有している場合、自動的に連続で引く処理を追加しました。  
5. ガチャの種類ごとに確率を変更するサンプルを `data.lua` に追記しました。  
6. 「標準ガチャ」アイテムが 1% の確率で「限定ガチャ」に変化する処理を追加しました。

これらの改造を加えた本リポジトリは、元の `demi_lootbox` と同じライセンスで提供されます。

## Modifications (by Rezuna)

This repository is a modified version of the original `demi_lootbox` script, adapted for use in Qbox environments. The following changes have been made:

1. Edited `client.lua`, `data.lua`, and `server.lua` to support Qbox integration.  
2. Removed `bridge.lua` as it is not used in this setup.  
3. Prevented re-use during active operation to avoid item loss.  
4. Added automatic multi-roll functionality when the player owns multiple gacha items.  
5. Included sample logic to vary probabilities based on gacha type.  
6. Added a mechanic where the "standard gacha" item has a 1% chance to transform into a "limited gacha".

This modified repository is distributed under the same license as the original `demi_lootbox`.

## Overview

`demi_lootbox` is a FiveM script that brings a CSGO-style case opening user interface into your server. With a visual representation and configurable case contents, this script enhances the in-game economy with randomized loot mechanics.

## Features

- **Customizable Cases:** Define your own cases with varying rarity levels (common, uncommon, rare, epic, legendary).
- **UI:** A UI that gives players a sense of anticipation when opening cases.

## Dependecies

- ESX, QB, or standalone with ox_inventory.

## Installation

1. Copy the `demi_lootbox` folder into your server's resources directory.
2. Add `ensure demi_lootbox` to your server configuration file.

## Configuration

The primary configuration for your cases is done within the `CASES` table found in `server/data.lua` Here, you can define your own cases with varying rarity levels and the weapons/items each rarity level might contain.

each rarity should have at least 1 item in it, or the script wont work properly.

Example:

```lua
CASES = {
    ['gun_case'] = {
        common = {
            {
                name = 'WEAPON_PISTOL',
                amount = 1,
            },
            {
                name = 'WEAPON_SNSPISTOL',
                amount = 1,
            },
        },
        uncommon = {
            {
                name = 'WEAPON_HEAVYPISTOL',
                amount = 1,
            },
        },
        rare = {
            {
                name = 'WEAPON_APPISTOL',
                amount = 1,
            },
        },
        epic = {
            {
                name = 'WEAPON_COMBATPDW',
                amount = 1,
            },

        },
        legendary = {
            {
                name = 'WEAPON_RPG',
                amount = 1,
            },
        },
    }
}
```

## Exported Functions (server)

### addNewLootBox

```lua
exports.demi_lootbox:addNewLootBox(caseName, caseContents, cb)
```

the cb function will run before the case is opened

**Example:**

```lua
		exports.demi_lootbox:addNewLootBox('fishing_chest_money', {
			common = {
				{
					name = 'money',
					amount = 500
				}
			},
			uncommon = {
				{
					name = 'money',
					amount = 2500
				}
			},
			rare = {
				{
					name = 'money',
					amount = 5000
				}
			},
			epic = {
				{
					name = 'money',
					amount = 7500
				}
			},
			legendary = {
				{
					name = 'money',
					amount = 10000
				}
			},
		}, function(src)
			TriggerClientEvent('rb-fishing:chestScene', src)
		end)
```

## Probabilities

for those curious about the chances

- Common: 80%
- Uncommon: 16%
- Rare: 3.10%
- Epic: 0.64%
- Legendary: 0.26%

## Feedback & Support

For any feedback or support regarding the script, please reach out in the forums or discord `demiautomatic`.
