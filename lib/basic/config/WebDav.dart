import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';
import 'IsPro.dart';

const _webdavRootPropertyName = "webdavRoot";
const _webdavUsernamePropertyName = "webdavUsername";
const _webdavPasswordPropertyName = "webdavPassword";
const _autoSyncHistoryToWebdavPropertyName = "autoSyncHistoryToWebdav";

late String _webdavRoot;
late String _webdavUsername;
late String _webdavPassword;
late bool _autoSyncHistoryToWebdav;

Future initWebDav() async {
  _webdavRoot = await method.loadProperty(
    _webdavRootPropertyName,
    "https://your.dav.host/folder",
  );
  _webdavUsername = await method.loadProperty(
    _webdavUsernamePropertyName,
    "",
  );
  _webdavPassword = await method.loadProperty(
    _webdavPasswordPropertyName,
    "",
  );
  if (!isPro) {
    _autoSyncHistoryToWebdav = false;
    return;
  }
  _autoSyncHistoryToWebdav = await method.loadProperty(
        _autoSyncHistoryToWebdavPropertyName,
        "false",
      ) ==
      "true";
}

Future syncWebDavIfAuto(BuildContext context) async {
  if (_autoSyncHistoryToWebdav) {
    try {
      await method.mergeHistoriesFromWebDav(
        _webdavRoot,
        _webdavUsername,
        _webdavPassword,
        "pk.histories",
      );
    } catch (e, s) {
      print("$e\n$s");
      defaultToast(context, "WebDav没有同步成功\n$e");
    }
  }
}

Future syncHistoryToWebdav(BuildContext context) async {
  try {
    await method.mergeHistoriesFromWebDav(
      _webdavRoot,
      _webdavUsername,
      _webdavPassword,
      "pk.histories",
    );
    defaultToast(context, "同步成功");
  } catch (e, s) {
    print("$e\n$s");
    defaultToast(context, "没有同步成功\n$e");
  }
}

List<Widget> webDavSettings(BuildContext context) {
  return [
    //
    StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
            title: const Text(
              "WebDav 路径 （文件夹）",
            ),
            subtitle: Text(_webdavRoot),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _webdavRoot,
                title: 'WebDav 路径',
                hint: '请输入WebDav 路径',
              );
              if (input != null) {
                await method.saveProperty(_webdavRootPropertyName, input);
                setState(() {
                  _webdavRoot = input;
                });
              }
            });
      },
    ),
    //
    StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
            title: const Text(
              "WebDav 用户名",
            ),
            subtitle: Text(_webdavUsername),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _webdavUsername,
                title: 'WebDav 用户名',
                hint: '请输入WebDav 用户名',
              );
              if (input != null) {
                await method.saveProperty(_webdavUsernamePropertyName, input);
                setState(() {
                  _webdavUsername = input;
                });
              }
            });
      },
    ),
    //
    StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
            title: const Text(
              "WebDav 密码",
            ),
            subtitle: Text(_webdavPassword),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _webdavPassword,
                title: 'WebDav 密码',
                hint: '请输入WebDav 密码',
              );
              if (input != null) {
                await method.saveProperty(_webdavPasswordPropertyName, input);
                setState(() {
                  _webdavPassword = input;
                });
              }
            });
      },
    ),
    //
    StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
          title: Text(
            "开启时自动同步浏览记录到WebDav" + (isPro ? "" : "(发电)"),
            style: TextStyle(
              color: !isPro ? Colors.grey : null,
            ),
          ),
          subtitle: Text(
            _autoSyncHistoryToWebdav ? "是" : "否",
            style: TextStyle(
              color: !isPro ? Colors.grey : null,
            ),
          ),
          onTap: () async {
            if (!isPro) {
              return;
            }
            String? result = await chooseListDialog<String>(
                context, "开启时自动同步浏览记录到WebDav", ["是", "否"]);
            if (result != null) {
              var target = result == "是";
              await method.saveProperty(
                  _autoSyncHistoryToWebdavPropertyName, "$target");
              _autoSyncHistoryToWebdav = target;
            }
            setState(() {});
          },
        );
      },
    ),
    //
    ListTile(
        title: const Text("立即同步浏览记录到WebDAV"),
        onTap: () async {
          await syncHistoryToWebdav(context);
        }),
  ];
}
