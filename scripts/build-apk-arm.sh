# 仅构建arm的APK

cd go/mobile
cd ../..
gomobile bind -target=android/arm -o lib/Mobile.aar ./
flutter build apk --target-platform android-arm
