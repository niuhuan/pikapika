import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/basic/config/IsPro.dart';
import 'package:pikapika/basic/config/Themes.dart';
import 'package:pikapika/basic/enum/ErrorTypes.dart';
import 'package:pikapika/screens/RegisterScreen.dart';
import 'package:pikapika/screens/SettingsScreen.dart';
import 'package:pikapika/screens/components/NetworkSetting.dart';

import '../basic/config/Version.dart';
import 'AppScreen.dart';
import 'DownloadListScreen.dart';
import 'ThemeScreen.dart';
import 'components/ContentLoading.dart';

// 账户设置
class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late bool _logging = false;
  late String _username = "";
  late String _password = "";
  late StreamSubscription<String?> _linkSubscription;

  @override
  void initState() {
    _linkSubscription = linkSubscript(context);
    versionEvent.subscribe(_versionSub);
    versionPop(context);
    _loadProperties();
    super.initState();
  }

  @override
  void dispose() {
    _linkSubscription.cancel();
    versionEvent.unsubscribe(_versionSub);
    super.dispose();
  }

  _versionSub(_) {
    versionPop(context);
  }


  Future _loadProperties() async {
    var username = await method.getUsername();
    var password = await method.getPassword();
    setState(() {
      _username = username;
      _password = password;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_logging) {
      return _buildLogging();
    }
    return _buildGui();
  }

  Widget _buildLogging() {
    return const Scaffold(
      body: ContentLoading(label: '登录中'),
    );
  }

  Widget _buildGui() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配置选项'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(
                    hiddenAccountInfo: true,
                  ),
                ),
              );
            },
            icon: const Text('设置'),
          ),
          IconButton(
            onPressed: () {
              if (androidNightModeDisplay) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ThemeScreen()),
                );
              } else {
                chooseLightTheme(context);
              }
            },
            icon: const Text('主题'),
          ),
          IconButton(
            onPressed: _toDownloadList,
            icon: const Icon(Icons.download_rounded),
          ),
          IconButton(
            onPressed: _logIn,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("账号"),
            subtitle: Text(_username == "" ? "未设置" : _username),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _username,
                title: '账号',
                hint: '请输入账号',
              );
              if (input != null) {
                await method.setUsername(input);
                setState(() {
                  _username = input;
                });
              }
            },
          ),
          ListTile(
            title: const Text("密码"),
            subtitle: Text(_password == "" ? "未设置" : '\u2022' * 10),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _password,
                title: '密码',
                hint: '请输入密码',
                isPasswd: true,
              );
              if (input != null) {
                await method.setPassword(input);
                setState(() {
                  _password = input;
                });
              }
            },
          ),
          const NetworkSetting(),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Text.rich(TextSpan(
                    text: '没有账号,我要注册',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const RegisterScreen()),
                          ).then((value) => _loadProperties()),
                  )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _logIn() async {
    setState(() {
      _logging = true;
    });
    try {
      await method.login();
      await reloadIsPro();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AppScreen()),
      );
    } catch (e, s) {
      print("$e\n$s");
      setState(() {
        _logging = false;
      });
      var message = "请检查账号密码或网络环境";
      switch (errorType("$e")) {
        case ERROR_TYPE_NETWORK:
          message = "网络不通";
          break;
        case ERROR_TYPE_TIME:
          message = "请检查设备时间";
          break;
      }
      if ("$e".contains("email") && "$e".contains("password")) {
        message = "请检查账号密码";
      }
      alertDialog(
        context,
        '登录失败',
        "$message\n$e",
      );
    }
  }

  _toDownloadList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DownloadListScreen()),
    );
  }
}
