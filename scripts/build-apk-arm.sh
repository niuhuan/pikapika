# 仅构建arm的APK

cd "$( cd "$( dirname "$0"  )" && pwd  )/.."

cd go/mobile
gomobile bind -target=android/arm -o lib/Mobile.aar ./
cd ../..
flutter build apk --target-platform android-arm
