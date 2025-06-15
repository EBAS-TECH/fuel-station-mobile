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
   ```
## Installation 💻

### Prerequisites
- Flutter SDK (v3.0.0 or later)
- Dart SDK

### Clone the Repository
```bash
git clone https://github.com/EBAS-TECH/fuel-station-mobile.git
cd fuel-station-mobile-main
```
### Project Structure 📂
```plaintext
fuel-station-mobile-main/
├── lib/
│   ├── core/
│   │   ├── themes/             # App-wide themes (colors, text styles)
│   │   └── utils/              # Utility functions
│   │
│   ├── features/               # Feature modules
│   │   ├── auth/               # Authentication
│   │   ├── dashboard/          # Homepage
│   │   ├── fuel_avaliablity/   # Fuel status
│   │   ├── station/            # Station data
│   │   └── user/               # User profile
│   │
├── l10n/                       # Localization files
├── settings/                   # Setting components
├── .env                        # Environment config
└── main.dart                   # App entry point
```

### Install Dependencies
```bash
flutter pub get
```
### Configure environment variables:
- Create a .env file in the root directory:
```bash
API_BASE_URL=BACK_END_URL (Will be provided)
```
### Run the app
```bash
flutter run
```
## Contributing 🤝

1. Fork the project  
2. Create your feature branch 
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. Commit your changes
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
4. Push your changes
   ```bash
   git push origin feature/AmazingFeature
   ```
5. Open pull request
