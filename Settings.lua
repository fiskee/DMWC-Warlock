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
    UI.AddToggle("Fear Bonus Mobs", nil, true)
end