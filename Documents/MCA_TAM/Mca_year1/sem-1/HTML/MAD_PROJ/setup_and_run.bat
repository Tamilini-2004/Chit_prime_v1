@echo off
echo ============================================
echo  CHITPRIME - Flutter Setup Check
echo ============================================

echo.
echo [1] Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo.
    echo Flutter NOT found. Please install from:
    echo https://docs.flutter.dev/get-started/install/windows
    echo.
    echo Steps:
    echo  1. Download Flutter SDK from the link above
    echo  2. Extract to C:\flutter
    echo  3. Add C:\flutter\bin to your PATH environment variable
    echo  4. Run: flutter doctor
    echo  5. Re-run this script
    pause
    exit /b 1
)

echo.
echo [2] Running flutter doctor...
flutter doctor

echo.
echo [3] Getting dependencies...
cd chitprime_app
flutter pub get

echo.
echo ============================================
echo  Ready! Choose what to run:
echo  1. flutter run -t lib/main.dart        (User App)
echo  2. flutter run -t lib/main_admin.dart  (Admin App)
echo ============================================
pause
