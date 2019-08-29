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
    UI.AddHeader("DPS")
    UI.AddToggle("Auto Pet Attack", "Auto cast pet attack on target", true)
    UI.AddToggle("Shadow Bolt", nil, true)
    UI.AddToggle("Corruption", nil, true)
    UI.AddToggle("Immolate", nil, true)
    UI.AddToggle("Curse of Agony", nil, true)
    UI.AddToggle("Fear Bonus Mobs", "Auto fear non target enemies when solo", false)
    UI.AddToggle("Drain Soul Snipe", "Try to auto snipe enemies with drain soul, useful for shard farming or Improved Drain Soul talent", false)
    UI.AddHeader("Defensive")
    UI.AddToggle("Healthstone", nil, true)
    UI.AddRange("Healthstone HP", nil, 0, 100, 1, 35)
    UI.AddToggle("Drain Life", nil, true)
    UI.AddRange("Drain Life HP", nil, 0, 100, 1, 25)
    UI.AddToggle("Health Funnel", "Activate Health Funnel, will only use if player HP above 60", true)
    UI.AddRange("Health Funnel HP", "Pet HP to cast Health Funnel", 0, 100, 1, 20)
    UI.AddHeader("Utility")
    UI.AddToggle("Auto Delete Shards", "Activate automatic deletion of shards from bags, set max below", true)
    UI.AddRange("Max Shards", "Control max number of shards in bag", 0, 20, 1, 10)
end