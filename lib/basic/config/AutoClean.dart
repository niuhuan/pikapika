import 'package:flutter/material.dart';
import 'package:pikapi/basic/Method.dart';

late String _autoCleanSec;

Future<dynamic> autoClean() async {
  _autoCleanSec = await method.loadProperty("autoCleanSec", "${3600 * 24 * 30}");
  await method.autoClean(_autoCleanSec);
}

var _autoCleanMap = {
  "一个月前": "${3600 * 24 * 30}",
  "一周前": "${3600 * 24 * 7}",
  "一天前": "${3600 * 24 * 1}",
};

String currentAutoCleanSec() {
  for (var value in _autoCleanMap.entries) {
    if (value.value == _autoCleanSec) {
      return value.key;
    }
  }
  return "";
}

Future<void> chooseAutoCleanSec(BuildContext context) async {
  String? choose = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text('选择分流'),
        children: <Widget>[
          ..._autoCleanMap.entries.map(
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
    await method.saveProperty("autoCleanSec", choose);
    _autoCleanSec = choose;
  }
}
