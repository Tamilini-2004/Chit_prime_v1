# CHITPRIME - Smart Chit Fund App

A production-ready Flutter fintech application for managing digital chit funds for small retailers in India.

## Project Structure

```
chitprime_app/
├── lib/
│   ├── main.dart                    # User App entry point
│   ├── main_admin.dart              # Admin App entry point
│   ├── core/
│   │   ├── constants/               # Colors, strings, routes
│   │   ├── theme/                   # Material 3 theme
│   │   ├── utils/                   # Utility functions
│   │   └── widgets/                 # Reusable widgets
│   ├── data/
│   │   ├── models/                  # Data models
│   │   └── repositories/            # Data repositories (mock)
│   ├── features/                    # User App features
│   │   ├── auth/                    # Login, OTP, Register
│   │   ├── dashboard/               # Home screen
│   │   ├── groups/                  # Group management
│   │   ├── payments/                # Payment processing
│   │   ├── auctions/                # Live auctions
│   │   ├── credit_score/            # AI credit score
│   │   ├── notifications/           # Notifications
│   │   └── profile/                 # User profile
│   └── admin_features/              # Admin App features
│       ├── admin_auth/              # Admin login
│       ├── admin_dashboard/         # Dashboard + all tabs
│       ├── user_management/         # User CRUD
│       ├── group_management/        # Group CRUD
│       ├── fraud_detection/         # Fraud alerts
│       ├── transactions/            # Transaction monitoring
│       ├── reports/                 # Analytics & reports
│       └── settings/                # Platform settings
└── android/                         # Android config
```

## Setup & Run

### Prerequisites
1. Install Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Install Android Studio + Android SDK
3. Set up an emulator or connect a physical device

### Install Dependencies
```bash
cd chitprime_app
flutter pub get
```

### Run User App
```bash
flutter run -t lib/main.dart
```

### Run Admin App
```bash
flutter run -t lib/main_admin.dart
```

### Build APK - User App
```bash
flutter build apk -t lib/main.dart --release
```

### Build APK - Admin App
```bash
flutter build apk -t lib/main_admin.dart --release
```

## Demo Credentials

### User App
- Phone: any 10-digit number starting with 6-9
- OTP: **123456**

### Admin App
- Email: **admin@chitprime.com**
- Password: **Admin@123**

## Features

### User App
- Phone OTP authentication
- 3-step KYC registration
- Dashboard with AI credit score
- Group creation & management
- UPI/Card/NetBanking payments
- Live auction bidding
- Lottery-based winner selection
- Credit score analytics
- Push notifications

### Admin App
- Secure admin login with 2FA
- Platform overview dashboard
- User management (verify/suspend)
- Group management (approve/suspend)
- Transaction monitoring
- AI-powered fraud detection
- Reports & analytics
- Platform settings

## Tech Stack
- Flutter 3.x + Dart 3.x
- Provider (state management)
- GoRouter (navigation)
- FL Chart (charts)
- Percent Indicator (gauges)
- Pin Code Fields (OTP)
- Shimmer (loading states)
- Google Fonts (Poppins)
