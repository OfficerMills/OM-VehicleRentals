local QBCore = exports['qb-core']:GetCoreObject()

-- Debug print function
local function DebugPrint(message)
    if Config.Debug then
        print("[DEBUG]: " .. tostring(message))
    end
end

-- Check if Player has a Driver's License
QBCore.Functions.CreateCallback('om-vehiclerentals:hasDriversLicense', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        DebugPrint("Player not found for source ID: " .. source)
        cb(false)
        return
    end

    -- Fetch licenses from metadata
    local licenses = Player.PlayerData.metadata["licences"]
    if licenses and licenses["driver"] then
        DebugPrint("License check passed for player ID: " .. source)
        cb(true) -- Player has a driver's license
    else
        DebugPrint("License check failed for player ID: " .. source)
        cb(false) -- Player does not have a driver's license
    end
end)

-- Process Rental
RegisterNetEvent('om-vehiclerentals:serverProcessRental', function(vehicle, location)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        DebugPrint("Player not found for source ID: " .. src)
        return
    end

    if not vehicle or not location then
        DebugPrint("Error: Missing vehicle or location data in serverProcessRental.")
        TriggerClientEvent('QBCore:Notify', src, "An error occurred while processing your rental.", "error")
        return
    end

    local price = vehicle.price + vehicle.deposit
    DebugPrint("Processing rental for player ID: " .. src .. ", Vehicle: " .. vehicle.label .. ", Total Cost: $" .. price)

    -- Check if player has enough money
    if Player.Functions.RemoveMoney('cash', price, 'vehicle-rental') then
        DebugPrint("Payment successful for player ID: " .. src)

        -- Generate plate for the rental vehicle
        local rentalPlate = "RENTAL" .. math.random(00, 99)
        local rentalInfo = {
            label = vehicle.label,
            deposit = vehicle.deposit,
            plate = rentalPlate
        }

        -- Grant Rental Papers
        Player.Functions.AddItem('rental_papers', 1, nil, rentalInfo)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['rental_papers'], "add")
        DebugPrint("Rental papers issued to player ID: " .. src)

        -- Send spawn data back to client
        TriggerClientEvent('om-vehiclerentals:spawnVehicle', src, {
            vehicle = vehicle,
            location = location,
            plate = rentalPlate
        })

        TriggerClientEvent('QBCore:Notify', src, 'Vehicle rented successfully!', 'success')
    else
        DebugPrint("Payment failed for player ID: " .. src)
        TriggerClientEvent('QBCore:Notify', src, 'Not enough money!', 'error')
    end
end)

-- Return Rental Papers and Delete Vehicle
QBCore.Functions.CreateCallback('om-vehiclerentals:serverReturnVehicle', function(source, cb, location)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        cb(false)
        return
    end

    local rentalPapers = Player.Functions.GetItemByName('rental_papers')
    if rentalPapers then
        local vehiclePlate = rentalPapers.info.plate or nil
        local deposit = rentalPapers.info.deposit or 0

        -- Refund part of the deposit
        local refund = math.floor(deposit * (Config.DepositRefundPercent / 100))
        Player.Functions.RemoveItem('rental_papers', 1)
        Player.Functions.AddMoney('cash', refund, 'rental-refund')

        -- Inform the callback that the vehicle can be deleted
        cb(true)
    else
        cb(false)
    end
end)


-- Despawn Vehicle Event
RegisterNetEvent('om-vehiclerentals:despawnVehicle', function(vehiclePlate)
    if not vehiclePlate then
        DebugPrint("Error: Missing vehicle plate for despawnVehicle.")
        return
    end

    local allVehicles = GetGamePool('CVehicle') -- Get all vehicles in the game
    for _, vehicle in ipairs(allVehicles) do
        if GetVehicleNumberPlateText(vehicle) == vehiclePlate then
            DeleteEntity(vehicle)
            DebugPrint("Vehicle deleted successfully for plate: " .. vehiclePlate)
            return
        end
    end

    DebugPrint("Error: No vehicle found with plate: " .. vehiclePlate)
end)


-- Ensure players cannot rent multiple vehicles
QBCore.Functions.CreateCallback('om-vehiclerentals:canRentVehicle', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        cb(false)
        return
    end

    local rentalPapers = Player.Functions.GetItemByName('rental_papers')
    if rentalPapers then
        cb(false) -- Player already has a rented vehicle
        TriggerClientEvent('QBCore:Notify', source, 'You already have a rented vehicle. Return it before renting another.', 'error')
    else
        cb(true) -- Player can rent a vehicle
    end
end)


--    ____  __  ___   ____                 __                                 __ 
--   / __ \/  |/  /  / __ \___ _   _____  / /___  ____  ____ ___  ___  ____  / /_ ™
--  / / / / /|_/ /  / / / / _ \ | / / _ \/ / __ \/ __ \/ __ `__ \/ _ \/ __ \/ __/
-- / /_/ / /  / /  / /_/ /  __/ |/ /  __/ / /_/ / /_/ / / / / / /  __/ / / / /_  
-- \____/_/  /_/  /_____/\___/|___/\___/_/\____/ .___/_/ /_/ /_/\___/_/ /_/\__/  
--                                          /_/                              