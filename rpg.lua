-- BETA VERSION
-- LUNA TEAM
local socket = require("socket")

local function cloneTable(tbl)
  local copy = {}
  for k, v in pairs(tbl) do
    if type(v) == "table" then
      copy[k] = cloneTable(v)
    else
      copy[k] = v
    end
  end
  return copy
end

local GAME_VERSION = "BETA RELEASE 1.1.3.1"
local REST_COST = 20
local COMMON_BOX_COST = 50
local LEGENDARY_BOX_COST = 200
local MAX_COMMON_BOXES = 1000
local MAX_LEGENDARY_BOXES = 2000
local STARTING_GOLD = 99999999999

math.randomseed(os.time())

io.write("Your charactor name: ")
local username = io.read()
if username == "" then
  username = "Warrior"
end

local function randomString(length)
  local str = ''
  while true do
    for i = 1, length do
      local randomNum = math.random(1, 3)
      if randomNum == 1 then
        --lower case
        str = str .. string.char(math.random(97, 122))

      elseif randomNum == 2 then
        -- upper case
        str = str .. string.char(math.random(65, 90))

      else
        -- digits
        str = str .. string.char(math.random(48, 57))
      end
    end
    return str
  end
end

--local randomstr = randomString(10)

local player = {
  name= username,
  level = 1,
  exp = 0,
  maxEXP = 100,
  health = 100,
  maxHealth = 100,
  damage = 5,
  defense = 2,
  gold = STARTING_GOLD,
  inventory = {},
  inventory_limit = 20,
  equipped = {
    weapon = nil,
    armor = nil,
  }
}

local function generateEnemy(playerLevel)
  local levelFactor = math.max(1, playerLevel * 0.5)

  return {
    name = randomString(10),
    exp = math.floor(math.random(10, 20) * levelFactor),
    health = math.floor(math.random(10, 15) * levelFactor),
    maxHealth = math.floor(math.random(10, 15) * levelFactor),
    damage = math.floor(math.random(2, 6) * levelFactor),
    defense = math.floor(math.random(2, 5) * levelFactor),
    gold = math.floor(math.random(9, 18) * levelFactor)
  }
end

local enemy_list = {
  generateEnemy(1),
  generateEnemy(1)
}

local common_luckybox_loot = {
  { name = "Iron Sword", damage = 10, chance = 60, rank = "Uncommon", type = "weapon"},
  { name = "Leater Armor", defense = 2, chance = 50, rank = "Common", type = "armor"},
  { name = "Steel Sword", damage = 20, chance = 35, rank = "Rare", type = "weapon"},
  { name = "Health Potion", heal = 30, chance = 40, rank = "Rare", type = "consumable"}
}

local legendary_luckybox_loot = {
  { name = "Mask of Guardian", damage = 10, chance = 0.99342, rank = "Rare", type = "weapon"},
  { name = "Ice Cloth Armor", defense = 15, chance = 0.98723, rank = "Rare", type = "armor"},
  { name = "Magic Orbs", damage = 20, chance = 0.7, rank = "Epic", type = "weapon"},
  { name = "Eyes of Dragon", damage = 40, chance = 0.132, rank = "Legend", type = "weapon"},
  { name = "Cruz Blade", damage = 60, chance = 0.1, rank = "Legend", type = "weapon"},
  { name = "Zues Protection", defense = 100, chance = 0.01, rank = "Exotic", type = "armor"},
  { name = "Titan Armor", defense = 50, chance = 0.12, rank = "Divine", type = "armor"},
  { name = "Fire Dragon Cloth Armor", damage = 50, defense = 60, chance = 0.01, rank = "Exotic", type = "armor"}
}

local enemy_loot = {
  { name = "Wooden Sword", damage = 5, rank = "Common", chance = 60, type = "weapon"},
  { name = "Cloth Armor", defense = 2, rank = "Common", chance = 50, type = "armor"},
  { name = "Health Potion", heal = 30, rank = "Rare", chance = 40, type = " consumable"},
  { name = "Warrior Orbs", damage = 7, defense = 5, rank = "Rare", chance = 30, type = "weapon"},
  { name = "Gold x2", rank = "Epic", chance = 5, type = "buff"},
  { name = "EXP x2", rank = "Epic", chance = 5, type = "buff"}
}

