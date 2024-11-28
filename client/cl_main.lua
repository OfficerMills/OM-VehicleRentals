local QBCore = exports['qb-core']:GetCoreObject()

-- Debug print function
function DebugPrint(message)
    if Config.Debug then
        print("[DEBUG]: " .. tostring(message))
    end
end

-- Debug configured rental locations on resource start
CreateThread(function()
    DebugPrint("Configured Rental Locations:")
    for index, location in ipairs(Config.RentalLocations) do
        DebugPrint("Location " .. index .. ": " .. json.encode(location or {}))
        for vIndex, vehicle in ipairs(location.vehicles or {}) do
            DebugPrint("Vehicle " .. vIndex .. ": " .. json.encode(vehicle or {}))
        end
    end
end)

-- Spawn Rental Peds and Set Up Targeting
CreateThread(function()
    DebugPrint("Spawning rental ped(s) and setting up targeting...")
    for index, location in ipairs(Config.RentalLocations) do
        if not location or not location.name or not location.pedCoords or not location.pedModel then
            DebugPrint("Error: Invalid rental location configuration at index " .. index)
            DebugPrint("Location Data: " .. json.encode(location or {}))
            goto continue
        end

        local pedHash = GetHashKey(location.pedModel)
        RequestModel(pedHash)
        while not HasModelLoaded(pedHash) do
            Wait(100)
        end

        -- Create Ped
        local ped = CreatePed(4, pedHash, location.pedCoords.x, location.pedCoords.y, location.pedCoords.z - 1.0, location.pedCoords.w, false, true)
        if DoesEntityExist(ped) then
            DebugPrint("Ped created successfully at: " .. tostring(location.pedCoords))

            -- Freeze ped in place and make invincible
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)

            -- Make ped play clipboard animation
            local animDict = "amb@world_human_clipboard@male@base"
            local animName = "base"
            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do
                Wait(100)
            end
            TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)

            DebugPrint("Clipboard animation set for ped at location: " .. location.name)

            -- Add targeting options to ped
            exports['qb-target']:AddTargetEntity(ped, {
                options = {
                    {
                        type = "client",
                        event = "om-vehiclerentals:checkLicense",
                        icon = "fas fa-car",
                        label = "Rent a Vehicle",
                        args = {location = location}
                    },
                    {
                        type = "client",
                        event = "om-vehiclerentals:returnVehicle",
                        icon = "fas fa-undo",
                        label = "Return Vehicle",
                        args = {location = location}
                    }
                },
                distance = 3.0
            })

            DebugPrint("Targeting set up for ped at location: " .. location.name)
        else
            DebugPrint("Error: Failed to create ped at location: " .. tostring(location.pedCoords))
        end

        -- Release ped model
        SetModelAsNoLongerNeeded(pedHash)
        ::continue::
    end
    DebugPrint("Rental ped(s) and targeting setup complete.")
end)

-- Check Player's License
RegisterNetEvent('om-vehiclerentals:checkLicense', function(data)
    local location = data.args.location

    if not location or not location.name then
        DebugPrint("Error: Location data is missing or invalid.")
        DebugPrint("Location Data: " .. json.encode(location or {}))
        QBCore.Functions.Notify("An error occurred while checking the rental location.", "error")
        return
    end

    DebugPrint("Checking driver's license for player...")
    QBCore.Functions.TriggerCallback('om-vehiclerentals:hasDriversLicense', function(hasLicense)
        if hasLicense then
            DebugPrint("Player has a valid driver's license.")
            TriggerEvent('om-vehiclerentals:openMenu', location)
        else
            DebugPrint("Player does not have a valid driver's license.")
            QBCore.Functions.Notify("You need a driver's license to rent a vehicle!", "error")
        end
    end)
end)

