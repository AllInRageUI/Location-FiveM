local hasAlreadyEnteredMarker, currentActionData = false, {}
local lastZone, currentAction, currentActionMsg, vehiclePart
ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

local InMenu = false
RMenu.Add("Localtion", "Main", RageUI.CreateMenu("Location", " ", nil , 160))
RMenu:Get("Localtion", "Main").Closed = function()
    RageUI.CloseAll()
    InMenu = false
end;
RMenu:Get("Localtion", "Main").onIndexChange = function(Index)
end

function OpenVehicleLocationMenu(object)
    if InMenu then RageUI.CloseAll() InMenu = false return end
    InMenu = true
    local elements = {}

    for k,v in ipairs(Config.Locations.Vehicles) do
        for i=1, #v.Models, 1 do
            table.insert(elements, {
                label = v.Models[i].label,
                name = v.Models[i].label,
                model = v.Models[i].model,
                price = v.Models[i].price
            })
        end
    end

    RageUI.Visible(RMenu:Get("Localtion", "Main"), not RageUI.Visible(RMenu:Get("Localtion", "Main")))
    Citizen.CreateThread(function()
        while InMenu do
            Wait(1)
            RageUI.IsVisible(RMenu:Get("Localtion", "Main"), function()
                for k,v in pairs(elements) do
                    RageUI.Button(v.label, niol, {RightLabel = "~b~"..v.price.."$"}, true, {
                        onSelected = function()
                            local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(object)
                            ESX.TriggerServerCallback('esx_vehicle_location:buy', function(bought)
                                if bought then
                                    if spawnPoint then
                                        ESX.Game.SpawnVehicle(v.model, spawnPoint.coords, spawnPoint.heading, function(vehicle)
                                            TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                                        end)
                        
                                        ESX.ShowNotification("Vous avez payé la Location")
                                        RageUI.CloseAll()
                                        InMenu = false
                                        currentAction = 'location_menu'
                                        currentActionMsg = "Appuyez sur [~b~E~s~] Pour ouvrir le Menu de Location"
                                        currentActionData = {}
                                    end
                                else
                                    ESX.ShowNotification("Vous n'avez pas assez d'Argent")
                                    RageUI.CloseAll()
                                    InMenu = false
                                    currentAction = 'location_menu'
                                    currentActionMsg = "Appuyez sur [~b~E~s~] Pour ouvrir le Menu de Location"
                                    currentActionData = {}
                                end
                            end, v.price)
                        end
                    })
                end
            end, function() 
            end)
        end
    end)
end

function GetAvailableVehicleSpawnPoint(object)
    local found, foundSpawnPoint = false, nil
    
    for i=1, #object.SpawnPoints, 1 do
        if ESX.Game.IsSpawnPointClear(object.SpawnPoints[i].coords, object.SpawnPoints[i].radius) then
           found, foundSpawnPoint = true, object.SpawnPoints[i]
           break
        end
    end

    if found then
        return true, foundSpawnPoint
    else
        ESX.ShowNotification("Point de Spawn Bloquer !")
        return false
    end
end

AddEventHandler('esx_vehicle_location:hasEnteredMarker', function(zone)
    currentAction = 'location_menu'
    currentActionMsg = "Appuyez sur [~b~E~s~] Pour ouvrir le Menu de Location"
    currentActionData = {}
end)

AddEventHandler('esx_vehicle_location:hasExitedMarker', function(zone)
    ESX.UI.Menu.CloseAll()
    currentAction = nil
end)

-- Create blip
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Config.Locations.Blip.Coords)

    SetBlipSprite(blip, Config.Locations.Blip.Sprite)
    SetBlipDisplay(blip, Config.Locations.Blip.Display)
    SetBlipScale(blip, Config.Locations.Blip.Scale)
    SetBlipColour(blip, Config.Locations.Blip.Color)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString("Location")
    EndTextCommandSetBlipName(blip)
end)

-- Enter / Exit marker events & draw markers
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerCoords, isInMarker, currentZone, letSleep = GetEntityCoords(PlayerPedId()), nil, nil, true

        for k,v in pairs(Config.Locations.Vehicles) do
            local distance = GetDistanceBetweenCoords(playerCoords, v.Spawner, true)

            if distance < Config.DrawDistance then
                DrawMarker(Config.MarkerType, v.Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
                letSleep = false
            end

            if distance < Config.MarkerSize.x then
                isInMarker, currentZone, vehiclePart = true, k, v
            end
        end

        if (isInMarker and not hasAlreadyEnteredMarker) or (isInMarker and lastZone ~= currentZone) then
            hasAlreadyEnteredMarker, lastZone = true, currentZone
            TriggerEvent('esx_vehicle_location:hasEnteredMarker', currentZone)
        end

        if not isInMarker and hasAlreadyEnteredMarker then
            hasAlreadyEnteredMarker = false
            TriggerEvent('esx_vehicle_location:hasExitedMarker', lastZone)
        end

        if letSleep then
            Citizen.Wait(500)
        end
    end
end)

-- Key controls
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if currentAction then
            ESX.ShowHelpNotification(currentActionMsg)

            if IsControlJustReleased(0, 38) then
                if currentAction == 'location_menu' then
                    OpenVehicleLocationMenu(vehiclePart)
                end

                currentAction = nil
            end
        else
            Citizen.Wait(500)
        end
    end
end)