local shop_items = {
 {name = "Basic Sword", damage = 8, price = 100, type = "weapon", rank = "Common"},
 {name = "Chain Armor", defense = 5, price = 150, tyoe = "armor", rank = "Common"},
 {name = "Health Potion", heal = 50, price = 30, type = "consumable", rank = "Common"},
 {name = "Steel Sword", damage = 15, price = 300, type = "weapon", rank = "Uncommon"},
 {name = "Steel Armor", defense = 10, price = 400, type= "armor", rank = "Uncommon"}
}

local lucky_wheel = {
  {name = "Gold", reward = math.random(10, 100), chance = math.random(10, 50), rank = "Rare", type = "reward"},
  {name = "Health Potion", reward = 1, chance = math.random(10, 50), rank = "Rare", type = "reward"},
  {name = "Grim Reaper Mask", reward = 1, chance = 0.1, rank = "Legend", type = "weapon", damage = 70},
  {name = "Death Knight Armor", reward = 1, chance = 20, rank = "Rare", type = "armor", defense = 35}
}

----------------------------------------------------------------------------
local function addItemToInventory(item)
  if #player.inventory >= player.inventory_limit then
    print("[!] Inventory is full! cannot pick up " .. item.name)
    return false
  end
  table.insert(player.inventory, item)
  return true
end

local function findItemInInventory(itemName)
  for i, item in ipairs(player.inventory) do
    if item.name == itemName then
      return i, item
    end
  end
  return nil, nil
end

local function equipItem(itemIndex)
  local item = player.inventory[itemIndex]

  if not item then
    print("[!] Item not found in inventory!")
    return false
  end

  if item.type == "weapon" then
    if player.equipped.weapon then
      print("\nComparing weapons:")
      print(string.format("Current: %s (Damage: %d)", player.equipped.weapon.name, player.equipped.weapon.damage))
      print(string.format("New: %s (Damage: %d)", item.name, item.damage))
      
      table.insert(player.inventory, player.equipped.weapon)
      player.damage = player.damage - player.equipped.weapon.damage
      print("[*] Unequipped " .. player.equipped.weapon.name)
    end

    player.equipped.weapon = item
    player.damage = player.damage + item.damage
    table.remove(player.inventory, itemIndex)
    print("[+] Equipped " .. item.name .. "! Damage increased by " .. item.damage)
    return true

  elseif item.type == "armor" then
    if player.equipped.armor then
      print("\nComparing armor:")
      print(string.format("Current: %s (Defense: %d)", player.equipped.armor.name, player.equipped.armor.defense))
      print(string.format("NewL %s (Defense: %d)", item.name, item.defense))
      
      table.insert(player.inventory, player.equipped.armor)
      player.defense = player.defense - player.equipped.armor.defense
      print("[*] Unequipped: " .. player.equipped.armor.name)
    end

    player.equipped.armor = item
    player.defense = player.defense + item.defense
    table.remove(player.inventory, itemIndex)
    print("[+] Equipped " .. item.name .. "! Defense increased by " .. item.defense)
    return true

  else
    print("[!] This item cannot be equipped!")
    return false
  end
end

local function enemy_dropLoot()
  local dropped_item = nil
  for _, item in ipairs(enemy_loot) do
    local roll = math.random() * 100
    if roll <= item.chance then
      dropped_item = cloneTable(item)
      break
    end
  end
  return dropped_item
end