-- Open Rental Menu
RegisterNetEvent('om-vehiclerentals:openMenu', function(location)
    if not location or not location.name then
        DebugPrint("Error: Invalid location data.")
        QBCore.Functions.Notify("Unable to open rental menu. Please contact staff.", "error")
        return
    end

    DebugPrint("Opening rental menu for location: " .. location.name)

    local options = {}

    for _, vehicle in ipairs(location.vehicles or {}) do
        -- Ensure vehicle data is valid
        local label = vehicle.label or "Undefined"
        local price = vehicle.price or 0
        local deposit = vehicle.deposit or 0

        -- Add formatted menu option
        table.insert(options, {
            header = label,
            txt = "Rent for $" .. price .. " + $" .. deposit .. " deposit.",
            params = {
                event = "om-vehiclerentals:processRental",
                args = {vehicle = vehicle, location = location}
            }
        })
    end

    -- Add a close option at the end
    table.insert(options, {
        header = "Close",
        txt = "",
        params = {
            event = ""
        }
    })

    exports['qb-menu']:openMenu(options)
    DebugPrint("Rental menu opened with " .. #options .. " options.")
end)

-- Trigger Server-Side Rental Process
RegisterNetEvent('om-vehiclerentals:processRental', function(data)
    local vehicle = data.vehicle
    local location = data.location

    if not location or not location.vehicleSpawn then
        DebugPrint("Error: Vehicle spawn data is invalid or missing.")
        QBCore.Functions.Notify("An error occurred while processing your request.", "error")
        return
    end

    -- Notify server to process the rental
    TriggerServerEvent('om-vehiclerentals:serverProcessRental', vehicle, location)
end)

-- Spawn Vehicle
RegisterNetEvent('om-vehiclerentals:spawnVehicle', function(data)
    local vehicle = data.vehicle
    local location = data.location
    local plate = data.plate

    if not vehicle or not location or not location.vehicleSpawn then
        DebugPrint("Error: Missing or invalid data for vehicle spawn.")
        QBCore.Functions.Notify("An error occurred while spawning the vehicle.", "error")
        return
    end

    local vehicleHash = GetHashKey(vehicle.model)
    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do
        DebugPrint("Loading model: " .. vehicle.model)
        Wait(100)
    end

    local coords = location.vehicleSpawn
    local vehicleEntity = CreateVehicle(vehicleHash, coords.x, coords.y, coords.z, coords.w, true, false)

    if DoesEntityExist(vehicleEntity) then
        DebugPrint("Vehicle spawned successfully: " .. vehicle.label)

        -- Set custom license plate
        SetVehicleNumberPlateText(vehicleEntity, plate)
        DebugPrint("Set license plate to: " .. plate)

        -- Set player into vehicle
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicleEntity, -1)

        -- Give keys to the player
        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)

        -- Set fuel level
        if exports['cdn-fuel'] then
            DebugPrint("CDN Fuel export detected.")
            exports['cdn-fuel']:SetFuel(vehicleEntity, 100.0)
        else
            DebugPrint("CDN Fuel export not found!")
        end
    else
        DebugPrint("Error: Failed to spawn vehicle.")
        QBCore.Functions.Notify("Failed to spawn vehicle.", "error")
    end

    SetModelAsNoLongerNeeded(vehicleHash)
end)

-- Return Vehicle
RegisterNetEvent('om-vehiclerentals:returnVehicle', function(data)
    local location = data.args.location

    if not location then
        DebugPrint("Error: Invalid location data for return vehicle.")
        QBCore.Functions.Notify("An error occurred while returning the vehicle.", "error")
        return
    end

    -- Check if the player is in a vehicle
    local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)

    if playerVehicle == 0 then
        DebugPrint("Player is not in a vehicle. Cannot return.")
        QBCore.Functions.Notify("You must be in the rental vehicle to return it.", "error")
        return
    end

    QBCore.Functions.TriggerCallback('om-vehiclerentals:serverReturnVehicle', function(success)
        if success then
            -- Delete the vehicle the player is currently in
            if DoesEntityExist(playerVehicle) then
                DeleteEntity(playerVehicle)
                DebugPrint("Rented vehicle deleted successfully!")
                QBCore.Functions.Notify("Vehicle returned successfully. Refund issued.", "success")
            else
                DebugPrint("Failed to delete the vehicle entity.")
                QBCore.Functions.Notify("An error occurred while deleting the vehicle.", "error")
            end
        else
            QBCore.Functions.Notify("Unable to return vehicle. Ensure you have rental papers.", "error")
        end
    end, location)
end)


--    ____  __  ___   ____                 __                                 __ 
--   / __ \/  |/  /  / __ \___ _   _____  / /___  ____  ____ ___  ___  ____  / /_ ™
--  / / / / /|_/ /  / / / / _ \ | / / _ \/ / __ \/ __ \/ __ `__ \/ _ \/ __ \/ __/
-- / /_/ / /  / /  / /_/ /  __/ |/ /  __/ / /_/ / /_/ / / / / / /  __/ / / / /_  
-- \____/_/  /_/  /_____/\___/|___/\___/_/\____/ .___/_/ /_/ /_/\___/_/ /_/\__/  
--                                          /_/                              