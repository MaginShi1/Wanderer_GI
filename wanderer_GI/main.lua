local Wanderer_GI = RegisterMod("Wanderer", 1)
local game = Game()

local Ids = {
    Funny_Hat = Isaac.GetItemIdByName("Wanderer Hat"),
    COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/Wanderer_Costume.anm2"),
    VARIANT = Isaac.GetEntityVariantByName("Wind_Blade_WAND")
}

local tearBonusT = {
    MIN_FIRE_DELAY = 5,
    damageFH = 1.25,
    fdFH = 1.25,
    rangerFH = 30
}

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

function Wanderer_GI:onPlayerInit(player)
    HasHat = player:HasCollectible(Ids.Funny_Hat)
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
                    local scale = tear.BaseDamage / 6 + 0.4
                    tear:GetSprite().Scale = Vector(scale, scale)
                end
            end
        end
    end
end

function Wanderer_GI:onUpdate(player)
    if game:GetFrameCount() == 1 then
        Wanderer_GI.HasHat = false
    end
end

Wanderer_GI:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Wanderer_GI.onUpdate)
Wanderer_GI:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Wanderer_GI.cacheUpdate)
Wanderer_GI:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Wanderer_GI.OnUpdateEf)
Wanderer_GI:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Wanderer_GI.onPlayerInit)

-- function Wanderer_GI:onDamage(entity, amt, flag, source, countdown)
--     if source.Type == EntityType.ENTITY_TEAR
--     and source.Variant == TearVariant.WINDBLAD
--     then
--         game -- later
--     end
-- end
