/// 自动清理

import 'package:flutter/material.dart';
import 'package:pikapika/basic/Method.dart';

const _lockTimeOutMap = {
  "一小时": "${60 * 60}",
  "十分钟": "${60 * 10}",
  "三分钟": "${60 * 3}",
  "一分钟": "${60}",
  "十秒": "${10}",
  "一秒": "${1}",
  "不锁定": "${0}",
};
late String _lockTimeOutSec;

int get timeoutLock => int.tryParse(_lockTimeOutSec) ?? 0;

Future<dynamic> initLockTimeOut() async {
  _lockTimeOutSec = await method.loadProperty("lockTimeOutSec", "${0}");
}

String _currentLockTimeOutSec() {
  for (var value in _lockTimeOutMap.entries) {
    if (value.value == _lockTimeOutSec) {
      return value.key;
    }
  }
  return "$_lockTimeOutSec 秒";
}

Future<void> _chooseLockTimeOutSec(BuildContext context) async {
  String? choose = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text('多久后自动锁定'),
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
        title: const Text("自动锁定"),
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
  return const ListTile(
    subtitle: Text("注意：自动锁定在桌面端仅支持最小化后超时，手机端支持后台以及锁屏后超时。如果没有设置密码，自动锁定无效。安卓以及桌面端只会锁定桌面，不会锁定下载，iOS未测试，需要手动开启后台活动。"),
  );
}
