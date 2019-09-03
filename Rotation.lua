local DMW = DMW
local Warlock = DMW.Rotations.WARLOCK
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local Player, Pet, Buff, Debuff, Spell, Target, Talent, Item, GCD, CDs, HUD, Enemy20Y, Enemy20YC, Enemy30Y, Enemy30YC
local WandTime = GetTime()
local PetAttackTime = GetTime()

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
    Enemy20Y, Enemy20YC = Player:GetEnemies(20)
    Enemy30Y, Enemy30YC = Player:GetEnemies(30)
end

local function DeleteShards(Max)
    local Count = 1
    for Bag = 0, 4, 1 do
        for Slot = 1, GetContainerNumSlots(Bag), 1 do
            local ItemID = GetContainerItemID(Bag, Slot)
            if ItemID and ItemID == 6265 then
                if Count > Max then
                    PickupContainerItem(Bag, Slot)
                    DeleteCursorItem()
                end
                Count = Count + 1
            end
        end
    end
end

local function Wand()
    if not Player.Moving and not IsAutoRepeatSpell(Spell.Shoot.SpellName) and (DMW.Time - WandTime) > 0.7 and (Target.Distance > 1 or not Setting("Auto Attack In Melee")) and
    (Player.PowerPct < 10 or ((not Setting("Curse of Agony") or Debuff.CurseOfAgony:Exist(Target) or Target.TTD < 10) and 
    (not Setting("Immolate") or Debuff.Immolate:Exist(Target) or Target.TTD < 10) and 
    (not Setting("Corruption") or Debuff.Corruption:Exist(Target) or Target.TTD < 7))) and Spell.Shoot:Cast(Target) then
        WandTime = DMW.Time
        return true
    end
end

local function Defensive()
    if Setting("Healthstone") and Player.HP < Setting("Healthstone HP") and Item.MinorHealthstone:Use(Player) then
        return true
    end
    if Setting("Drain Life") and Player.HP < Setting("Drain Life HP") and Spell.DrainLife:Cast(Target) and not (Target.CreatureType == "Mechanical" or Target.CreatureType == "Elemental") then
        return true
    end
    if Setting("Health Funnel") and Pet and not Pet.Dead and Pet.HP < Setting("Health Funnel HP") and Target.TTD > 2 and Player.HP > 60 and Spell.HealthFunnel:Cast(Pet) then
        return true
    end
end

