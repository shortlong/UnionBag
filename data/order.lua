
UB = UB or {}

local categoryOrder = {
    ["misc fishing misc"] = 1,
    ["armor plate chest"] = 2,
    ["armor plate legs"] = 3,
    ["armor plate feet"] = 4,
    ["armor plate hands"] = 5,
    ["armor plate head"] = 6,
    ["armor plate shoulders"] = 7,
    ["armor plate waist"] = 8,
    ["armor chain chest"] = 9,
    ["armor chain legs"] = 10,
    ["armor chain feet"] = 11,
    ["armor chain hands"] = 12,
    ["armor chain head"] = 13,
    ["armor chain shoulders"] = 14,
    ["armor chain waist"] = 15,
    ["armor leather chest"] = 16,
    ["armor leather legs"] = 17,
    ["armor leather feet"] = 18,
    ["armor leather hands"] = 19,
    ["armor leather head"] = 20,
    ["armor leather shoulders"] = 21,
    ["armor leather waist"] = 22,
    ["armor cloth chest"] = 23,
    ["armor cloth legs"] = 24,
    ["armor cloth feet"] = 25,
    ["armor cloth hands"] = 26,
    ["armor cloth head"] = 27,
    ["armor cloth shoulders"] = 28,
    ["armor cloth waist"] = 29,
    ["armor accessory neck"] = 30,
    ["armor accessory ring"] = 31,
    ["armor accessory trinket"] = 32,
    ["weapon onehand sword"] = 33,
    ["weapon onehand axe"] = 34,
    ["weapon onehand mace"] = 35,
    ["weapon onehand dagger"] = 36,
    ["weapon twohand sword"] = 37,
    ["weapon twohand axe"] = 38,
    ["weapon twohand mace"] = 39,
    ["weapon twohand polearm"] = 40,
    ["weapon twohand staff"] = 41,
    ["weapon ranged bow"] = 42,
    ["weapon ranged gun"] = 43,
    ["weapon ranged wand"] = 44,
    ["weapon totem"] = 45,
    ["weapon shield"] = 46,
    ["planar lesser"] = 47,
    ["planar greater"] = 48,
    ["consumable food"] = 49,
    ["consumable drink"] = 50,
    ["consumable potion"] = 51,
    ["consumable scroll"] = 52,
    ["consumable enchantment"] = 53,
    ["consumable"] = 54,
    ["container"] = 55,
    ["crafting recipe apothecary"] = 56,
    ["crafting recipe armorsmith"] = 57,
    ["crafting recipe artificer"] = 58,
    ["crafting recipe butchering"] = 59,
    ["crafting recipe foraging"] = 60,
    ["crafting recipe weaponsmith"] = 61,
    ["crafting recipe outfitter"] = 62,
    ["crafting recipe mining"] = 63,
    ["crafting recipe runecrafting"] = 64,
    ["crafting material metal"] = 65,
    ["crafting material gem"] = 66,
    ["crafting material wood"] = 67,
    ["crafting material plant"] = 68,
    ["crafting material hide"] = 69,
    ["crafting material meat"] = 70,
    ["crafting material cloth"] = 71,
    ["crafting material rune"] = 72,
    ["crafting material fish"] = 73,
    ["crafting material component"] = 74,
    ["crafting ingredient reagent"] = 75,
    ["crafting ingredient drop"] = 76,
    ["crafting ingredient rift"] = 77,
    ["crafting augment"] = 78,
    ["misc quest"] = 79,
    ["misc mount"] = 80,
    ["misc pet"] = 81,
    ["misc collectible"] = 82,
    ["misc other"] = 83,
    ["misc"] = 84,
}

local rarityOrder = {
    relic = 1,
    transcendant = 2,
    epic = 3,
    rare = 4,
    uncommon = 5,
    quest = 6,
    common = 7,
    sellable = 8,
}

local statsOrder = {
    damagePerSecond = 0,
    armor = 1,
    strength = 2,
    dexterity = 3,
    intelligence = 4,
    wisdom = 5,
    endurance = 6,
    hit = 7,
    dodge = 8,
    parry = 9,
    toughness = 10,
    powerAttack = 11,
    critAttack = 12,
    powerSpell = 13,
    critSpell = 14,
    resistAll = 15,
    resistDeath = 16,
    resistEarth = 17,
    resistFire = 18,
    resistLife = 19,
    resistWater = 20,
}

local callingOrder = {
    mage = 2,
    rogue = 4,
    cleric = 3,
    warrior = 1,
}

function UB.getCategoryOrder(category)
    return categoryOrder[category] or 500
end

function UB.getRarityOrder(rarity)
    return rarityOrder[rarity or "common"]
end

function UB.getStatsOrder(stats)
    return statsOrder[stats] or 100
end

function UB.getCallingOrder(stats)
    return callingOrder[stats] or 100
end