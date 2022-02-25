import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/config/AndroidDisplayMode.dart';
import 'package:pikapika/basic/config/AndroidSecureFlag.dart';
import 'package:pikapika/basic/config/AutoClean.dart';
import 'package:pikapika/basic/config/AutoFullScreen.dart';
import 'package:pikapika/basic/config/ChooserRoot.dart';
import 'package:pikapika/basic/config/ContentFailedReloadAction.dart';
import 'package:pikapika/basic/config/ConvertToPNG.dart';
import 'package:pikapika/basic/config/DownloadAndExportPath.dart';
import 'package:pikapika/basic/config/DownloadThreadCount.dart';
import 'package:pikapika/basic/config/FullScreenAction.dart';
import 'package:pikapika/basic/config/FullScreenUI.dart';
import 'package:pikapika/basic/config/KeyboardController.dart';
import 'package:pikapika/basic/config/NoAnimation.dart';
import 'package:pikapika/basic/config/PagerAction.dart';
import 'package:pikapika/basic/config/Quality.dart';
import 'package:pikapika/basic/config/ReaderDirection.dart';
import 'package:pikapika/basic/config/ReaderSliderPosition.dart';
import 'package:pikapika/basic/config/ReaderType.dart';
import 'package:pikapika/basic/config/ShadowCategories.dart';
import 'package:pikapika/basic/config/Themes.dart';
import 'package:pikapika/basic/config/TimeOffsetHour.dart';
import 'package:pikapika/basic/config/Version.dart';
import 'package:pikapika/basic/config/VolumeController.dart';
import 'package:pikapika/basic/config/shadowCategoriesMode.dart';
import 'package:pikapika/screens/components/NetworkSetting.dart';

import 'CleanScreen.dart';
import 'MigrateScreen.dart';
import 'ModifyPasswordScreen.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('设置')),
        body: ListView(
          children: [
            Divider(),
            ListTile(
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ModifyPasswordScreen()),
                );
              },
              title: Text('修改密码'),
            ),
            Divider(),
            NetworkSetting(),
            Divider(),
            qualitySetting(),
            convertToPNGSetting(),
            readerTypeSetting(),
            readerDirectionSetting(),
            readerSliderPositionSetting(),
            autoFullScreenSetting(),
            fullScreenActionSetting(),
            volumeControllerSetting(),
            keyboardControllerSetting(),
            noAnimationSetting(),
            Divider(),
            shadowCategoriesModeSetting(),
            shadowCategoriesSetting(),
            pagerActionSetting(),
            fullScreenUISetting(),
            contentFailedReloadActionSetting(),
            timeZoneSetting(),
            Divider(),
            autoCleanSecSetting(),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CleanScreen()),
                );
              },
              title: Text('清除缓存'),
            ),
            Divider(),
            androidDisplayModeSetting(),
            androidSecureFlagSetting(),
            Divider(),
            chooserRootSetting(),
            downloadThreadCountSetting(),
            downloadAndExportPathSetting(),
            fontSetting(),
            Divider(),
            migrate(context),
            Divider(),
            autoUpdateCheckSetting(),
            Divider(),
          ],
        ),
      );

  Widget migrate(BuildContext context) {
    if (Platform.isAndroid) {
      return ListTile(
        title: Text("文件迁移"),
        subtitle: Text("更换您的数据文件夹"),
        onTap: () async {
          var f =
              await confirmDialog(context, "文件迁移", "此功能菜单保存后, 需要重启程序, 您确认吗");
          if (f) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) {
                return MigrateScreen();
              }),
              (route) => false,
            );
          }
        },
      );
    }
    return Container();
  }
}
