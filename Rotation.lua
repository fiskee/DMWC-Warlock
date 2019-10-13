local DMW = DMW
local Warlock = DMW.Rotations.WARLOCK
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local Player, Pet, Buff, Debuff, Spell, Target, Talent, Item, GCD, CDs, HUD, Enemy20Y, Enemy20YC, Enemy30Y, Enemy30YC, NewTarget, ShardCount, Curse
local WandTime = GetTime()
local PetAttackTime = GetTime()
local ItemUsage = GetTime()

local function GetCurse()
    local CurseSetting = Setting("Curse")
    if CurseSetting ~= 1 then
        if CurseSetting == 2 then
            return "CurseOfAgony"
        elseif CurseSetting == 3 then
            return "CurseOfShadow"
        elseif CurseSetting == 4 then
            return "CurseOfTheElements"
        elseif CurseSetting == 5 then
            return "CurseOfRecklessness"
        elseif CurseSetting == 6 then
            return "CurseOfWeakness"
        elseif CurseSetting == 7 then
            return "CurseOfTongues"
        elseif CurseSetting == 8 then
            return "CurseOfIdiocy"
        elseif CurseSetting == 9 then
            return "CurseOfDoom"
        end
    elseif Target and Target.Player then
        return "CurseOfAgony"
    end
    return nil
end

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
    Curse = GetCurse()
end

local function Shards(Max)
    local Count = 0
    for Bag = 0, 4, 1 do
        for Slot = 1, GetContainerNumSlots(Bag), 1 do
            local ItemID = GetContainerItemID(Bag, Slot)
            if ItemID and ItemID == 6265 then
                if Count >= Max then
                    PickupContainerItem(Bag, Slot)
                    DeleteCursorItem()
                else
                    Count = Count + 1
                end
            end
        end
    end
    return Count
end

local function Wand()
    if not Player.Moving and not DMW.Helpers.Queue.Spell and not IsAutoRepeatSpell(Spell.Shoot.SpellName) and (DMW.Time - WandTime) > 0.7 and (Target.Distance > 1 or not Setting("Auto Attack In Melee")) and
    (Player.PowerPct < 10 or Spell.ShadowBolt:CD() > 2 or ((not Curse or not Spell[Curse]:Known() or Debuff[Curse]:Exist(Target) or Target.TTD < 10 or Target.CreatureType == "Totem") and 
    (not Setting("Immolate") or not Spell.Immolate:Known() or Debuff.Immolate:Exist(Target) or Target.TTD < 10 or Target.CreatureType == "Totem") and 
    (not Setting("Corruption") or not Spell.Corruption:Known() or Debuff.Corruption:Exist(Target) or Target.TTD < 7 or Target.CreatureType == "Totem") and
    (not Setting("Siphon Life") or not Spell.SiphonLife:Known() or Debuff.SiphonLife:Exist(Target) or Target.TTD < 10 or Target.CreatureType == "Totem") and
    (not Setting("Drain Life Filler") or not Spell.DrainLife:Known() or Player.HP > Setting("Drain Life Filler HP") or Target.CreatureType == "Mechanical" or (not Target.Player and Target.TTD < 3) or Target.Distance > Spell.DrainLife.MaxRange)))
    and Spell.Shoot:Cast(Target) then
        WandTime = DMW.Time
        return true
    end
end

local function Defensive()
    if Setting("Healthstone") and Player.HP < Setting("Healthstone HP") and (DMW.Time - ItemUsage) > 0.2 and (Item.MajorHealthstone:Use(Player) or Item.GreaterHealthstone:Use(Player) or Item.Healthstone:Use(Player) or Item.LesserHealthstone:Use(Player) or Item.MinorHealthstone:Use(Player)) then
        ItemUsage = DMW.Time
        return true
    end
    if not Player.Casting and not Player.Moving and Setting("Drain Life") and Player.HP < Setting("Drain Life HP") and Target.CreatureType ~= "Mechanical" and Spell.DrainLife:Cast(Target) then
        return true
    end
    if Setting("Luffa") and Item.Luffa:Equipped() and (DMW.Time - ItemUsage) > 0.2 and Player:Dispel(Item.Luffa) and Item.Luffa:Use(Player) then
        ItemUsage = DMW.Time
        return true
    end
    if not Player.Casting and not Player.Moving and Setting("Health Funnel") and Pet and not Pet.Dead and Pet.HP < Setting("Health Funnel HP") and Target.TTD > 2 and Player.HP > 60 and Spell.HealthFunnel:Cast(Pet) then
        return true
    end
