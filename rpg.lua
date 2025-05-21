--[[
BETA RELEASE 1.1.0
- Added Lucky Box Feature
- When Player Level up monster will level up follow player level
- IDK will add more features later X_X
--]]



math.randomseed(os.time())
--math.random(); math.random(); math.random()

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
  gold = 9999999,
  inventory = {},
}

local enemy_list = {
  { name = randomString(10), exp = math.random(10, 20), health = math.random(10, 15), damage = math.random(2, 6), defense = math.random(2, 5), gold = math.random(9, 18)},
  { name = randomString(20), exp = math.random(15, 20), health = math.random(14, 18), damage = math.random(7, 10), defense = math.random(1, 3), gold = math.random(10, 25)},
}

local common_luckybox_loot = {
  { name = "Iron Sword", damage = 10, chance = 60, rank = "Uncommon"},
  { name = "Leater Armor", defense = 2, chance = 50, rank = "Common"},
  { name = "Steel Sword", damage = 20, chance = 35, rank = "Rare"},
  { name = "Health Potion", heal = 30, chance = 40, rank = "Rare"}
}

local legendary_luckybox_loot = {
  { name = "Mask of Guardian", damage = 10, chance = 0.99342, rank = "Rare"},
  { name = "Ice Cloth Armor", defense = 15, chance = 0.98723, rank = "Rare"},
  { name = "Magic Orbs", damage = 20, chance = 0.7, rank = "Epic"},
  { name = "Eyes of Dragon", damage = 40, chance = 0.132, rank = "Legend"},
  { name = "Cruz Blade", damage = 60, chance = 0.1, rank = "Legend"},
  { name = "Zues Protection", defense = 100, chance = 0.01, rank = "Exotic"},
  { name = "Titan Armor", defense = 50, chance = 0.12, rank = "Divine"},
  { name = "Fire Dragon Cloth Armor", damage = 50, defense = 60, chance = 0.01, rank = "Exotic"}
}

local enemy_loot = {
  { name = "Wooden Sword", damage = 5, rank = "Common", chance = 60},
  { name = "Cloth Armor", defense = 2, rank = "Common", chance = 50},
  { name = "Health Potion", heal = 30, rank = "Rare", chance = 40},
  { name = "Warrior Orbs", damage = 7, defense = 5, rank = "Rare", chance = 30},
  { name = "Gold x2", rank = "Epic", chance = 5},
  { name = "EXP x2", rank = "Epic", chance = 5}
}
----------------------------------------------------------------------------
local function enemy_dropLoot()
  local dropped_item = nil

  for _, item in ipairs(enemy_loot) do
    local roll = math.random() * 100

    if roll <= item.chance then
      dropped_item = item
      break
    end
  end
  return dropped_item
end

local function useItem()
  --check Inventory
  if #player.inventory == 0 then
    print("[!] Your inventory is empty!")
    return
  end

  for i , item in ipairs(player.inventory) do
    print(i .. ": " .. inventory.name)
    -- ถามว่าจะใช้ไอเท็มชิ้นไหน
  end
end

local function gold2()
  local useItem() == false
  if useItem == true then
    local reward = math.floor(player.gold + enemy.gold) * 2
    print("[+] You gained: " .. enemt.gold .. " But You have goldx2 You gained: " .. reward)
  end
end

local function exp2()
  -- logic Exp x2
end
----------------------------------------------------------------------------
local function common_dropItem() -- common box
  local dropped_item = nil

  for _, item in ipairs(common_luckybox_loot) do
    local roll = math.random() * 100

    if roll <= item.chance then
      dropped_item = item
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

  local random_roll = math.random() * total_chance

  local dropped_item = nil
  for _, items in ipairs(legendary_luckybox_loot) do
    if random_roll <= items.chance then
      dropped_item = items
      break
    else
      random_roll = random_roll - items.chance
    end
  end
  return dropped_item
end

local function status()
  local inventory_list = table.concat(player.inventory, ", ")
  print("\n====== Player Status ======")
  print("Name: " .. player.name)
  print("Level: " .. player.level)
  print("Damage: " .. player.damage)
  print("Defense: " .. player.defense)
  print("Gold: " .. player.gold)
  print("Inventory: " .. inventory_list)
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
  end
  return true
end

local function clear()
  os.execute('clear' or 'cls')
end

