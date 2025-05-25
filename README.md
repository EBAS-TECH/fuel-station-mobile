# ⛽ Fuel Finder - Station Manager App

An application for fuel station operators to manage station details and fuel availability in real-time through the Fuel Finder ecosystem.

## ✨ Features

### ⛽ Fuel Availability
- Real-time toggle for:
  - Petrol
  - Diesel
- Bulk status updates
- 
### 🏪 Station Management
- **Station Dashboard**
  - View station details
## 🛠 Tech Stack

| Component          | Technology               |
|--------------------|-------------------------|
| Frontend           | Flutter                 |
| State Management   | Bloc Pattern            |
| Backend            | Node.js REST API        |
| Authentication     | JWT Tokens              |

## 📱 Screens

1. **Auth Flow**
   - Username/Password login

2. **Main Dashboard**
   - Quick status overview

3. **Inventory Management**
   ```dart
   AvailabilitySwitch(
     fuelType: 'Petrol',
     initialValue: true,
     onChanged: (bool value) {
     },
   )
