local Wanderer_GI = RegisterMod("Wanderer", 1)
local game = Game()

local Ids = {
    Funny_Hat = Isaac.GetItemIdByName("Wanderer Hat"),                              -- Item id
    COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/Wanderer_Costume.anm2"),     -- Costume id
    VARIANT = Isaac.GetEntityVariantByName("WB WAND"),                              -- Tear id
    -- TEAR_POOF= Isaac.GetEntityVariantByName("Tear Poof"),                           -- Tear Poof 
    -- TEAR_POOF2 = Isaac.GetEntityVariantByName("Tear Poof2")                         -- Tear Poof 2
}

-- Tear Bonuses

local tearBonusT = {
    MIN_FIRE_DELAY = 5,     -- Min Fire rate
    damageFH = 1.25,        -- Damage
    fdFH = 1.25,            -- Tear Rate
    rangerFH = 30           -- Range
}

-- local tearTints = {}
-- local deadTears = {}
-- local clock = 0

function Wanderer_GI:cacheUpdate(player, cacheFlag)
    if player:HasCollectible(Ids.Funny_Hat) then
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + tearBonusT.damageFH
        end
        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            if player.MaxFireDelay > tearBonusT.MIN_FIRE_DELAY then
                local TearBonus = math.min(
                    tearBonusT.fdFH * player:GetCollectibleNum(Ids.Funny_Hat),
                    player.MaxFireDelay - tearBonusT.MIN_FIRE_DELAY
                )
                player.MaxFireDelay = player.MaxFireDelay - TearBonus
            end
        end
        if cacheFlag == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange + tearBonusT.rangerFH
        end
    end
end


function Wanderer_GI:OnUpdateEf(player)
    if not HasHat and player:HasCollectible(Ids.Funny_Hat) then
        player:AddNullCostume(Ids.COSTUME)
        HasHat = true
    end
    if HasHat then
        for _, entity in pairs(Isaac.GetRoomEntities()) do
            if entity.Type == EntityType.ENTITY_TEAR then
                local tearData = entity:GetData()
                if tearData.WINDBLADE == nil then
                    local tear = entity:ToTear()
                    tearData.WINDBLADE = 1
                    tear:ChangeVariant(Ids.VARIANT)
                    local scale = tear.BaseDamage / 11 + 0.4
                    tear:GetSprite().Scale = Vector(scale, scale)
                else
                    tearData.WINDBLADE = 0
                end
            end
        end
    end
end

-- function isVariant(variant, variants)
--     for i = 1, #variants do
--         if variant == variants[i] then
--             return true
--         end
--     end
--     return false  
-- end

-- function getPoofVariant(scale, height)
--     if scale > 1.8625 then
--         if height < -5 then
--             return Ids.TEAR_POOF2    -- Wall impact
--         else
--             return Ids.TEAR_POOF    -- Floor impact
--         end
--     elseif scale > 0.8 then
--         if height < -5 then
--             return EffectVariant.Ids.TEAR_POOF2    -- Wall impact
--         else
--             return EffectVariant.Ids.TEAR_POOF    -- Floor impact
--         end
--     elseif scale > 0.4 then
--         return EffectVariant.TEAR_POOF_SMALL
--     else
--         return EffectVariant.TEAR_POOF_VERYSMALL
--     end
-- end

-- function Wanderer_GI:tearsDeath()

--     clock = clock + 1
--     if clock > 600 then
--         clock = 0
--     end

--     local i = 1
--     while (i <= #deadTears) do
--         if deadTears[i][2] == 1 then
--             deadTears[i][2] = 2
--         elseif deadTears[i][2] == 2 then
--             local tear = deadTears[i][1]
--             if tear:IsDead() then
--                 TEAR_SCALE = tear:ToTear().Scale
--                 TEAR_HEIGHT = tear.Height
--                 TEAR_POS = tear.Position
--                 TEAR_VARIANT = tear.Variant
--                 TEAR_POINTER = GetPtrHash(tear)
--                 TEAR_COLOR = tearTints[TEAR_POINTER]

--                 local poofSize = getPoofVariant(TEAR_SCALE, TEAR_HEIGHT)

--                 local poof

--                 if isVariant(poofSize, {Ids.TEAR_POOF2, Ids.TEAR_POOF}) then
--                     poof:GetSprite().Rotation = math.random(4) * 90
--                 end
--             end
--             table.remove(deadTears, i)
--             i = i-1
--         end
--         i = i+1
--     end
-- end

-- TO KEEP

function Wanderer_GI:onUpdate(player)
    if game:GetFrameCount() == 1 then
        Wanderer_GI.HasHat = false
    end
end

-- To get tear rotation/direction
-- Maybe move somewhere later?

function Wanderer_GI:onPlayerInit(player)
    HasHat = player:HasCollectible(Ids.Funny_Hat)
end

function Wanderer_GI:Rotation(tear)
    tear.SpriteRotation = (tear.Velocity + Vector(0, tear.FallingSpeed)):GetAngleDegrees()
    -- if tear:IsDead() then
    --     table.insert(deadTears, {tear, 1, TEAR_COLOR})
    -- end
end

-- Call back area

Wanderer_GI:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Wanderer_GI.onUpdate)
Wanderer_GI:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Wanderer_GI.cacheUpdate)
Wanderer_GI:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Wanderer_GI.OnUpdateEf)
--Wanderer_GI:AddCallback(ModCallbacks.MC_POST_UPDATE, Wanderer_GI.tearsDeath)
Wanderer_GI:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Wanderer_GI.onPlayerInit)
Wanderer_GI:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, Wanderer_GI.Rotation)

