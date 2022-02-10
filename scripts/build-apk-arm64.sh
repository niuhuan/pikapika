# 仅构建arm64的APK

cd go/mobile
gomobile bind -target=android/arm64 -o lib/Mobile.aar ./
cd ../..
flutter build apk --target-platform android-arm64
