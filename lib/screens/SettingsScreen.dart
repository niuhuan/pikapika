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
import 'package:pikapika/basic/config/VolumeController.dart';
import 'package:pikapika/basic/config/ShadowCategoriesMode.dart';
import 'package:pikapika/screens/components/NetworkSetting.dart';
import 'package:pikapika/screens/components/RightClickPop.dart';

import '../basic/config/Authentication.dart';
import '../basic/config/CategoriesColumnCount.dart';
import '../basic/config/DownloadCachePath.dart';
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

  late var _index = 0;

  Widget buildScreen(BuildContext context) {
    final List<_IconAndWidgets> iaws = [
      _IconAndWidgets(Icons.lan, [
        const Padding(padding: EdgeInsets.only(top: 15)),
        const Divider(),
        const ListTile(
          subtitle: Text("网络&账户"),
        ),
        const Divider(),
        widget.hiddenAccountInfo
            ? Container()
            : ListTile(
                onTap: () async {
                  Navigator.push(
                    context,
                    mixRoute(
                      builder: (context) => const ModifyPasswordScreen(),
                    ),
                  );
                },
                title: const Text('修改密码'),
              ),
        const Divider(),
        const NetworkSetting(),
        const Padding(padding: EdgeInsets.only(top: 15)),
        const Divider(),
        const ListTile(
          subtitle: Text("同步"),
        ),
        ...webDavSettings(context),
        const Divider(),
        const Padding(padding: EdgeInsets.only(top: 15)),
      ]),
      _IconAndWidgets(Icons.ad_units, [
        const Padding(padding: EdgeInsets.only(top: 15)),
        const Divider(),
        const ListTile(
          subtitle: Text("系统&界面"),
        ),
        const Divider(),
        ListTile(
          onTap: () async {
            if (androidNightModeDisplay) {
              Navigator.push(
                context,
                mixRoute(builder: (context) => const ThemeScreen()),
              );
            } else {
              chooseLightTheme(context);
            }
          },
          title: const Text('主题'),
        ),
        fullScreenUISetting(),
        noAnimationSetting(),
        iconLoadingSetting(),
        categoriesColumnCountSetting(),
        willPopNoticeSetting(),
        pagerActionSetting(),
        contentFailedReloadActionSetting(),
        timeZoneSetting(),
        fontSetting(),
        usingRightClickPopSetting(),
        const Divider(),
        androidDisplayModeSetting(),
        androidSecureFlagSetting(),
        authenticationSetting(),
        const Divider(),
        migrate(context),
        const Divider(),
        const Padding(padding: EdgeInsets.only(top: 15)),
      ]),
      _IconAndWidgets(Icons.confirmation_num_rounded, [
        const Divider(),
        const Padding(padding: EdgeInsets.only(top: 15)),
        const Divider(),
        const ListTile(
          subtitle: Text("内容&阅读器"),
        ),
        const Divider(),
        shadowCategoriesModeSetting(),
        shadowCategoriesSetting(),
        const Divider(),
        qualitySetting(),
        readerTypeSetting(),
        readerDirectionSetting(),
        readerSliderPositionSetting(),
        autoFullScreenSetting(),
        fullScreenActionSetting(),
        volumeControllerSetting(),
        keyboardControllerSetting(),
        const Divider(),
        const Padding(padding: EdgeInsets.only(top: 15)),
      ]),
      _IconAndWidgets(Icons.download, [
        const Padding(padding: EdgeInsets.only(top: 15)),
        const Divider(),
        const ListTile(
          subtitle: Text("下载&缓存"),
        ),
        const Divider(),
        ListTile(
          title: const Text("启动Web服务器"),
          subtitle: const Text("让局域网内的设备通过浏览器看下载的漫画"),
          onTap: (){
            Navigator.of(context).push(
              mixRoute(
                builder: (BuildContext context) =>
                    const WebServerScreen(),
              ),
            );

          },
        ),
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
        chooserRootSetting(),
        downloadThreadCountSetting(),
        downloadAndExportPathSetting(),
        showCommentAtDownloadSetting(),
        exportRenameSetting(),
        const Divider(),
        downloadCachePathSetting(),
        importViewLogFromOff(),
        const Divider(),
        const Padding(padding: EdgeInsets.only(top: 15)),
      ]),
    ];
    var i = 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        actions: [
          ...iaws.map(
            (e) {
              final idx = i;
              return Opacity(
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _index = idx;
                    });
                  },
                  icon: Icon(e.icon),
                ),
                opacity: i++ == _index ? 1 : .75,
              );
            },
          )
        ],
      ),
      body: ListView(
        children: iaws[_index].widgets,
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