end

local function DemonBuff()
    if Spell.DemonArmor:Known() then
        if Buff.DemonArmor:Remain() < 300 and Spell.DemonArmor:Cast(Player) then
            return true
        end
    elseif Spell.DemonSkin:Known() then
        if Buff.DemonSkin:Remain() < 300 and Spell.DemonSkin:Cast(Player) then
            return true
        end
    end
end

local function CreateHealthstone()
    if Spell.CreateHealthstoneMajor:Known() then
        if not Spell.CreateHealthstoneMajor:LastCast() and not Item.MajorHealthstone:InBag() and Spell.CreateHealthstoneMajor:Cast(Player) then
            return true
        end
    elseif Spell.CreateHealthstoneGreater:Known() then
        if not Spell.CreateHealthstoneGreater:LastCast() and not Item.GreaterHealthstone:InBag() and Spell.CreateHealthstoneGreater:Cast(Player) then
            return true
        end
    elseif Spell.CreateHealthstone:Known() then
        if not Spell.CreateHealthstone:LastCast() and not Item.Healthstone:InBag() and Spell.CreateHealthstone:Cast(Player) then
            return true
        end
    elseif Spell.CreateHealthstoneLesser:Known() then
        if not Spell.CreateHealthstoneLesser:LastCast() and not Item.LesserHealthstone:InBag() and Spell.CreateHealthstoneLesser:Cast(Player) then
            return true
        end
    elseif Spell.CreateHealthstoneMinor:Known() then
        if not Spell.CreateHealthstoneMinor:LastCast() and not Item.MinorHealthstone:InBag() and Spell.CreateHealthstoneMinor:Cast(Player) then
            return true
        end
    end
end

local function CreateSoulstone()
    if Spell.CreateSoulstoneMajor:Known() then
        if not Spell.CreateSoulstoneMajor:LastCast() and not Item.MajorSoulstone:InBag() and Spell.CreateSoulstoneMajor:Cast(Player) then
            return true
        end
    elseif Spell.CreateSoulstoneGreater:Known() then
        if not Spell.CreateSoulstoneGreater:LastCast() and not Item.GreaterSoulstone:InBag() and Spell.CreateSoulstoneGreater:Cast(Player) then
            return true
        end
    elseif Spell.CreateSoulstone:Known() then
        if not Spell.CreateSoulstone:LastCast() and not Item.Soulstone:InBag() and Spell.CreateSoulstone:Cast(Player) then
            return true
        end
    elseif Spell.CreateSoulstoneLesser:Known() then
        if not Spell.CreateSoulstoneLesser:LastCast() and not Item.LesserSoulstone:InBag() and Spell.CreateSoulstoneLesser:Cast(Player) then
            return true
        end
    elseif Spell.CreateSoulstoneMinor:Known() then
        if not Spell.CreateSoulstoneMinor:LastCast() and not Item.MinorSoulstone:InBag() and Spell.CreateSoulstoneMinor:Cast(Player) then
            return true
        end
    end
end

