local DMW = DMW
DMW.Rotations.WARLOCK = {}
local Warlock = DMW.Rotations.WARLOCK
local UI = DMW.UI

function Warlock.Settings()
    UI.HUD.Options = {
        [1] = {
            Test = {
                [1] = {Text = "HUD Test |cFF00FF00On", Tooltip = ""},
                [2] = {Text = "HUD Test |cFFFFFF00Sort Of On", Tooltip = ""},
                [3] = {Text = "HUD Test |cffff0000Disabled", Tooltip = ""}
            }
        }
    }

    UI.AddHeader("This Is A Header")
    UI.AddDropdown("This Is A Dropdown", nil, {"Yay", "Nay"}, 1)
    UI.AddToggle("This Is A Toggle", "This is a tooltip", true)
    UI.AddRange("This Is A Range", "One more tooltip", 0, 100, 1, 70)
end