import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapika/basic/config/Address.dart';
import 'package:pikapika/basic/config/AndroidDisplayMode.dart';
import 'package:pikapika/basic/config/AndroidSecureFlag.dart';
import 'package:pikapika/basic/config/Authentication.dart';
import 'package:pikapika/basic/config/AutoClean.dart';
import 'package:pikapika/basic/config/AutoFullScreen.dart';
import 'package:pikapika/basic/config/ChooserRoot.dart';
import 'package:pikapika/basic/config/ContentFailedReloadAction.dart';
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
import 'package:pikapika/basic/config/UsingRightClickPop.dart';
import 'package:pikapika/basic/config/Version.dart';
import 'package:pikapika/basic/config/VolumeController.dart';
import 'package:pikapika/basic/config/ShadowCategoriesMode.dart';
import 'package:pikapika/screens/ComicInfoScreen.dart';
import 'package:pikapika/screens/PkzArchiveScreen.dart';
import 'package:uni_links/uni_links.dart';
import 'package:uri_to_file/uri_to_file.dart';
import '../basic/config/ExportRename.dart';
import '../basic/config/IsPro.dart';
import 'AccountScreen.dart';
import 'AppScreen.dart';
import 'DownloadOnlyImportScreen.dart';

// ???????????????
class InitScreen extends StatefulWidget {
  const InitScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  var _authenticating = false;

  @override
  initState() {
    _init();
    super.initState();
  }

  Future<dynamic> _init() async {
    // ?????????????????????
    await initPlatform(); // ????????????????????????, ??????????????????
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
    await initNoAnimation();
    await initExportRename();
    await initVersion();
    await initUsingRightClickPop();
    await initAuthentication();
    await reloadIsPro();
    autoCheckNewVersion();

    String? initUrl;
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        initUrl = (await getInitialUri())?.toString();
        // Use the uri and warn the user, if it is not correct,
        // but keep in mind it could be `null`.
      } on FormatException {
        // Handle exception by warning the user their action did not succeed
        // return?
      }
    }
    if (initUrl != null) {
      if (RegExp(r"^pika://comic/([0-9A-z]+)/$").allMatches(initUrl!).isNotEmpty) {
        String comicId = RegExp(r"^pika://comic/([0-9A-z]+)/$").allMatches(initUrl!).first.group(1)!;
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) =>
              ComicInfoScreen(comicId: comicId, holdPkz: true),
        ));
        return;
      } else if (RegExp(r"^.*\.pkz$").allMatches(initUrl!).isNotEmpty) {
        File file = await toFile(initUrl!);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) =>
              PkzArchiveScreen(pkzPath: file.path, holdPkz: true),
        ));
        return;
      } else if (RegExp(r"^.*\.((pki)|(zip))$").allMatches(initUrl!).isNotEmpty) {
        File file = await toFile(initUrl!);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) =>
                DownloadOnlyImportScreen(path: file.path, holdPkz: true),
          ),
        );
        return;
      }
    }

    setState(() {
      _authenticating = currentAuthentication();
    });
    if (_authenticating) {
      _goAuthentication();
    } else {
      _goApplication();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authenticating) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("????????????"),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: MaterialButton(
              onPressed: () {
                _goAuthentication();
              },
              child:
                  const Text('??????????????????APP????????????????????????, ????????????????????????????????????, ???????????????????????????APP'),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xfffffced),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Image.asset(
          "lib/assets/init.jpg",
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Future _goApplication() async {
    // ??????, ??????token??????????????????, ?????????????????????????????????1??????
    if (await method.preLogin()) {
      // ??????token???username+password???????????????????????????????????????
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AppScreen()),
      );
    } else {
      // ????????????????????????
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AccountScreen()),
      );
    }
  }

  Future _goAuthentication() async {
    if (await method.verifyAuthentication()) {
      _goApplication();
    }
  }
}
