import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pikapi/basic/config/AndroidDisplayMode.dart';
import 'package:pikapi/basic/config/AutoClean.dart';
import 'package:pikapi/basic/config/AutoFullScreen.dart';
import 'package:pikapi/basic/config/ContentFailedReloadAction.dart';
import 'package:pikapi/basic/config/FullScreenAction.dart';
import 'package:pikapi/basic/config/FullScreenUI.dart';
import 'package:pikapi/basic/config/KeyboardController.dart';
import 'package:pikapi/basic/config/PagerAction.dart';
import 'package:pikapi/basic/config/ReaderDirection.dart';
import 'package:pikapi/basic/config/ReaderType.dart';
import 'package:pikapi/basic/config/Quality.dart';
import 'package:pikapi/basic/config/ShadowCategories.dart';
import 'package:pikapi/basic/config/VolumeController.dart';
import 'package:pikapi/screens/components/NetworkSetting.dart';

import 'CleanScreen.dart';

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
            ListTile(
              title: Text("浏览时的图片质量"),
              subtitle: Text(currentQualityName()),
              onTap: () async {
                await chooseQuality(context);
                setState(() {});
              },
            ),
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
            ListTile(
              title: Text("阅读器音量键翻页(仅安卓)"),
              subtitle: Text(volumeControllerName()),
              onTap: () async {
                await chooseVolumeController(context);
                setState(() {});
              },
            ),
            ListTile(
              title: Text("阅读器键盘翻页(仅PC)"),
              subtitle: Text(keyboardControllerName()),
              onTap: () async {
                await chooseKeyboardController(context);
                setState(() {});
              },
            ),
            Divider(),
            ListTile(
              title: Text("封印"),
              subtitle: Text(jsonEncode(shadowCategories)),
              onTap: () async {
                await chooseShadowCategories(context);
                setState(() {});
              },
            ),
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
            ListTile(
              title: Text("屏幕刷新率(安卓)"),
              subtitle: Text(androidDisplayModeName()),
              onTap: () async {
                await chooseAndroidDisplayMode(context);
                setState(() {});
              },
            ),
            Divider(),
          ],
        ),
      );
}
