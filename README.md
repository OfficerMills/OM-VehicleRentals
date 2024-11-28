##    ____  __  ___   ____                 __                                 __ 
##   / __ \/  |/  /  / __ \___ _   _____  / /___  ____  ____ ___  ___  ____  / /_ ™
##  / / / / /|_/ /  / / / / _ \ | / / _ \/ / __ \/ __ \/ __ `__ \/ _ \/ __ \/ __/
## / /_/ / /  / /  / /_/ /  __/ |/ /  __/ / /_/ / /_/ / / / / / /  __/ / / / /_  
## \____/_/  /_/  /_____/\___/|___/\___/_/\____/ .___/_/ /_/ /_/\___/_/ /_/\__/  
##                                          /_/                              


# OM Vehicle Rentals

OM Vehicle Rentals is a resource for FiveM that allows players to rent vehicles from specific locations on the map. This script includes configurable rental locations, dynamic pricing, deposit refunds, and integration with keys and fuel management.

---

## Features

- **Multiple Rental Locations**: Add as many locations as needed with custom ped models and spawn points.
- **Driver's License Check**: Players must have a valid driver's license to rent vehicles.
- **Rental Papers System**: Players receive rental papers upon renting a vehicle.
- **Vehicle Keys**: Players are granted keys to the rented vehicle.
- **Fuel Integration**: Vehicles spawn with full fuel using `cdn-fuel`.
- **Deposit Refund**: Configurable percentage of the deposit refunded upon returning the vehicle.
- **Dynamic Pricing**: Set custom prices and deposits per vehicle.

---

## Dependencies

This resource requires the following dependencies:

1. **[qb-core](https://github.com/qbcore-framework/qb-core)**
2. **[qb-vehiclekeys](https://github.com/qbcore-framework/qb-vehiclekeys)**
3. **[cdn-fuel](https://github.com/CryptickDev/cdn-fuel)**

Please ensure these dependencies are installed and correctly configured on your server.

---

## Installation

### Step 1: Download and Install Dependencies

Download and install the required dependencies listed above.

1. **qb-core**: Follow the [qb-core installation guide](https://github.com/qbcore-framework/qb-core).
2. **qb-vehiclekeys**: Follow the [qb-vehiclekeys installation guide](https://github.com/qbcore-framework/qb-vehiclekeys).
3. **cdn-fuel**: Follow the [cdn-fuel installation guide](https://github.com/CryptickDev/cdn-fuel).

### Step 2: Add OM Vehicle Rentals to Your Server

1. Download the OM Vehicle Rentals resource and place it in your `resources` folder.
2. Add the following line to your `server.cfg`:
   ```plaintext
   ensure om-vehiclerentals