local function useItem()
  --check Inventory
  if #player.inventory == 0 then
    print("[!] Your inventory is empty!")
    return false
  end

  print("\n========== Your Inventory ==========")
  for i, item in ipairs(player.inventory) do
    local itemInfo = item.name
    if item.type == "weapon" then
      itemInfo = itemInfo .. " (Damage: " .. item.damage .. ")"
    elseif item.type == "armor" then
      itemInfo = itemInfo .. " (Defense: " .. item.defense .. ")"
    elseif item.type == "consumable" and item.heal then
      itemInfo = itemInfo .. " (Heal: " .. item.heal .. ")"
    end
    print(i .. ": " .. itemInfo .. " | Type: " .. item.type)
  end

  io.write("\nChoose item to use (0 to cancel): ")
  local choice = tonumber(io.read())

  if not choice or choice == 0 or choice > #player.inventory then
    return false
  end

  local item = player.inventory[choice]

  if item.type == "consumable" then
    if item.heal then
      if player.health >= player.maxHealth then
        print("[!] Your health is already full!!")
        return false
      end

      local healAmount = math.min(item.heal, player.maxHealth - player.health)
      player.health = player.health + healAmount
      print("[+] Used " .. item.name .. " and restored " .. healAmount .. " HP!")
      table.remove(player.inventory, choice)
      return true
    end

  elseif item.type == "weapon" or item.type == "armor" then
    return equipItem(choice)

  elseif item.type == "buff" then
    print("[+] Buff item used!")
    table.remove(player.inventory, choice)
    return true

  else
    print("[!] Cannot use this item!")
    return false
  end
  return false
end

local function applyGoldBuff(baseGold)
  local buffIndex, buffItem = findItemInInventory("Gold x2")

  if buffIndex then
    local reward = baseGold * 2
    print("[+] Gold x2 buff applied! You gained " .. reward .. " gold instead of " .. baseGold)
    table.remove(player.inventory, buffIndex)
    return reward
  end
  return baseGold
end

local function applyExpBuff(baseExp)
  local buffIndex, buffItem = findItemInInventory("EXP x2")

  if buffIndex then
    local reward = baseExp * 2
    print("[+] EXP x2 buff applied! You gained " .. reward .. "EXP instead of " .. baseExp)
    table.remove(player.inventory, buffIndex)
    return reward
  end

  return baseExp
end
----------------------------------------------------------------------------
local function common_dropItem() -- common box
  local dropped_item = nil
  for _, item in ipairs(common_luckybox_loot) do
    local roll = math.random() * 100
    if roll <= item.chance then
      dropped_item = cloneTable(item)
      break
    end
  end
  return dropped_item
end

local function legend_dropItem()
  local total_chance = 0
  for _, items in ipairs(legendary_luckybox_loot) do
    total_chance = total_chance + items.chance
  end

  math.randomseed(os.time() + math.random(1000))
  local random_roll = math.random() * total_chance
  local current_chance = 0

  for _, items in ipairs(legendary_luckybox_loot) do
    current_chance = current_chance + items.chance
    if random_roll <= current_chance then
      return cloneTable(items)
    end
  end
  return nil
end

