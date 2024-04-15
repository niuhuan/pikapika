#!/usr/bin/env bash

curl -JOL https://github.com/junmer/source-han-serif-ttf/raw/master/SubsetTTF/CN/SourceHanSerifCN-Regular.ttf
mkdir -p fonts
mv SourceHanSerifCN-Regular.ttf fonts/Roboto.ttf
cat ci/linux_font.yaml >> pubspec.yaml
hover build linux-appimage
mv go/build/outputs/linux-appimage-release/*.AppImage build/build.AppImage