function Warlock.Rotation()
    Locals()
    if not Player.Combat and not Player.Moving and (not Pet or Pet.Dead) and Setting("Pet") ~= 1 then
        if Setting("Pet") == 2 and not Spell.SummonImp:LastCast() and Spell.SummonImp:Cast(Player) then
            return true
        elseif Setting("Pet") == 3 and not Spell.SummonVoidwalker:LastCast() and Spell.SummonVoidwalker:Cast(Player) then
            return true
        elseif Setting("Pet") == 4 and not Spell.SummonSuccubus:LastCast() and Spell.SummonSuccubus:Cast(Player) then
            return true
        elseif Setting("Pet") == 5 and not Spell.SummonFelhunter:LastCast() and Spell.SummonFelhunter:Cast(Player) then
            return true
        end
    end   
    if Setting("Auto Delete Shards") then
        DeleteShards(Setting("Max Shards"))
    end
    if Setting("Auto Target Quest Units") then
        if Player:AutoTargetQuest(30, true) then
            return true
        end
    end
    if Target and Target.ValidEnemy and Target.Distance < 40 then
        if Defensive() then
            return true
        end
        if not Player.Moving and Setting("Drain Soul Snipe") then
            for _, Unit in ipairs(Enemy30Y) do
                if Unit.Facing and (Unit.TTD < 3 or Unit.HP < 12) and not Unit:IsBoss() and not UnitIsTapDenied(Unit.Pointer) and Spell.DrainSoul:CD() < 0.2 then
                    if IsAutoRepeatSpell(Spell.Shoot.SpellName) then
                        MoveForwardStart()
                        MoveForwardStop()
                        WandTime = DMW.Time
                    end
                    if Spell.DrainSoul:Cast(Target) then
                        return true
                    end
                end
            end
        end
        if not Player.Moving and Setting("Fear Bonus Mobs") and Debuff.Fear:Count() == 0 and (not Spell.Fear:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 0.7)) then
            if Enemy20YC > 1 and not Player.InGroup then
                local CreatureType
                for i, Unit in ipairs(Enemy20Y) do
                    if i > 1 then
                        CreatureType = Unit.CreatureType
                        if Unit.TTD > 3 and not (CreatureType == "Undead" or CreatureType == "Mechanical" or CreatureType == "Totem") and not Unit:IsBoss() and Spell.Fear:Cast(Unit) then
                            return true
                        end
                    end
                end
            end
        end
        if Setting("Auto Pet Attack") and Pet and not Pet.Dead and not UnitIsUnit(Target.Pointer, "pettarget") and DMW.Time > (PetAttackTime + 1) then
            PetAttackTime = DMW.Time
            PetAttack()
        end
        if (not DMW.Player.Equipment[18] or (Target.Distance <= 1 and Setting("Auto Attack In Melee"))) and not IsCurrentSpell(Spell.Attack.SpellID) then
            StartAttack()
        end
        --Corruption
        if Setting("Corruption") and (not Player.Moving or Talent.ImprovedCorruption.Rank == 5) then
            if (not Spell.Corruption:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 0.7) or not UnitIsUnit(Spell.Corruption.LastBotTarget, Target.Pointer)) and Target.Facing and not Debuff.Corruption:Exist(Target) and Target.TTD > 7 and Spell.Corruption:Cast(Target) then
                return true
            end
            if Setting("Cycle Corruption") then
                for _, Unit in ipairs(Enemy30Y) do
                    if (not Spell.Corruption:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 0.7) or not UnitIsUnit(Spell.Corruption.LastBotTarget, Unit.Pointer)) and Unit.Facing and not Debuff.Corruption:Exist(Unit) and Unit.TTD > 7 and Spell.Corruption:Cast(Unit) then
                        return true
                    end
                end
            end
        end
        --CoA
        if Setting("Curse of Agony") then
            if not Debuff.CurseOfAgony:Exist(Target) and Target.TTD > 10 and Spell.CurseOfAgony:Cast(Target) then
                return true
            end
            if Setting("Cycle Curse of Agony") then
                for _, Unit in ipairs(Enemy30Y) do
                    if not Debuff.CurseOfAgony:Exist(Unit) and Unit.TTD > 10 and Spell.CurseOfAgony:Cast(Unit) then
                        return true
                    end
                end
            end
        end
        --Immolate
        if Setting("Immolate") and not Player.Moving then
            if (not Spell.Immolate:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 0.7) or not UnitIsUnit(Spell.Immolate.LastBotTarget, Target.Pointer)) and Target.Facing and not Debuff.Immolate:Exist(Target) and Target.TTD > 10 and Spell.Immolate:Cast(Target) then
                return true
            end
            if Setting("Cycle Immolate") then
                for _, Unit in ipairs(Enemy30Y) do
                    if (not Spell.Immolate:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 0.7) or not UnitIsUnit(Spell.Immolate.LastBotTarget, Unit.Pointer)) and Unit.Facing and not Debuff.Immolate:Exist(Unit) and Unit.TTD > 10 and Spell.Immolate:Cast(Unit) then
                        return true
                    end
                end
            end
        end
        if Setting("Life Tap") and Player.HP > Setting("Life Tap HP") and Player.PowerPct < 20 and Spell.LifeTap:Cast(Player) then
            return true
        end
        if Setting("Shadow Bolt") and Target.Facing and not Player.Moving and Player.PowerPct > 35 and (Target.TTD > Spell.ShadowBolt:CastTime() or (Target.Distance > 5 and not DMW.Player.Equipment[18])) and Spell.ShadowBolt:Cast(Target) then
            return true
        end
        if DMW.Player.Equipment[18] and Target.Facing then
            Wand()
        end
    end
end
