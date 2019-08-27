local DMW = DMW
local Warlock = DMW.Rotations.WARLOCK
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local Player, Pet, Buff, Debuff, Spell, Target, Talent, Item, GCD, CDs, HUD, Enemy40Y, Enemy40YC

local function Locals()
    Player = DMW.Player
    Pet = DMW.Player.Pet
    Buff = Player.Buffs
    Debuff = Player.Debuffs
    Spell = Player.Spells
    Talent = Player.Talents
    Item = Player.Items
    Target = Player.Target or false
    HUD = DMW.Settings.profile.HUD
    CDs = Player:CDs()
    Enemy40Y, Enemy40YC = Player:GetEnemies(40)
end

function Warlock.Rotation()
    Locals()
    if Target and Target.ValidEnemy then
        if Pet and not Pet.Dead and not UnitIsUnit(Target.Pointer, "pettarget") then
            PetAttack()
        end
        if not DMW.Player.Equipment[18] and not IsCurrentSpell(Spell.Attack.SpellID) then
            StartAttack()
        end
        if Debuff.Corruption:Refresh(Target) and (Target.TTD - Debuff.Corruption:Remain()) > 2 and Spell.Corruption:Cast(Target) then
            return true
        end
        if Debuff.Immolate:Refresh(Target) and (Target.TTD - Debuff.Immolate:Remain()) > 2 and Spell.Immolate:Cast(Target) then
            return true
        end
        if Debuff.Immolate:Exist(Target) and Debuff.Corruption:Exist(Target) and not IsCurrentSpell(Spell.Shoot.SpellID) and Spell.Shoot:Cast(Target) then
            return true
        end
    end
end