local function battle()
  local enemy = enemy_list[math.random(#enemy_list)]
  local enemy_health = enemy.health

  if player.health <= 0 then
    print("[!] You're ran of health please restore your health with rest :P")
    return
  end

  print("\n========================================================")
  print("[!] A wilds " .. enemy.name .. " appears!")
  print("========================================================")
  while player.health > 0 and enemy_health > 0 do
    print("\n[!] " .. enemy.name .. " Health: " .. enemy_health)
    print("[+] " .. player.name .. " Health: " .. math.floor(player.health) .. "/" .. player.maxHealth)
    print("\n[1] Attack")
    print("[2] Run away")
    io.write("> ")
    local choice = tonumber(io.read())

    if choice == 1 then
      -- Player Attack First
      enemy_health = enemy_health - player.damage
      print("\n========================================================")
      print("[+] You attacked " .. enemy.name .. " for " .. player.damage .. " damage!")

      -- Enemy Turn
      player.health = player.health - enemy.damage
      print("[!] " .. enemy.name .. " hits you for " .. enemy.damage .. " damage!")
      -- check player health
      if player.health <= 0 then
        print("\nYou were defeated by " .. enemy.name .. " and you lost half of your gold and health")
        player.gold = player.gold / 2
        player.health = player.health / 2
      end

      if enemy_health <= 0 then
        print("\n[+] You defeated " .. enemy.name .. "!")
        print("[+] Player Gained: " .. enemy.gold .. " gold | EXP: " .. enemy.exp .. "!" )
        player.gold = player.gold + enemy.gold
        player.exp = player.exp + enemy.exp
        checkLevelUp()
      end
      print("========================================================")

    elseif choice == 2 then
      local escape_chance = math.random(1, 10)

      if escape_chance > 3 then
        print("[+] You've escaped successfully'")
        return
      else
        print("[+] You've escape failed!!'")
        print("\n[!] Enemy attacked you " .. enemy.damage .. " damage")
        player.health = player.health - enemy.damage
      end
      return true
    end
  end
  return false
end

local function rest()
  if player.gold < 20 then
    print("[!] Not enough gold to rest.. (20 Gold Require)")
    return

  elseif player.health >= player.maxHealth then
    print("[!] Your health is full, Can't rest now")
    return
  end

  if player.gold >= 20 then
    local heal_amount = math.floor(player.maxHealth - player.health)
    print("[+] The world is safe now... (Recovered " .. heal_amount .. " HP)")
    player.health = player.health + heal_amount
  end
end

local function explore()

end

local function shop()
  local shopping = true
  while shopping == true do
    print("\n========== old man's shop ==========")
    print("[1] Buy Items (Sword, Armor, Potion)")
    print("[2] Lucky Box")
    print("[0] Exit")
    io.write("> ")
    local shop_choice = tonumber(io.read())

    if shop_choice == 1 then
      -- logic

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

          if player.gold < 50 then
            print("[!] Not Enough gold!")
            return shop
          end
          io.write("\nHow many boxes you want to buy?(50 Gold/Box): ")
          local box = tonumber(io.read())

          if box > 1000 then
            print("[!] Maximum box is not more than 1000")
            return true
          end
          player.gold = player.gold - (box * 50)

          print("==========================================================")
          print("[*] Your dream come true...")
          for i = 1, box do
            local item = common_dropItem()
            if item then
              print("[+] You've got: " .. item.name .. " (Chance: " .. item.chance .. "%" .. ")")
            else
              print("[!] Nothing Here :P")
            end
          end
          print("==========================================================")

        elseif luckybox_choice == 2 then
          print("\n===== Legendary Items List =====")
          for i, items in ipairs(legendary_luckybox_loot) do
            print(i .. ": " .. items.name .. " | Rank: " .. items.rank .. " | Chance: " .. items.chance .. "%")
          end

          local found_rare = false
          if player.gold < 50 then
            print("[!] Not enough gold!")
            return shop
          end
          io.write("\nHow many boxes you want to buy?(200 Gold/Box): ")
          local box = tonumber(io.read())
          if box > 100000 then
            print("[!] Maximum box is not more then 2000")
            return true
          end
          player.gold = player.gold - (box * 200)

          for i = 1, box do
            local items = legend_dropItem()
            if items and items.name == "Ice Cloth Armor" or items and items.name == "Magic Orbs" or items and items.name == "Eyes of Dragon" or items and items.name == "Cruz Blade" or items and items.name == "Zues Protection" or items and items.name == "Titan Armor" or items and items.name == "Fire Dragon Cloth Armor" then
              print("====================================================================")
              print("[!] You've got Legendary item: " .. items.name .. " | Rank: " .. items.rank .. " | Chance: " .. items.chance)
              found_rare = true
              print("====================================================================")
              break
            end
          end

          if not found_rare then
            print("[!] Nothing in here :P Better luck next time")
          end

        elseif luckybox_choice == 0 then
          return shopping
        end
      end

    elseif shop_choice == 0 then
      return shopping == false
    end
  end
end

local function main()
  clear()
  while true do
    print("================== Main Menu =======================")
    print("[BETA RELEASE 1.1.0 BETA FEATURES TEXT-BASED-RPG]")
    print("====================================================")
    print("[1] Battle")
    print("[2] Rest")
    print("[3] Explore")
    print("[4] Shop")
    print("[5] Plater Status")
    print("[0] Exit")
    print("====================================================")
    print(player.name .. " Level: " .. player.level .. "(" .. player.exp .. "/" .. player.maxEXP .. ")" .. " | HP: " .. math.floor(player.health) .. "/" .. player.maxHealth)
    io.write("> ")
    local choice = io.read()

    if choice == nil then end

    if choice == "1" then
      battle()

    elseif choice == "2" then
      rest()

    elseif choice == "3" then
      explore()

    elseif choice == "4" then
      shop()

    elseif choice == "5" then
      status()

    elseif choice == "0" then
      os.exit()

    elseif choice == "clear" or choice == "cls" then
      clear()

    else end
  end
end

main()
