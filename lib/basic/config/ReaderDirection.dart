/// 阅读器的方向

import 'package:flutter/material.dart';
import 'package:pikapi/basic/Method.dart';

enum ReaderDirection {
  TOP_TO_BOTTOM,
  LEFT_TO_RIGHT,
  RIGHT_TO_LEFT,
}

late ReaderDirection gReaderDirection;

const _propertyName = "readerDirection";

Future<void> initReaderDirection() async {
  gReaderDirection = _pagerDirectionFromString(await method.loadProperty(
      _propertyName, ReaderDirection.TOP_TO_BOTTOM.toString()));
}

var _types = {
  '从上到下': ReaderDirection.TOP_TO_BOTTOM,
  '从左到右': ReaderDirection.LEFT_TO_RIGHT,
  '从右到左': ReaderDirection.RIGHT_TO_LEFT,
};

ReaderDirection _pagerDirectionFromString(String pagerDirectionString) {
  for (var value in ReaderDirection.values) {
    if (pagerDirectionString == value.toString()) {
      return value;
    }
  }
  return ReaderDirection.TOP_TO_BOTTOM;
}

String currentReaderDirectionName() {
  for (var e in _types.entries) {
    if (e.value == gReaderDirection) {
      return e.key;
    }
  }
  return '';
}

Future<void> choosePagerDirection(BuildContext buildContext) async {
  ReaderDirection? choose = await showDialog<ReaderDirection>(
    context: buildContext,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text("选择翻页方向"),
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
    gReaderDirection = choose;
  }
}

Widget readerDirectionSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text("阅读器方向"),
        subtitle: Text(currentReaderDirectionName()),
        onTap: () async {
          await choosePagerDirection(context);
          setState(() {});
        },
      );
    },
  );
}
