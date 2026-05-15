@echo off

call flutter build apk --target-platform android-arm64 --split-per-abi

cd /d build\app\outputs\flutter-apk

for %%f in (*.apk) do (
    ren "%%f" "Reporting System.apk"
)

start .

echo.
echo APK BUILT SUCCESSFULLY!
pause