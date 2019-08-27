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
    if not Player.Combat and not Player.Moving and (not Pet or Pet.Dead) and Setting("Pet") ~= 1 then
        if Setting("Pet") == 2 and Spell.SummonImp:Cast(Player) then
            return true
        elseif Setting("Pet") == 3 and Spell.Voidwalker:Cast(Player) then--TODO: Add spells for these
        elseif Setting("Pet") == 4 and Spell.Succubus:Cast(Player) then
        elseif Setting("Pet") == 5 and Spell.Felhunter:Cast(Player) then
        end
    end
    if Target and Target.ValidEnemy and Target.Distance < 40 then
        if Setting("Auto Pet Attack") and Pet and not Pet.Dead and not UnitIsUnit(Target.Pointer, "pettarget") then
            PetAttack()
        end
        if not DMW.Player.Equipment[18] and not IsCurrentSpell(Spell.Attack.SpellID) then
            StartAttack()
        end
        if Setting("Corruption") and not Player.Moving and (not Spell.Corruption:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 0.7) or not UnitIsUnit(Spell.Corruption.LastBotTarget, Target.Pointer)) and not Debuff.Corruption:Exist(Target) and Target.TTD > 5 and Spell.Corruption:Cast(Target) then
            return true
        end
        if Setting("Immolate") and not Player.Moving and (not Spell.Immolate:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 0.7) or not UnitIsUnit(Spell.Immolate.LastBotTarget, Target.Pointer)) and not Debuff.Immolate:Exist(Target) and Target.TTD > 5 and Spell.Immolate:Cast(Target) then
            return true
        end
        if not Player.Moving and Debuff.Immolate:Exist(Target) and Debuff.Corruption:Exist(Target) and not IsCurrentSpell(Spell.Shoot.SpellID) and Spell.Shoot:Cast(Target) then
            return true
        end
        if Setting("Shadow Bolt") and not Player.Moving and Player.PowerPct > 35 and (Target.TTD > Spell.ShadowBolt:CastTime() or (Target.Distance > 5 and not DMW.Player.Equipment[18])) and Spell.ShadowBolt:Cast(Target) then
            return true
        end
    end
end
