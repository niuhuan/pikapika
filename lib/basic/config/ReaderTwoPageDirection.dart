/// 阅读器的方向

import 'package:flutter/material.dart';
import 'package:pikapika/basic/Method.dart';

enum ReaderTwoPageDirection {
  CLOSE_TO,
  PULL_AWAY,
  EACH_CENTERED,
}

const _types = {
  '靠近': ReaderTwoPageDirection.CLOSE_TO,
  '远离': ReaderTwoPageDirection.PULL_AWAY,
  '各自居中': ReaderTwoPageDirection.EACH_CENTERED,
};

const _propertyName = "readerTwoPageDirection";
late ReaderTwoPageDirection gReaderTwoPageDirection;

Future<void> initReaderTwoPageDirection() async {
  gReaderTwoPageDirection = _pagerDirectionFromString(await method.loadProperty(
      _propertyName, ReaderTwoPageDirection.CLOSE_TO.toString()));
}

ReaderTwoPageDirection _pagerDirectionFromString(String pagerDirectionString) {
  for (var value in ReaderTwoPageDirection.values) {
    if (pagerDirectionString == value.toString()) {
      return value;
    }
  }
  return ReaderTwoPageDirection.CLOSE_TO;
}

String _currentReaderTwoPageDirectionName() {
  for (var e in _types.entries) {
    if (e.value == gReaderTwoPageDirection) {
      return e.key;
    }
  }
  return '';
}

var gReaderTwoPageDirectionName  = _currentReaderTwoPageDirectionName;

/// ?? to ActionButton And Event ??
Future<void> choosePagerDirection(BuildContext buildContext) async {
  ReaderTwoPageDirection? choose = await showDialog<ReaderTwoPageDirection>(
    context: buildContext,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text("选择翻页方向"),
        children: _types.entries
            .map((e) => SimpleDialogOption(
                  child: Text(e.key),
                  onPressed: () {
                    Navigator.of(context).pop(e.value);
                  },
                ))
            .toList(),
      );
    },
  );
  if (choose != null) {
    await method.saveProperty(_propertyName, choose.toString());
    gReaderTwoPageDirection = choose;
  }
}

Widget readerTwoPageDirectionSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("双页阅读器内容排列"),
        subtitle: Text(_currentReaderTwoPageDirectionName()),
        onTap: () async {
          await choosePagerDirection(context);
          setState(() {});
        },
      );
    },
  );
}
