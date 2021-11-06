import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/config/AndroidDisplayMode.dart';
import 'package:pikapi/basic/config/AndroidSecureFlag.dart';
import 'package:pikapi/basic/config/AutoClean.dart';
import 'package:pikapi/basic/config/AutoFullScreen.dart';
import 'package:pikapi/basic/config/ChooserRoot.dart';
import 'package:pikapi/basic/config/ContentFailedReloadAction.dart';
import 'package:pikapi/basic/config/ConvertToPNG.dart';
import 'package:pikapi/basic/config/DownloadAndExportPath.dart';
import 'package:pikapi/basic/config/DownloadThreadCount.dart';
import 'package:pikapi/basic/config/FullScreenAction.dart';
import 'package:pikapi/basic/config/FullScreenUI.dart';
import 'package:pikapi/basic/config/KeyboardController.dart';
import 'package:pikapi/basic/config/PagerAction.dart';
import 'package:pikapi/basic/config/ReaderDirection.dart';
import 'package:pikapi/basic/config/ReaderType.dart';
import 'package:pikapi/basic/config/Quality.dart';
import 'package:pikapi/basic/config/ShadowCategories.dart';
import 'package:pikapi/basic/config/Themes.dart';
import 'package:pikapi/basic/config/TimeOffsetHour.dart';
import 'package:pikapi/basic/config/VolumeController.dart';
import 'package:pikapi/screens/components/NetworkSetting.dart';

import 'CleanScreen.dart';
import 'MigrateScreen.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('设置')),
        body: ListView(
          children: [
            Divider(),
            NetworkSetting(),
            Divider(),
            qualitySetting(),
            convertToPNGSetting(),
            readerTypeSetting(),
            readerDirectionSetting(),
            autoFullScreenSetting(),
            fullScreenActionSetting(),
            volumeControllerSetting(),
            keyboardControllerSetting(),
            Divider(),
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
