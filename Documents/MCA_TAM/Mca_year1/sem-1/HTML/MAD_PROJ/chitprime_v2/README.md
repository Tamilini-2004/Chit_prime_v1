# CHITPRIME v2 — Firebase Connected

## Quick Setup (5 steps)

### Step 1 — Create Firebase Project
1. Go to https://console.firebase.google.com
2. Create project: `chitprime-app`
3. Enable: Authentication (Email/Password), Firestore, Realtime Database, Storage
4. Firestore rules: `allow read, write: if true;`
5. Realtime DB rules: `{ "rules": { ".read": true, ".write": true } }`

### Step 2 — Add Web App
1. Firebase Console → Add App → Web
2. Copy the firebaseConfig values
3. Update `lib/firebase_options.dart` with your values

### Step 3 — Add Android App
1. Firebase Console → Add App → Android
2. Package: `com.chitprime.chitprime_v2`
3. Download `google-services.json` → place in `android/app/`

### Step 4 — Install & Run
```cmd
set PATH=%PATH%;C:\flutter\bin
cd C:\Users\Tamilini.S\Documents\MCA_TAM\Mca_year1\sem-1\HTML\MAD_PROJ\chitprime_v2
flutter create --platforms=web .
flutter pub get
```

### Step 5 — Run Apps
```cmd
# User App
flutter run -t lib/main.dart -d chrome

# Admin App  
flutter run -t lib/main_admin.dart -d chrome
```

## Demo Credentials
- **User App**: Enter any phone number → auto-login
- **Admin App**: test@admin.com / admin123

## Real-Time Features
- Live auction bids (Firebase Realtime DB, <100ms)
- Admin actions instantly visible to users (Firestore streams)
- Push notifications (FCM)
- Live payment status updates
- Real-time fraud alerts
- Group member changes reflected instantly

## Inter-App Communication
```
User pays → Foreman notified instantly (Firestore + FCM)
Admin suspends user → User sees suspended screen immediately
Member bids → All group members see bid in real-time (RTDB)
Foreman confirms payout → Winner notified instantly
Admin sends message → User receives in chat instantly
```
