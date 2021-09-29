import 'package:flutter/material.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/config/Themes.dart';
import 'package:pikapi/screens/AboutScreen.dart';
import 'package:pikapi/screens/AccountScreen.dart';
import 'package:pikapi/screens/DownloadListScreen.dart';
import 'package:pikapi/screens/FavouritePaperScreen.dart';
import 'package:pikapi/screens/ViewLogsScreen.dart';
import 'package:pikapi/basic/Method.dart';

import 'SettingsScreen.dart';
import 'components/UserProfileCard.dart';

// 个人空间页面
class SpaceScreen extends StatefulWidget {
  const SpaceScreen();

  @override
  State<StatefulWidget> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends State<SpaceScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的'),
        actions: [
          IconButton(
            onPressed: () async {
              bool result =
                  await confirmDialog(context, '退出登录', '您确认要退出当前账号吗?');
              if (result) {
                await method.clearToken();
                await method.setPassword("");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AccountScreen()),
                );
              }
            },
            icon: Icon(Icons.exit_to_app),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutScreen()),
              );
            },
            icon: Icon(Icons.info_outline),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView(
        children: [
          Divider(),
          UserProfileCard(),
          Divider(),
          ListTile(
            onTap: () async {
              await chooseTheme(context);
              setState(() {});
            },
            title: Text('主题'),
            subtitle: Text(currentThemeName()),
          ),
          Divider(),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavouritePaperScreen()),
              );
            },
            title: Text('我的收藏'),
          ),
          Divider(),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewLogsScreen()),
              );
            },
            title: Text('浏览记录'),
          ),
          Divider(),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DownloadListScreen()),
              );
            },
            title: Text('我的下载'),
          ),
          Divider(),
        ],
      ),
    );
  }
}
