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
        if Setting("Pet") == 2 and not Spell.SummonImp:LastCast() and Spell.SummonImp:Cast(Player) then
            return true
        elseif Setting("Pet") == 3 and not Spell.Voidwalker:LastCast() and Spell.Voidwalker:Cast(Player) then
            return true
        elseif Setting("Pet") == 4 and not Spell.Succubus:LastCast() and Spell.Succubus:Cast(Player) then
            return true
        elseif Setting("Pet") == 5 and not Spell.Felhunter:LastCast() and Spell.Felhunter:Cast(Player) then
            return true
        end
    end
    if Target and Target.ValidEnemy and Target.Distance < 40 then
        if not Player.Moving and Setting("Fear Bonus Mobs") then
            if Enemy40YC > 1 and not Player.InGroup then
                for i, Unit in ipairs(Enemy40Y) do
                    if i > 1 then
                        if Unit.TTD > 3 and not Debuff.Fear:Exist(Unit) and (not Spell.Fear:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 0.7) or not UnitIsUnit(Spell.Immolate.LastBotTarget, Unit.Pointer)) and Spell.Fear:Cast(Unit) then
                            return true
                        end
                    end
                end
            end
        end
        if Setting("Auto Pet Attack") and Pet and not Pet.Dead and not UnitIsUnit(Target.Pointer, "pettarget") then
            PetAttack()
        end
        if not DMW.Player.Equipment[18] and not IsCurrentSpell(Spell.Attack.SpellID) then
            StartAttack()
        end
        if Setting("Immolate") and not Player.Moving and (not Spell.Immolate:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 0.7) or not UnitIsUnit(Spell.Immolate.LastBotTarget, Target.Pointer)) and not Debuff.Immolate:Exist(Target) and Target.TTD > 5 and Spell.Immolate:Cast(Target) then
            return true
        end
        if Setting("Corruption") and not Player.Moving and (not Spell.Corruption:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 0.7) or not UnitIsUnit(Spell.Corruption.LastBotTarget, Target.Pointer)) and not Debuff.Corruption:Exist(Target) and Target.TTD > 5 and Spell.Corruption:Cast(Target) then
            return true
        end
        if Setting("Curse of Agony") and not Debuff.CurseOfAgony:Exist(Target) and Target.TTD > 4 and Spell.CurseOfAgony:Cast(Target) then
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
