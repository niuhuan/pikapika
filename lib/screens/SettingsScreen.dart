import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/config/AndroidDisplayMode.dart';
import 'package:pikapi/basic/config/AutoClean.dart';
import 'package:pikapi/basic/config/AutoFullScreen.dart';
import 'package:pikapi/basic/config/ChooserRoot.dart';
import 'package:pikapi/basic/config/ContentFailedReloadAction.dart';
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

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('设置')),
        body: ListView(
          children: [
            Divider(),
            NetworkSetting(),
            Divider(),
            qualitySetting(),
            ListTile(
              title: Text("阅读器模式"),
              subtitle: Text(currentReaderTypeName()),
              onTap: () async {
                await choosePagerType(context);
                setState(() {});
              },
            ),
            ListTile(
              title: Text("阅读器方向"),
              subtitle: Text(currentReaderDirectionName()),
              onTap: () async {
                await choosePagerDirection(context);
                setState(() {});
              },
            ),
            ListTile(
              title: Text("进入阅读器自动全屏"),
              subtitle: Text(autoFullScreenName()),
              onTap: () async {
                await chooseAutoFullScreen(context);
                setState(() {});
              },
            ),
            ListTile(
              title: Text("进入全屏的方式"),
              subtitle: Text(currentFullScreenActionName()),
              onTap: () async {
                await chooseFullScreenAction(context);
                setState(() {});
              },
            ),
            volumeControllerSetting(),
            keyboardControllerSetting(),
            Divider(),
            shadowCategoriesSetting(),
            ListTile(
              title: Text("列表页加载方式"),
              subtitle: Text(currentPagerActionName()),
              onTap: () async {
                await choosePagerAction(context);
                setState(() {});
              },
            ),
            ListTile(
              title: Text("全屏UI"),
              subtitle: Text(currentFullScreenUIName()),
              onTap: () async {
                await chooseFullScreenUI(context);
                setState(() {});
              },
            ),
            ListTile(
              title: Text("加载失败时"),
              subtitle: Text(currentContentFailedReloadActionName()),
              onTap: () async {
                await chooseContentFailedReloadAction(context);
                setState(() {});
              },
            ),
            timeZoneSetting(),
            Divider(),
            ListTile(
              title: Text("自动清理缓存"),
              subtitle: Text(currentAutoCleanSec()),
              onTap: () async {
                await chooseAutoCleanSec(context);
                setState(() {});
              },
            ),
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
            Divider(),
            ListTile(
              title: Text("文件夹选择器默认路径"),
              subtitle: Text(currentChooserRoot()),
              onTap: () async {
                await inputChooserRoot(context);
                setState(() {});
              },
            ),
            fontSetting(),
            Divider(),
            migrate(),
          ],
        ),
      );

  Widget migrate() {
    if (Platform.isAndroid) {
      return ListTile(
        title: Text("文件迁移"),
        subtitle: Text("更换您的数据文件夹"),
        onTap: () async {
          var f = await confirmDialog(
            context,
            "文件迁移",
            "此功能菜单保存后, 需要重启程序, 您确认吗"
          );
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
