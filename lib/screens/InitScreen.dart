import 'package:flutter/material.dart';
import 'package:pikapika/basic/config/Address.dart';
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
import 'package:pikapika/basic/config/ImageAddress.dart';
import 'package:pikapika/basic/config/KeyboardController.dart';
import 'package:pikapika/basic/config/NoAnimation.dart';
import 'package:pikapika/basic/config/PagerAction.dart';
import 'package:pikapika/basic/config/Platform.dart';
import 'package:pikapika/basic/config/Proxy.dart';
import 'package:pikapika/basic/config/Quality.dart';
import 'package:pikapika/basic/config/ReaderDirection.dart';
import 'package:pikapika/basic/config/ReaderSliderPosition.dart';
import 'package:pikapika/basic/config/ReaderType.dart';
import 'package:pikapika/basic/config/ShadowCategories.dart';
import 'package:pikapika/basic/config/Themes.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/basic/config/ListLayout.dart';
import 'package:pikapika/basic/config/TimeOffsetHour.dart';
import 'package:pikapika/basic/config/Version.dart';
import 'package:pikapika/basic/config/VolumeController.dart';
import 'package:pikapika/basic/config/shadowCategoriesMode.dart';

import '../basic/config/ExportRename.dart';
import 'AccountScreen.dart';
import 'AppScreen.dart';

// 初始化界面
class InitScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  @override
  initState() {
    _init();
    super.initState();
  }

  Future<dynamic> _init() async {
    // 初始化配置文件
    await initPlatform(); // 必须第一个初始化, 加载设备信息
    await initAutoClean();
    await initAddress();
    await initImageAddress();
    await initProxy();
    await initQuality();
    await initFont();
    await initTheme();
    await initListLayout();
    await initReaderType();
    await initReaderDirection();
    await initReaderSliderPosition();
    await initAutoFullScreen();
    await initFullScreenAction();
    await initPagerAction();
    await initShadowCategoriesMode();
    await initShadowCategories();
    await initFullScreenUI();
    switchFullScreenUI();
    await initContentFailedReloadAction();
    await initVolumeController();
    await initKeyboardController();
    await initAndroidDisplayMode();
    await initChooserRoot();
    await initTimeZone();
    await initDownloadAndExportPath();
    await initAndroidSecureFlag();
    await initDownloadThreadCount();
    await initConvertToPNG();
    await initNoAnimation();
    await initExportRename();
    await initVersion();
    autoCheckNewVersion();
    // 登录, 如果token失效重新登录, 网络不好的时候可能需要1分钟
    if (await method.preLogin()) {
      // 如果token或username+password有效则直接进入登录好的界面
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AppScreen()),
      );
    } else {
      // 否则跳转到登录页
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AccountScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffffced),
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: new Image.asset(
          "lib/assets/init.jpg",
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
