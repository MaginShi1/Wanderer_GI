local Wanderer_GI = RegisterMod("Wanderer", 1)
local game = Game()

local Ids = {
    Funny_Hat = Isaac.GetItemIdByName("Wanderer Hat"),                              -- Item id
    COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/Wanderer_Costume.anm2"),     -- Costume id
    VARIANT = Isaac.GetEntityVariantByName("WB WAND"),                              -- Tear id
    TEAR_POOF= Isaac.GetEntityVariantByName("Tear Poof"),                           -- Tear Poof 
}

-- Tear Bonuses
local tearBonusT = {
    MIN_FIRE_DELAY = 5,     -- Min Fire rate
    damageFH = 1.25,        -- Damage
    fdFH = 1.25,            -- Tear Rate
    rangerFH = 30           -- Range
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
                    if entity:IsDead() then
                        Wanderer_GI:SpawnTearPoof(entity.Position)
                    end
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

function Wanderer_GI:onPlayerInit(player)
    HasHat = player:HasCollectible(Ids.Funny_Hat)
end

function Wanderer_GI:Rotation(tear)
    local sprite = tear:GetSprite()
    if sprite ~= nil then
        sprite.Rotation = (tear.Velocity + Vector(0, tear.FallingSpeed)):GetAngleDegrees()
    end
end

-- TEAR POOF
function Wanderer_GI:SpawnTearPoof(position)
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, Ids.TEAR_POOF, 0, position, Vector(0, 0), nil)
    poof:GetSprite():Play("Poof", true)
    
    local entities = Isaac.GetRoomEntities()

    for _, entity in pairs(entities) do
        if entity:IsActiveEnemy() then
            local entityPosition = entity.Position
            
            -- knockback
            local direction = (position - entityPosition):Normalized()
            entity.Velocity = entity.Velocity + direction * 10 

            -- vacuum 
            entity.Position = entity.Position + direction * 5 
        end
    end
end


Wanderer_GI:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Wanderer_GI.onUpdate)
Wanderer_GI:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Wanderer_GI.cacheUpdate)
Wanderer_GI:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Wanderer_GI.OnUpdateEf)
Wanderer_GI:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Wanderer_GI.onPlayerInit)
Wanderer_GI:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, Wanderer_GI.Rotation)