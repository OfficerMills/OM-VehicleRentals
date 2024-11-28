--    ____  __  ___   ____                 __                                 __ 
--   / __ \/  |/  /  / __ \___ _   _____  / /___  ____  ____ ___  ___  ____  / /_ ™
--  / / / / /|_/ /  / / / / _ \ | / / _ \/ / __ \/ __ \/ __ `__ \/ _ \/ __ \/ __/
-- / /_/ / /  / /  / /_/ /  __/ |/ /  __/ / /_/ / /_/ / / / / / /  __/ / / / /_  
-- \____/_/  /_/  /_____/\___/|___/\___/_/\____/ .___/_/ /_/ /_/\___/_/ /_/\__/  
--                                          /_/                              
Config = {}

-- Debug mode for logging
Config.Debug = false -- Set to false to disable debug prints

-- Refund percentage for deposit
Config.DepositRefundPercent = 85 -- Percentage of deposit refunded when returning rental papers

-- Rental Locations (Add as many as you like)
Config.RentalLocations = {
    {
        name = "LSIA Rentals", -- Name of Rental Location
        pedModel = "cs_andreas", -- PED Model for Interaction
        pedCoords = vector4(-1029.90, -2734.88, 20.25, 334), -- PED Coordinates
        vehicleSpawn = vector4(-1024.44, -2735.64, 19.24, 240), -- Vehicle Spawn Location
        vehicles = { -- Vehicle Models Available at location
            {model = "faggio", label = "Faggio Scooter", price = 500, deposit = 1000},
            {model = "blista", label = "Blista Compact", price = 500, deposit = 2000}
        }
    },
    {
        name = "Cayo Airport Rentals", -- Name of Rental Location
        pedModel = "cs_manuel", -- PED Model for Interaction
        pedCoords = vector4(4516.14, -4515.84, 4.29, 92), -- PED Coordinates
        vehicleSpawn = vector4(4524.47, -4496.15, 3.35, 293), -- Vehicle Spawn Location
        vehicles = { -- Vehicle Models Available at location
            {model = "sanchez", label = "Sanchez MX", price = 250, deposit = 1000},
            {model = "bodhi2", label = "Bodhi Jeep", price = 1000, deposit = 2000}
        }
    },
    -- Uncomment and modify the example below to add more locations
    -- {
    --     name = "Airport Rentals",
    --     pedModel = "s_m_m_pilot_01",
    --     pedCoords = vector4(-941.25, -2947.65, 13.94, 180.0),
    --     vehicleSpawn = vector4(-945.55, -2951.15, 13.94, 180.0),
    --     vehicles = {
    --         {model = "dilettante", label = "Dilettante Hybrid", price = 300, deposit = 600},
    --         {model = "turismor", label = "Turismo R", price = 1000, deposit = 2000}
    --     }
    -- },
}

