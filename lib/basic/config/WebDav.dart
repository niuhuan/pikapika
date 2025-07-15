import 'package:pikapika/i18.dart';
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
      defaultToast(context, tr("settings.webdav.sync_failed"));
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
    defaultToast(context, tr("settings.webdav.sync_success"));
  } catch (e, s) {
    print("$e\n$s");
    defaultToast(context, tr("settings.webdav.sync_failed"));
  }
}

List<Widget> webDavSettings(BuildContext context) {
  return [
    //
    StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
            title: Text(
              tr("settings.webdav.path"),
            ),
            subtitle: Text(_webdavRoot),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _webdavRoot,
                title: tr("settings.webdav.path"),
                hint: tr("settings.webdav.path_hint"),
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
            title: Text(
              tr("settings.webdav.username"),
            ),
            subtitle: Text(_webdavUsername),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _webdavUsername,
                title: tr("settings.webdav.username"),
                hint: tr("settings.webdav.username_hint"),
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
            title: Text(
              tr("settings.webdav.password"),
            ),
            subtitle: Text(_webdavPassword),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _webdavPassword,
                title: tr("settings.webdav.password"),
                hint: tr("settings.webdav.password_hint"),
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
            tr("settings.webdav.auto_sync_history_to_webdav") + (isPro ? "" : "(${tr("app.pro")})"),
            style: TextStyle(
              color: !isPro ? Colors.grey : null,
            ),
          ),
          subtitle: Text(
            _autoSyncHistoryToWebdav ? tr("app.yes") : tr("app.no"),
            style: TextStyle(
              color: !isPro ? Colors.grey : null,
            ),
          ),
          onTap: () async {
            if (!isPro) {
              return;
            }
            String? result = await chooseListDialog<String>(
                context, tr("settings.webdav.auto_sync_history_to_webdav"), [tr("app.yes"), tr("app.no")]);
            if (result != null) {
              var target = result == tr("app.yes");
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
        title: Text(tr("settings.webdav.sync_history_to_webdav")),
        onTap: () async {
          await syncHistoryToWebdav(context);
        }),
  ];
}
