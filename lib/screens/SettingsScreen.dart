import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/config/AndroidDisplayMode.dart';
import 'package:pikapika/basic/config/AndroidSecureFlag.dart';
import 'package:pikapika/basic/config/AutoClean.dart';
import 'package:pikapika/basic/config/AutoFullScreen.dart';
import 'package:pikapika/basic/config/ChooserRoot.dart';
import 'package:pikapika/basic/config/ContentFailedReloadAction.dart';
import 'package:pikapika/basic/config/DownloadAndExportPath.dart';
import 'package:pikapika/basic/config/DownloadThreadCount.dart';
import 'package:pikapika/basic/config/ExportRename.dart';
import 'package:pikapika/basic/config/FullScreenAction.dart';
import 'package:pikapika/basic/config/FullScreenUI.dart';
import 'package:pikapika/basic/config/IconLoading.dart';
import 'package:pikapika/basic/config/IsPro.dart';
import 'package:pikapika/basic/config/KeyboardController.dart';
import 'package:pikapika/basic/config/NoAnimation.dart';
import 'package:pikapika/basic/config/PagerAction.dart';
import 'package:pikapika/basic/config/Quality.dart';
import 'package:pikapika/basic/config/ReaderDirection.dart';
import 'package:pikapika/basic/config/ReaderSliderPosition.dart';
import 'package:pikapika/basic/config/ReaderType.dart';
import 'package:pikapika/basic/config/ShadowCategories.dart';
import 'package:pikapika/basic/config/ShowCommentAtDownload.dart';
import 'package:pikapika/basic/config/Themes.dart';
import 'package:pikapika/basic/config/TimeOffsetHour.dart';
import 'package:pikapika/basic/config/Version.dart';
import 'package:pikapika/basic/config/VolumeController.dart';
import 'package:pikapika/basic/config/ShadowCategoriesMode.dart';
import 'package:pikapika/screens/components/NetworkSetting.dart';
import 'package:pikapika/screens/components/RightClickPop.dart';

import '../basic/config/Authentication.dart';
import '../basic/config/CategoriesColumnCount.dart';
import '../basic/config/DownloadCachePath.dart';
import '../basic/config/UsingRightClickPop.dart';
import '../basic/config/WillPopNotice.dart';
import 'CleanScreen.dart';
import 'MigrateScreen.dart';
import 'ModifyPasswordScreen.dart';

class SettingsScreen extends StatelessWidget {
  final bool hiddenAccountInfo;

  const SettingsScreen({Key? key, this.hiddenAccountInfo = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return rightClickPop(
      child: buildScreen(context),
      context: context,
      canPop: true,
    );
  }

  Widget buildScreen(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('设置')),
        body: ListView(
          children: [
            const Divider(),
            hiddenAccountInfo
                ? Container()
                : ListTile(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ModifyPasswordScreen()),
                      );
                    },
                    title: const Text('修改密码'),
                  ),
            const Divider(),
            const NetworkSetting(),
            const Divider(),
            shadowCategoriesModeSetting(),
            shadowCategoriesSetting(),
            qualitySetting(),
            const Divider(),
            pagerActionSetting(),
            contentFailedReloadActionSetting(),
            const Divider(),
            readerTypeSetting(),
            readerDirectionSetting(),
            readerSliderPositionSetting(),
            autoFullScreenSetting(),
            fullScreenActionSetting(),
            volumeControllerSetting(),
            keyboardControllerSetting(),
            noAnimationSetting(),
            iconLoadingSetting(),
            categoriesColumnCountSetting(),
            const Divider(),
            fullScreenUISetting(),
            willPopNoticeSetting(),
            timeZoneSetting(),
            const Divider(),
            autoCleanSecSetting(),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CleanScreen()),
                );
              },
              title: const Text('清除缓存'),
            ),
            const Divider(),
            androidDisplayModeSetting(),
            androidSecureFlagSetting(),
            authenticationSetting(),
            const Divider(),
            chooserRootSetting(),
            downloadThreadCountSetting(),
            downloadAndExportPathSetting(),
            showCommentAtDownloadSetting(),
            downloadCachePathSetting(),
            exportRenameSetting(),
            fontSetting(),
            usingRightClickPopSetting(),
            const Divider(),
            migrate(context),
            const Divider(),
          ],
        ),
      );

  Widget migrate(BuildContext context) {
    if (Platform.isAndroid) {
      return ListTile(
        title: Text(
          "文件迁移" + (!isPro ? "(发电)" : ""),
          style: TextStyle(
            color: !isPro ? Colors.grey : null,
          ),
        ),
        subtitle: const Text("更换您的数据文件夹到内存卡"),
        onTap: () async {
          if (!isPro) {
            defaultToast(context, "请先发电再使用");
            return;
          }
          var f =
              await confirmDialog(context, "文件迁移", "此功能菜单保存后, 需要重启程序, 您确认吗");
          if (f) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) {
                return const MigrateScreen();
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
