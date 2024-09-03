import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/config/AndroidDisplayMode.dart';
import 'package:pikapika/basic/config/AndroidSecureFlag.dart';
import 'package:pikapika/basic/config/AutoClean.dart';
import 'package:pikapika/basic/config/AutoFullScreen.dart';
import 'package:pikapika/basic/config/ChooserRoot.dart';
import 'package:pikapika/basic/config/ContentFailedReloadAction.dart';
import 'package:pikapika/basic/config/CopySkipConfirm.dart';
import 'package:pikapika/basic/config/DownloadAndExportPath.dart';
import 'package:pikapika/basic/config/DownloadThreadCount.dart';
import 'package:pikapika/basic/config/EBookScrollingRange.dart';
import 'package:pikapika/basic/config/EBookScrollingTrigger.dart';
import 'package:pikapika/basic/config/ExportRename.dart';
import 'package:pikapika/basic/config/FullScreenAction.dart';
import 'package:pikapika/basic/config/FullScreenUI.dart';
import 'package:pikapika/basic/config/IconLoading.dart';
import 'package:pikapika/basic/config/IsPro.dart';
import 'package:pikapika/basic/config/KeyboardController.dart';
import 'package:pikapika/basic/config/NoAnimation.dart';
import 'package:pikapika/basic/config/PagerAction.dart';
import 'package:pikapika/basic/config/Quality.dart';
import 'package:pikapika/basic/config/ReaderBackgroundColor.dart';
import 'package:pikapika/basic/config/ReaderDirection.dart';
import 'package:pikapika/basic/config/ReaderSliderPosition.dart';
import 'package:pikapika/basic/config/ReaderType.dart';
import 'package:pikapika/basic/config/ShadowCategories.dart';
import 'package:pikapika/basic/config/ShadowCategoriesMode.dart';
import 'package:pikapika/basic/config/ShowCommentAtDownload.dart';
import 'package:pikapika/basic/config/Themes.dart';
import 'package:pikapika/basic/config/TimeOffsetHour.dart';
import 'package:pikapika/basic/config/VolumeController.dart';
import 'package:pikapika/basic/config/VolumeNextChapter.dart';
import 'package:pikapika/screens/components/NetworkSetting.dart';
import 'package:pikapika/screens/components/RightClickPop.dart';

import '../basic/config/Authentication.dart';
import '../basic/config/CategoriesColumnCount.dart';
import '../basic/config/CategoriesSort.dart';
import '../basic/config/DownloadCachePath.dart';
import '../basic/config/EBookScrolling.dart';
import '../basic/config/HiddenFdIcon.dart';
import '../basic/config/HiddenSubIcon.dart';
import '../basic/config/ImageFilter.dart';
import '../basic/config/LocalHistorySync.dart';
import '../basic/config/TimeoutLock.dart';
import '../basic/config/UsingRightClickPop.dart';
import '../basic/config/WebDav.dart';
import '../basic/config/WillPopNotice.dart';
import 'CleanScreen.dart';
import 'MigrateScreen.dart';
import 'ModifyPasswordScreen.dart';
import 'ThemeScreen.dart';
import 'WebServerScreen.dart';

class SettingsScreen extends StatefulWidget {
  final bool hiddenAccountInfo;

  const SettingsScreen({Key? key, this.hiddenAccountInfo = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return rightClickPop(
      child: buildScreen(context),
      context: context,
      canPop: true,
    );
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ExpansionTile(
              leading: const Icon(Icons.ad_units),
              title: const Text('界面'),
              children: [
                const Divider(),
                ...themeWidgets(context, setState),
                const Divider(),
                pagerActionSetting(),
                contentFailedReloadActionSetting(),
                willPopNoticeSetting(),
                categoriesColumnCountSetting(),
                categoriesSortSetting(),
                const Divider(),
                timeZoneSetting(),
                fontSetting(),
                fullScreenUISetting(),
                usingRightClickPopSetting(),
                hiddenFdIconSetting(),
                hiddenSubIconSetting(),
                const Divider(),
                copySkipConfirmSetting(),
                iconLoadingSetting(),
                eBookScrollingSetting(),
                eBookScrollingRangeSetting(),
                eBookScrollingTriggerSetting(),
                const Divider(),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.lan),
              title: Text('网络'),
              children: [
                const Divider(),
                const NetworkSetting(),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.dangerous),
              title: Text('封印'),
              children: [
                const Divider(),
                shadowCategoriesModeSetting(),
                shadowCategoriesSetting(),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.menu_book_outlined),
              title: Text('阅读'),
              children: [
                const Divider(),
                qualitySetting(),
                readerTypeSettings(),
                readerDirectionSetting(),
                readerSliderPositionSetting(),
                autoFullScreenSetting(),
                fullScreenActionSetting(),
                volumeControllerSetting(),
                volumeNextChapterSetting(),
                keyboardControllerSetting(),
                const Divider(),
                noAnimationSetting(),
                imageFilterSetting(),
                readerBackgroundColorSetting(),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.download),
              title: Text('下载'),
              children: [
                const Divider(),
                ListTile(
                  title: const Text("启动Web服务器"),
                  subtitle: const Text("让局域网内的设备通过浏览器看下载的漫画"),
                  onTap: () {
                    Navigator.of(context).push(
                      mixRoute(
                        builder: (BuildContext context) =>
                            const WebServerScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                chooserRootSetting(),
                downloadThreadCountSetting(),
                downloadAndExportPathSetting(),
                showCommentAtDownloadSetting(),
                exportRenameSetting(),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.backup),
              title: Text('同步'),
              children: [
                const Divider(),
                ...webDavSettings(context),
                if (!Platform.isIOS) const Divider(),
                ...Platform.isIOS ? [] : localHistorySyncTiles(),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.manage_accounts),
              title: Text('账户'),
              children: [
                const Divider(),
                widget.hiddenAccountInfo
                    ? Container()
                    : ListTile(
                  onTap: () async {
                    Navigator.push(
                      context,
                      mixRoute(
                        builder: (context) =>
                        const ModifyPasswordScreen(),
                      ),
                    );
                  },
                  title: const Text('修改密码'),
                ),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.ad_units),
              title: Text('系统'),
              children: [
                const Divider(),
                androidDisplayModeSetting(),
                androidSecureFlagSetting(),
                authenticationSetting(),
                lockTimeOutSecSetting(),
                lockTimeOutSecNotice(),
                const Divider(),
                autoCleanSecSetting(),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      mixRoute(builder: (context) => const CleanScreen()),
                    );
                  },
                  title: const Text('清除缓存'),
                ),
                const Divider(),
                migrate(context),
                const Divider(),
                downloadCachePathSetting(),
                importViewLogFromOff(),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
              mixRoute(builder: (BuildContext context) {
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

class _IconAndWidgets {
  final IconData icon;
  final List<Widget> widgets;

  _IconAndWidgets(this.icon, this.widgets);
}
