local DMW = DMW
DMW.Rotations.WARLOCK = {}
local Warlock = DMW.Rotations.WARLOCK
local UI = DMW.UI

function Warlock.Settings()
    -- UI.HUD.Options = {
    --     [1] = {
    --         Test = {
    --             [1] = {Text = "HUD Test |cFF00FF00On", Tooltip = ""},
    --             [2] = {Text = "HUD Test |cFFFFFF00Sort Of On", Tooltip = ""},
    --             [3] = {Text = "HUD Test |cffff0000Disabled", Tooltip = ""}
    --         }
    --     }
    -- }
    UI.AddHeader("General")
    UI.AddDropdown("Pet", nil, {"Disabled", "Imp", "Voidwalker", "Succubus", "Felhunter"}, 1)
    UI.AddToggle("Life Tap", nil, true)
    UI.AddRange("Life Tap Mana", "Mana pct to use Life Tap", 0, 100, 1, 60)
    UI.AddRange("Life Tap HP", "Minimum player hp to use Life Tap", 0, 100, 1, 80)
    UI.AddToggle("Auto Target Quest Units", nil, false)
    UI.AddHeader("DPS")
    UI.AddToggle("Auto Pet Attack", "Auto cast pet attack on target", true)
    UI.AddToggle("Auto Attack In Melee", "Will use normal attack over wand if target is in melee range", false)
    UI.AddDropdown("Shadowbolt Mode", "Select Shadowbolt mode", {"Disabled", "Always", "Only Nightfall"}, 2)
    UI.AddRange("Shadowbolt Mana", "Minimum mana pct to cast Shadowbolt", 0, 100, 1, 35)
    UI.AddToggle("Corruption", nil, true)
    UI.AddToggle("Cycle Corruption", "Spread Corruption to all enemies", false)
    UI.AddToggle("Immolate", nil, true)
    UI.AddToggle("Cycle Immolate", "Spread Immolate to all enemies", false)
    UI.AddToggle("Curse of Agony", nil, true)
    UI.AddToggle("Cycle Curse of Agony", "Spread Curse of Agony to all enemies", false)
    UI.AddToggle("Siphon Life", nil, true)
    UI.AddToggle("Cycle Siphon Life", "Spread Siphon Life to all enemies", false)
    UI.AddToggle("Drain Life Filler", "Use Drain Life as filler over wanding", false)
    UI.AddRange("Drain Life Filler HP", "Player HP to start using drain life over wanding", 0, 100, 1, 80)
    UI.AddHeader("Defensive")
    UI.AddToggle("Healthstone", nil, true)
    UI.AddRange("Healthstone HP", nil, 0, 100, 1, 35)
    UI.AddToggle("Drain Life", nil, true)
    UI.AddRange("Drain Life HP", nil, 0, 100, 1, 25)
    UI.AddToggle("Health Funnel", "Activate Health Funnel, will only use if player HP above 60", false)
    UI.AddRange("Health Funnel HP", "Pet HP to cast Health Funnel", 0, 100, 1, 20)
    UI.AddHeader("Utility")
    UI.AddToggle("Fear Bonus Mobs", "Auto fear non target enemies when solo", false)
    UI.AddToggle("Drain Soul Snipe", "Try to auto snipe enemies with drain soul, useful for shard farming or Improved Drain Soul talent", false)
    UI.AddToggle("Auto Delete Shards", "Activate automatic deletion of shards from bags, set max below", false)
    UI.AddRange("Max Shards", "Control max number of shards in bag", 0, 20, 1, 4)
end