function Warlock.Rotation()
    Locals()
    if not Player.Casting then
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
        ShardCount = Shards(Setting("Max Shards"))
        if Setting("Auto Target Quest Units") then
            if Player:AutoTargetQuest(30, true) then
                return true
            end
        end
        if Player.Combat and Setting("Auto Target") then
            if Player:AutoTarget(30, true) then
                return true
            end
        end
        if not Player.Combat then
            if Setting("Auto Buff") and DemonBuff() then
                return true
            end
            if not Player.Moving and Setting("Create Healthstone") and CreateHealthstone() then
                return true
            end
            if not Player.Moving and Setting("Create Soulstone") and CreateSoulstone() then
                return true
            end
            if Setting("Soulstone Player") and not Player.Moving and Player.Instance == "none" and (DMW.Time - ItemUsage) > 0.2 and not Buff.SoulstoneResurrection:Exist(Player) and (Item.MajorSoulstone:Use(Player) or Item.GreaterSoulstone:Use(Player) or Item.Soulstone:Use(Player) or Item.LesserSoulstone:Use(Player) or Item.MinorSoulstone:Use(Player)) then
                ItemUsage = DMW.Time
                return true
            end
            if Setting("Life Tap OOC") and Setting("Life Tap") and Player.HP >= Setting("Life Tap HP") and Player.PowerPct <= Setting("Life Tap Mana") and Spell.LifeTap:Cast(Player) then
                return true
            end
            if Pet and not Pet.Dead and Setting("Dark Pact OOC") and Setting("Dark Pact") and Player.PowerPct <= Setting("Dark Pact Mana") and Pet:PowerPct() > Setting("Dark Pact Pet Mana") and Spell.DarkPact:Cast(Player) then
                return true
            end
        end
    end
    if Target and Target.ValidEnemy and Target.Distance < 40 then
        if Player.Casting and Player.Casting == Spell.Fear.SpellName and NewTarget then
            TargetUnit(NewTarget.Pointer)
            NewTarget = false
        end
        if Defensive() then
            return true
        end
        if not Player.Casting then
            if Target.Player and (Target.Class == "PRIEST" or Target.Class == "WARLOCK") and Setting("Shadow Ward") and Spell.ShadowWard:Cast(Player) then
                return true
            end 
            --Force refresh on fear
            if Setting("Corruption") and Debuff.Fear:Exist(Target) and (Spell.Fear:LastCast() or Spell.Fear:LastCast(2)) and Debuff.Corruption:Remain(Target) < 5 and (not Player.Moving or Talent.ImprovedCorruption.Rank == 5) and Spell.Corruption:Cast(Target) then
                return true
            end
        end
        if not Player.Moving and not Target.Player and Setting("Drain Soul Snipe") and (not Setting("Stop DS At Max Shards") or ShardCount < Setting("Max Shards")) and not Debuff.Shadowburn:Exist(Target) then
            for _, Unit in ipairs(Enemy30Y) do
                if Unit.Facing and not Unit.Player and (Unit.TTD < 3 or Unit.HP < 8) and not Unit:IsBoss() and not UnitIsTapDenied(Unit.Pointer) and Spell.DrainSoul:CD() < 0.2 then
                    if (not Player.Casting or (Player.Casting ~= Spell.DrainSoul.SpellName and Player.Casting ~= Spell.Hellfire.SpellName and Player.Casting ~= Spell.RainOfFire.SpellName)) and Spell.DrainSoul:Cast(Unit) then
                        WandTime = DMW.Time
                        return true
                    end
                end
            end
        end
        if Setting("Shadowburn") and ShardCount >= Setting("Max Shards") then
            for _, Unit in ipairs(Enemy30Y) do
                if Unit.Facing and (Unit.TTD < Setting("Shadowburn TTD") or Unit.HP < Setting("Shadowburn HP")) and not Unit:IsBoss() and not UnitIsTapDenied(Unit.Pointer) and Spell.Shadowburn:Cast(Unit) then
                    return true
                end
            end
        end
        if not Player.Casting then
            if not Player.Moving and Setting("Fear Bonus Mobs") and Spell.Fear:IsReady() and Debuff.Fear:Count() == 0 and (not Spell.Fear:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 0.7)) then
                local CreatureType = Target.CreatureType
                if Enemy20YC > 1 and not Player.InGroup and not (CreatureType == "Undead" or CreatureType == "Mechanical" or CreatureType == "Totem") and Target.TTD > 3 and not Target:IsBoss() and
                (not Setting("Immolate") or not Spell.Immolate:Known() or Debuff.Immolate:Exist(Target) or Target.TTD < 10) and 
                (not Setting("Corruption") or not Spell.Corruption:Known() or Debuff.Corruption:Exist(Target) or Target.TTD < 7) and
                (not Setting("Siphon Life") or not Spell.SiphonLife:Known() or Debuff.SiphonLife:Exist(Target) or Target.TTD < 10) and 
                (not Curse or not Spell[Curse]:Known() or Debuff[Curse]:Exist(Target) or Target.TTD < 10 ) then                    
                    for i, Unit in ipairs(Enemy20Y) do
                        if i > 1 and Unit.TTD > 3 and Spell.Fear:Cast(Target) then
                            NewTarget = Unit
                            return true
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
                if (not Spell.Corruption:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 0.7) or not UnitIsUnit(Spell.Corruption.LastBotTarget, Target.Pointer)) and Target.CreatureType ~= "Totem" and Target.Facing and not Debuff.Corruption:Exist(Target) and Target.TTD > 7 and Spell.Corruption:Cast(Target) then
                    return true
                end
                if Setting("Cycle Corruption") and Debuff.Corruption:Count() < Setting("Multidot Limit") then
                    for _, Unit in ipairs(Enemy30Y) do
                        if (not Spell.Corruption:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 0.7) or not UnitIsUnit(Spell.Corruption.LastBotTarget, Unit.Pointer)) and Unit.CreatureType ~= "Totem" and Unit.Facing and not Debuff.Corruption:Exist(Unit) and Unit.TTD > 7 and Spell.Corruption:Cast(Unit) then
                            return true
                        end
                    end
                end
            end
            --SL
            if Setting("Siphon Life") then
                if not Debuff.SiphonLife:Exist(Target) and Target.TTD > 10 and Target.CreatureType ~= "Totem" and Spell.SiphonLife:Cast(Target) then
                    return true
                end
                if Setting("Cycle Siphon Life") and Debuff.SiphonLife:Count() < Setting("Multidot Limit") then
                    for _, Unit in ipairs(Enemy30Y) do
                        if not Debuff.SiphonLife:Exist(Unit) and Unit.TTD > 10 and Unit.CreatureType ~= "Totem" and Spell.SiphonLife:Cast(Unit) then
                            return true
                        end
                    end
                end
            end
            --AC
            if CDs and Curse and Target.TTD > 15 and Target.CreatureType ~= "Totem" and Target.Distance <= Spell[Curse].MaxRange and Spell.AmplifyCurse:Cast(Player) then
                return true
            end
            --Curse
            if Curse then
                if not Debuff[Curse]:Exist(Target) and Target.TTD > 10 and Target.CreatureType ~= "Totem" and Spell[Curse]:Cast(Target) then
                    return true
                end
                if Setting("Cycle Curse") and Debuff[Curse]:Count() < Setting("Multidot Limit") then
                    for _, Unit in ipairs(Enemy30Y) do
                        if not Debuff[Curse]:Exist(Unit) and Unit.TTD > 10 and Unit.CreatureType ~= "Totem" and Spell[Curse]:Cast(Unit) then
                            return true
                        end
                    end
                end
            end
            --Immolate
            if Setting("Immolate") and not Player.Moving then
                if (not Spell.Immolate:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 0.7) or not UnitIsUnit(Spell.Immolate.LastBotTarget, Target.Pointer)) and Target.CreatureType ~= "Totem" and Target.Facing and not Debuff.Immolate:Exist(Target) and Target.TTD > 10 and Spell.Immolate:Cast(Target) then
                    return true
                end
                if Setting("Cycle Immolate") and Debuff.Immolate:Count() < Setting("Multidot Limit") then
                    for _, Unit in ipairs(Enemy30Y) do
                        if (not Spell.Immolate:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 0.7) or not UnitIsUnit(Spell.Immolate.LastBotTarget, Unit.Pointer)) and Unit.CreatureType ~= "Totem" and Unit.Facing and not Debuff.Immolate:Exist(Unit) and Unit.TTD > 10 and Spell.Immolate:Cast(Unit) then
                            return true
                        end
                    end
                end
            end
            if Setting("Life Tap") and Player.HP >= Setting("Life Tap HP") and (not Setting("Safe Life Tap") or (not Player:IsTanking() and not Debuff.LivingBomb:Exist(Player))) and Player.PowerPct <= Setting("Life Tap Mana") and not Spell.DarkPact:LastCast() and Spell.LifeTap:Cast(Player) then
                return true
            end
            if Pet and not Pet.Dead and Setting("Dark Pact") and Player.PowerPct <= Setting("Dark Pact Mana") and Pet:PowerPct() > Setting("Dark Pact Pet Mana") and not Spell.DarkPact:LastCast() and not Spell.LifeTap:LastCast() and Spell.DarkPact:Cast(Pet) then
                return true
            end
            if Setting("Shadow Bolt Mode") == 2 and Target.Facing and not Player.Moving and Player.PowerPct > Setting("Shadow Bolt Mana") and (Target.TTD > Spell.ShadowBolt:CastTime() or (Target.Distance > 5 and not DMW.Player.Equipment[18])) and Spell.ShadowBolt:Cast(Target) then
                return true
            end
            if Setting("Shadow Bolt Mode") == 3 and Target.Facing and Player.PowerPct > Setting("Shadow Bolt Mana") and Buff.ShadowTrance:Exist(Player) and Spell.ShadowBolt:Cast(Target) then
                return true
            end
            if Setting("Drain Life Filler") and not Player.Moving and Player.HP <= Setting("Drain Life Filler HP") and Target.CreatureType ~= "Mechanical" and (Target.Player or Target.TTD > 3) and Spell.DrainLife:Cast(Target) then
                return true
            end
            if DMW.Player.Equipment[18] and Target.Facing and Wand() then
                return true
            end
        end
    end
end