-- Future ref for tear flags

TearFlags = {
    FLAG_NO_EFFECT = 0,
    FLAG_SPECTRAL = 1,
    FLAG_PIERCING = 1 << 1,
    FLAG_HOMING = 1 << 2,
    FLAG_SLOWING = 1 << 3,
    FLAG_POISONING = 1 << 4,
    FLAG_FREEZING = 1 << 5,
    FLAG_COAL = 1 << 6,
    FLAG_PARASITE = 1 << 7,
    FLAG_MAGIC_MIRROR = 1 << 8,
    FLAG_POLYPHEMUS = 1 << 9,
    FLAG_WIGGLE_WORM = 1 << 10,
    FLAG_UNK1 = 1 << 11, --No noticeable effect
    FLAG_IPECAC = 1 << 12,
    FLAG_CHARMING = 1 << 13,
    FLAG_CONFUSING = 1 << 14,
    FLAG_ENEMIES_DROP_HEARTS = 1 << 15,
    FLAG_TINY_PLANET = 1 << 16,
    FLAG_ANTI_GRAVITY = 1 << 17,
    FLAG_CRICKETS_BODY = 1 << 18,
    FLAG_RUBBER_CEMENT = 1 << 19,
    FLAG_FEAR = 1 << 20,
    FLAG_PROPTOSIS = 1 << 21,
    FLAG_FIRE = 1 << 22,
    FLAG_STRANGE_ATTRACTOR = 1 << 23,
    FLAG_UNK2 = 1 << 24, --Possible worm?
    FLAG_PULSE_WORM = 1 << 25,
    FLAG_RING_WORM = 1 << 26,
    FLAG_FLAT_WORM = 1 << 27,
    FLAG_UNK3 = 1 << 28, --Possible worm?
    FLAG_UNK4 = 1 << 29, --Possible worm?
    FLAG_UNK5 = 1 << 30, --Possible worm?
    FLAG_HOOK_WORM = 1 << 31,
    FLAG_GODHEAD = 1 << 32,
    FLAG_UNK6 = 1 << 33, --No noticeable effect
    FLAG_UNK7 = 1 << 34, --No noticeable effect
    FLAG_EXPLOSIVO = 1 << 35,
    FLAG_CONTINUUM = 1 << 36,
    FLAG_HOLY_LIGHT = 1 << 37,
    FLAG_KEEPER_HEAD = 1 << 38,
    FLAG_ENEMIES_DROP_BLACK_HEARTS = 1 << 39,
    FLAG_ENEMIES_DROP_BLACK_HEARTS2 = 1 << 40,
    FLAG_GODS_FLESH = 1 << 41,
    FLAG_UNK8 = 1 << 42, --No noticeable effect
    FLAG_TOXIC_LIQUID = 1 << 43,
    FLAG_OUROBOROS_WORM = 1 << 44,
    FLAG_GLAUCOMA = 1 << 45,
    FLAG_BOOGERS = 1 << 46,
    FLAG_PARASITOID = 1 << 47,
    FLAG_UNK9 = 1 << 48, --No noticeable effect
    FLAG_SPLIT = 1 << 49,
    FLAG_DEADSHOT = 1 << 50,
    FLAG_MIDAS = 1 << 51,
    FLAG_EUTHANASIA = 1 << 52,
    FLAG_JACOBS_LADDER = 1 << 53,
    FLAG_LITTLE_HORN = 1 << 54,
    FLAG_GHOST_PEPPER = 1 << 55
}