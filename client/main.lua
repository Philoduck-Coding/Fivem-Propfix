local function requestEntityControl(entity)
    if not NetworkGetEntityIsNetworked(entity) then
        return true
    end

    if NetworkHasControlOfEntity(entity) then
        return true
    end

    NetworkRequestControlOfEntity(entity)

    local timeoutAt = GetGameTimer() + 500
    while not NetworkHasControlOfEntity(entity) and GetGameTimer() < timeoutAt do
        NetworkRequestControlOfEntity(entity)
        Wait(0)
    end

    return NetworkHasControlOfEntity(entity)
end

local function deleteAttachedProps(playerPed)
    local removedCount = 0

    for _, object in ipairs(GetGamePool('CObject')) do
        if DoesEntityExist(object) and IsEntityAttachedToEntity(object, playerPed) then
            if requestEntityControl(object) then
                SetEntityAsMissionEntity(object, true, true)
                DetachEntity(object, true, true)
                DeleteObject(object)
                DeleteEntity(object)

                if not DoesEntityExist(object) then
                    removedCount = removedCount + 1
                end
            end
        end
    end

    return removedCount
end

RegisterCommand('propfix', function()
    local removedCount = deleteAttachedProps(PlayerPedId())

    if removedCount > 0 then
        ESX.ShowNotification(('Alle angehängten Props wurden entfernt. (%d)'):format(removedCount))
    else
        ESX.ShowNotification('Es wurden keine angehängten Props gefunden.')
    end
end, false)