function randomize_item_legend(duration, target_item)
  duration = duration or 3
  local messages = { "Mask of Guardian", "Ice Cloth Armor", "Magic Orbs", "Eyes of Dragon", "Cruz Blade", "Zues Protection", "Titan Armor", "Fire Dragon Cloth Armor" }
  
  local start_time = socket.gettime()
  math.randomseed(os.time())

  while socket.gettime() - start_time < duration do
    local msg = messages[math.random(#messages)]
    io.write("\r[*] God choosing: " .. msg .. "          ")
    io.flush()
    socket.sleep(0.1)
  end

  if target_item then
    io.write("\r[*] God choosing: " .. target_item.name .. "      ")
    print()
    return target_item
  else
    io.write("\r[*] God choosing: Nothing...       \n")
    print()
    return nil
  end
end

function randomize_item_common(duration, target_item)
  duration = duration or 3
  local messages = { "Iron Sword", "Leater Armor", "Steel Sword", "Health Potion"}

  local start_time = socket.gettime()
  math.randomseed(os.time())

  while socket.gettime() - start_time < duration do
    local msg = messages[math.random(#messages)]
    io.write("\r[*] God choosing: " .. msg .. "          ")
    io.flush()
    socket.sleep(0.1)
  end

  if target_item then
    io.write("\r[*] God choosing: " .. target_item.name .. "          ")
    print()
    return target_item
  else
    io.write("\r[*] God choosing: Nothing...          \n")
    print()
    return nil
  end
end

local function status()
  local inventory_display = "None"
  if #player.inventory > 0 then
    inventory_display = ""
    for i, item in ipairs(player.inventory) do
      if i > 1 then inventory_display = inventory_display .. ", " end
      inventory_display = inventory_display .. item.name
    end
  end

  print("\n====== Player Status ======")
  print("Name: " .. player.name)
  print("Level: " .. player.level)
  print("Damage: " .. player.damage)
  print("Defense: " .. player.defense)
  print("Gold: " .. player.gold)
  print("Inventory: " .. inventory_display)

  if player.equipped.weapon then
    print("Equipped Weapon: " .. player.equipped.weapon.name .. " (Damage: " .. player.equipped.weapon.damage .. ")")
  else
    print("Equipped Weapon: None")
  end

  if player.equipped.armor then
    print("Equipped Armor: " .. player.equipped.armor.name .. " (Defense: " .. player.equipped.armor.defense .. ")")
  end
  return player
end

local function checkLevelUp()
  if player.exp >= player.maxEXP then
    player.level = player.level + 1
    player.maxEXP = math.floor(player.maxEXP * 1.5)
    player.exp = 0
    player.maxHealth = player.maxHealth + 20
    player.health = player.maxHealth
    print("[+] Level up!! You're Level: " .. player.level .. "!")

    enemy_list = {
      generateEnemy(player.level),
      generateEnemy(player.level)
    }
    return true

  end
  return false
end

local function clear()
  if package.config.sub(1,1) == '\\' then
    os.execute('cls')
  else
    os.execute('clear')
  end
end

local function gameHelp()
  print("\n========== Game Help ==========")
  print("Battle: Fight monsters to gain exp and gold")
  print("Rest: Heal yourself for " .. REST_COST .. " gold")
  print("Explore: Find items, gold, or enemies")
  print("Shop: Buy items or try your luck with lucky box")
  print("Status: Check your stats and inventory")
  print("\nTips:")
  print("- Equip weapons and armor to increase your stats")
  print("- Use potions during battle to heal")
  print("- Run away from battle if your health is low")
  print("- Save gold for better equipment")
  print("- Inventory limit: " .. player.inventory_limit .. " items")
  print("========== Good Luck :P ==========")
end

local function battle()
  local enemy = enemy_list[math.random(#enemy_list)]

  local current_enemy = cloneTable(enemy)

  if player.health <= 0 then
    print("[!] You're ran of health please restore your health with rest :P")
    return
  end

  print("\n========================================================")
  print("[!] A wilds " .. current_enemy.name .. " appears!")
  print("========================================================")
  while player.health > 0 and current_enemy.health > 0 do
    print("\n[!] " .. current_enemy.name .. " Health: " .. current_enemy.health)
    print("[+] " .. player.name .. " Health: " .. math.floor(player.health) .. "/" .. player.maxHealth)
    print("\n[1] Attack")
    print("[2] Use Item")
    print("[3] Run away!?")
    io.write("> ")
    local choice = tonumber(io.read())

    if choice == 1 then
      -- Player Attack First
      local damage_dealth = math.max(1, player.damage - current_enemy.defense / 2)
      current_enemy.health = current_enemy.health - damage_dealth
      print("\n========================================================")
      print("[+] You attacked " .. current_enemy.name .. " for " .. damage_dealth .. " damage!")
      
      if current_enemy.health > 0 then
        local damage_taken = math.max(1, current_enemy.damage - player.defense / 2)
        player.health = player.health - damage_taken
        print("[!] " .. current_enemy.name .. " hits you for " .. damage_taken .. " damage!")
      end

      if player.health <= 0 then
        print("[!] You were defeated by " .. current_enemy.name .. " and lost half of your gold and health")
        player.gold = math.floor(player.gold / 2)
        player.health = math.max(1, math.floor(player.maxHealth * 0.1))
        return false
      end
      
      if current_enemy.health <= 0 then
        print("[+] You defeated " .. current_enemy.name .. "!")

        local dropped_item = enemy_dropLoot()
        if dropped_item then
          print("[+] " .. current_enemy.name .. " dropped: " .. dropped_item.name --[[.. " (" .. dropped_item.rank .. ")"--]] )

          if dropped_item.name == "Gold x2" then
            print("[+] You got a Gold x2 buff for your next battle!")

          elseif dropped_item.name == "EXP x2" then
            print("[+] You got an EXP x2 buff for your next battle!")
          end

          table.insert(player.inventory, dropped_item)
        end

        local gold_earned = applyGoldBuff(current_enemy.gold)
        local exp_earned = applyExpBuff(current_enemy.exp)

        print("[+] You gained: " .. gold_earned .. " gold | EXP: " .. exp_earned .. "!")
        player.gold = player.gold + gold_earned
        player.exp = player.exp + exp_earned
        checkLevelUp()
        return true
      end
      print("========================================================")

    elseif choice == 2 then
      useItem()

    elseif choice == 3 then
      local escape_chance = math.random(1, 10)

      if escape_chance > 3 then
        print("[+] You've escaped successfully!")
        return false

      else
        print("[+] Your escaped failed!!")
        local damage_taken = math.max(1, current_enemy.damage - player.defense / 2)
        print("[!] Enemy attacked you for " .. damage_taken .. " damage!")
        player.health = player.health - damage_taken

        if player.health <= 0 then
          print("[!] You were defeated by " .. current_enemy.name .. " and lost half of your gold and health!")
          player.gold = math.floor(player.gold / 2)
          player.health = math.max(1, math.floor(player.maxHealth * 0.1))
          return false
        end
      end
    end
  end
  return true
end

local function rest()
  if player.gold < 20 then
    print("[!] Not enough gold to rest.. (20 Gold Require)")
    return

  elseif player.health >= player.maxHealth then
    print("[!] Your health is full, Can't rest now")
    return
  end

  player.gold = player.gold - 20
  local heal_amount = math.floor(player.maxHealth - player.health)
  print("[+] The world is safe now... (Recovered " .. math.floor(heal_amount) .. " HP)")
  player.health = player.maxHealth

end

local function explore()
  print("\n[+] You are exploring the area...")

  local event_chance = math.random(1, 10)

  if event_chance <= 3 then
    print("[!] You encountered an enemy")
    battle()

  elseif event_chance <= 6 then
    local gold_found = math.random(5, 20) * player.level
    print("[+] You found " .. gold_found .. " gold!")
    player.gold = player.gold + gold_found

  elseif event_chance <= 8 then
    local item = common_dropItem()
    if item then
      print("[+] You found an item: " .. item.name .. " (" .. item.rank .. ")")
      table.insert(player.inventory, item)

    else
      print("[+] You found nothing interesting...")
    end

  elseif event_chance == 9 then
    local heal_amount = math.random(10, 30)
    if player.health < player.maxHealth then
      print("[+] You found some healing herbs! (Recovered " .. heal_amount .. " HP)")
      player.health = math.min(player.maxHealth, player.health + heal_amount)
    else
      print("[+] You found some healing herbs, but your health is already full")
    end

  else
    print("[+] You found nothing interesting...")
  end
end

local function shop()
  local shopping = true
  while shopping do
    print("\n========== old man's shop ==========")
    print("[1] Buy Items (Sword, Armor, Potion)")
    print("[2] Lucky Box")
    print("[3] Lucky Wheel")
    print("[0] Exit")
    io.write("> ")
    local shop_choice = tonumber(io.read())

    if shop_choice == 1 then
      print("\n========== Shop Items ==========")
      for i, item in ipairs(shop_items) do
        local stats = ""
        if item.damage then
          stats = "Damage: " .. item.damage
        elseif item.defense then
          stats = "Defense: " .. item.defense
        elseif item.heal then
          stats = "Heal: " .. item.heal
        end
        print(string.format("[%d] %s (%s) - %d gold [%s]", i, item.name, stats, item.price, item.rank))
      end
      print("[0] Back")
      io.write("> ")
      local choice = tonumber(io.read())

      if choice and choice > 0 and choice <= #shop_items then
        local item = shop_items[choice]
        if player.gold >= item.price then
          player.gold = player.gold - item.price
          local bought_item = cloneTable(item)
          print("[+] Bought " .. item.name .. "!")
          addItemToInventory(bought_item)
        else
          print("[!] Not enough gold!")
        end
      end

    elseif shop_choice == 2 then
      local luckybox_area = true
      while luckybox_area == true do
        print("\n >>> Lucky Box!! <<<")
        print("[1] Common Box(50 Gold)")
        print("[2] Legendary Box(200 Gold)")
        print("[0] Back to shop")
        io.write("> ")
        local luckybox_choice = tonumber(io.read())

        if luckybox_choice == 1 then
          print("\n===== Common Items List =====")

          for i, item in ipairs(common_luckybox_loot) do
            print(i .. ": " .. item.name .. " | Rank: " .. item.rank .. " | Chance: " .. item.chance .. "%")
          end

          if player.gold < COMMON_BOX_COST then
            print("[!] Not Enough gold!")
            break
          end
          io.write("\nHow many boxes you want to buy?(" .. COMMON_BOX_COST .. " Gold/Box):")
          local box = tonumber(io.read())

          if not box or box < 1 then
            break
          end

          if box > MAX_COMMON_BOXES then
            print("[!] Maximum box is " .. MAX_COMMON_BOXES)
            break
          end

          if player.gold < (box * COMMON_BOX_COST) then
            print("[!] Not enough gold for " .. box .. " boxes!")
            break
          end

          player.gold = player.gold - (box * COMMON_BOX_COST)

          print("==========================================================")
          print("[*] Opening " .. box .. " Common boxes....\n")
          local items_found = 0
          for i = 1, box do
            local item = common_dropItem()
            local result = randomize_item_common(3, item)
            if result and addItemToInventory(result) then
              print("[+] Box #" .. i .. ": Got " .. result.name .. " (Chance: " .. result.chance .. "%)\n")
              items_found = items_found + 1
            end
          end
          if items_found == 0 then
              print("[!] No items found in any boxes :(")
          end
          print("==========================================================")

        elseif luckybox_choice == 2 then
          print("\n===== Legendary Items List =====")
          for i, items in ipairs(legendary_luckybox_loot) do
            print(i .. ": " .. items.name .. " | Rank: " .. items.rank .. " | Chance: " .. items.chance .. "%")
          end

          if player.gold < LEGENDARY_BOX_COST then
            print("[!] Not enough gold!")
            break
          end
          io.write("\nHow many boxes you want to buy?(" .. LEGENDARY_BOX_COST .. " Gold/Box): ")
          local box = tonumber(io.read())

          if not box or box < 1 then
            break
          end

          if box > MAX_LEGENDARY_BOXES then
            print("[!] Maximum box is " .. MAX_LEGENDARY_BOXES)
            break
          end

          if player.gold < (box * LEGENDARY_BOX_COST) then
            print("[!] Not enough gold for " .. box .. " boxes!")
            break
          end
          player.gold = player.gold - (box * LEGENDARY_BOX_COST)

          print("====================================================================")
          print("[*] Opening " .. box .. " Legendary boxes....\n")
          local rare_items = {}
          local items_found = 0

          for i = 1, box do
            local items = legend_dropItem()
            local result = randomize_item_legend(3, items)
            if result then
              if result.rank == "Legend" or result.rank == "Exotic" or result.rank == "Divine" then
                table.insert(rare_items, result)
                print("[!] RARE DROP from box #" .. i .. ": " .. result.name .. " | Rank: " .. result.rank .. " | Chance: " .. result.chance .. "%\n")
              else
                print("[+] Box#" .. i .. ": Got>> " .. result.name .. " | Rank: " .. result.rank .. "\n")
              end

              if addItemToInventory(result) then
                items_found = items_found + 1
              end
            end
          end

          print("==================================================================")
          if #rare_items == 0 then
            print("[!] No rare items found. Better luck next time :P")
          end
          if items_found == 0 then
            print("[!] Could not store any items - inventory full!")
          end

        elseif luckybox_choice == 0 then
          luckybox_area = false
        end
      end

    elseif shop_choice == 3 then
      local daily_used = false
      local countdown = os.time() + 24 * 60 * 60
      local luckyWheel = true
      while luckyWheel == true do
      local now = os.time()
      local remaining = countdown - now

      if remaining <= 0 and daily_used == true then
          -- รีเซ็ต countdown และ daily_used เมื่อครบ 24 ชั่วโมง
          countdown = os.time() + 24 * 60 * 60
          daily_used = false
          remaining = countdown - now
      end

      local hour = math.max(0, math.floor(remaining / 3600))
      local minute = math.max(0, math.floor((remaining % 3600) / 60))
      local second = math.max(0, remaining % 60)

      clear()
      print("===== Welcome to Daily Lucky Wheel! =====\n")

      if daily_used == true then
        print(string.format("Next spin available in: %02d:%02d:%02d", hour, minute, second))
      else
          print("Daily spin available!")
      end

      print("\nAvailable rewards:")
      for i, loot in ipairs(lucky_wheel) do
        print(i .. " | " .. loot.name .. " | Rank: " .. loot.rank .. " | Chance: " .. loot.chance)
      end

      print("\n[1] Spin")
      print("[0] Back to Shop")
      io.write("> ")
      local choice = tonumber(io.read())

      if choice == 1 then
        if daily_used == false then
            print("You spinned for 1 item!")

            math.randomseed(os.time())
            local random = math.random(100)
            local selected_item

            if random <= 5 then
                selected_item = lucky_wheel[4]
            elseif random <= 20 then
                selected_item = lucky_wheel[3]
            elseif random <= 50 then
                selected_item = lucky_wheel[2]
            else
                selected_item = lucky_wheel[1]
            end

            print("Congratulations! You got: " .. selected_item.name .. " (Rank: " .. selected_item.rank .. ")")

            daily_used = true
            countdown = os.time() + 24 * 60 * 60

            print("Press Enter to continue...")
            io.read()
        else
            print("You have already used your daily spin!")
            print(string.format("Please wait %02d:%02d:%02d for next spin", hour, minute, second))
            print("Press Enter to continue...")
            io.read()
        end
      elseif choice == 0 then
        luckyWheel = false
      end
      
      os.execute("sleep 1" or "timeout /t 1 >nul")
       end

    elseif shop_choice == 0 then
      shopping = false
    end
  end
end

local function main()
  clear()
  while true do
    print("\n================== Main Menu ========================")
    print("[" .. GAME_VERSION .. " BETA FEATURES TEXT-BASED-RPG]")
    print("     [type help to show game help and tips]")
    print("=====================================================")
    print("[1] Battle")
    print("[2] Rest")
    print("[3] Explore")
    print("[4] Use Item")
    print("[5] Shop")
    print("[6] Player Status")
    print("[0] Exit")
    print("=====================================================")
    print(player.name .. " Level: " .. player.level .. "(" .. player.exp .. "/" .. player.maxEXP .. ")" .. " | HP: " .. math.floor(player.health) .. "/" .. player.maxHealth)
    io.write("> ")
    local choice = io.read()

    if choice == "help" then
      gameHelp()
    end
    if choice == "1" then
      battle()

    elseif choice == "2" then
      rest()

    elseif choice == "3" then
      explore()

    elseif choice == "4" then
      useItem()

    elseif choice == "5" then
      shop()
    
    elseif choice == "6" then
      status()

    elseif choice == "0" then
      os.exit()

    elseif choice == "clear" or choice == "cls" then
      clear()

    else end
  end
end

main()
