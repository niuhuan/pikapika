/// 自动清理

import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/Method.dart';

// const _lockTimeOutMap = {
//   "一小时": "${60 * 60}",
//   "十分钟": "${60 * 10}",
//   "三分钟": "${60 * 3}",
//   "一分钟": "${60}",
//   "十秒": "${10}",
//   "一秒": "${1}",
//   "不锁定": "${0}",
// };

Map<String, String> _lockTimeOutMap = {};

late String _lockTimeOutSec;

int get timeoutLock => int.tryParse(_lockTimeOutSec) ?? 0;

Future<dynamic> initLockTimeOut() async {
  _lockTimeOutMap.addAll({
    tr("settings.timeout_lock.1_hour"): "${60 * 60}",
    tr("settings.timeout_lock.10_minutes"): "${60 * 10}",
    tr("settings.timeout_lock.3_minutes"): "${60 * 3}",
    tr("settings.timeout_lock.1_minute"): "${60}",
    tr("settings.timeout_lock.10_seconds"): "${10}",
    tr("settings.timeout_lock.1_second"): "${1}",
    tr("settings.timeout_lock.no_lock"): "${0}",
  });
  _lockTimeOutSec = await method.loadProperty("lockTimeOutSec", "${0}");
}

String _currentLockTimeOutSec() {
  for (var value in _lockTimeOutMap.entries) {
    if (value.value == _lockTimeOutSec) {
      return value.key;
    }
  }
  return "$_lockTimeOutSec seconds";
}

Future<void> _chooseLockTimeOutSec(BuildContext context) async {
  String? choose = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(tr("settings.timeout_lock.title")),
        children: <Widget>[
          ..._lockTimeOutMap.entries.map(
            (e) => SimpleDialogOption(
              child: Text(e.key),
              onPressed: () {
                Navigator.of(context).pop(e.value);
              },
            ),
          ),
        ],
      );
    },
  );
  if (choose != null) {
    await method.saveProperty("lockTimeOutSec", choose);
    _lockTimeOutSec = choose;
  }
}

Widget lockTimeOutSecSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr("settings.timeout_lock.title")),
        subtitle: Text(_currentLockTimeOutSec()),
        onTap: () async {
          await _chooseLockTimeOutSec(context);
          setState(() {});
        },
      );
    },
  );
}

Widget lockTimeOutSecNotice() {
  return ListTile(
    subtitle: Text(tr("settings.timeout_lock.notice")),
  );
}
