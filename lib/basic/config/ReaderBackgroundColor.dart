import 'dart:ui';

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "readerBackgroundColor";
late ReaderBackgroundColor readerBackgroundColor;

Color get readerBackgroundColorObj => readerBackgroundColor.color;

Future<void> initReaderBackgroundColor() async {
  readerBackgroundColor =
      _readerBackgroundColorFromString(await method.loadProperty(
    _propertyName,
    _colors[0].name,
  ));
}

ReaderBackgroundColor _readerBackgroundColorFromString(String string) {
  for (var value in _colors) {
    if (string == value.name) {
      return value;
    }
  }
  return _colors[0];
}

class ReaderBackgroundColor {
  final String name;
  final Color color;

  ReaderBackgroundColor(this.name, this.color);
}

final List<ReaderBackgroundColor> _colors = [
  ReaderBackgroundColor(
    "黑色",
    Colors.black,
  ),
  ReaderBackgroundColor(
    "灰度",
    Colors.grey,
  ),
  ReaderBackgroundColor(
    "白色",
    Colors.white,
  ),
];

Future<void> chooseReaderBackgroundColor(BuildContext context) async {
  Map<String, ReaderBackgroundColor> map = {};
  for (var element in _colors) {
    map[element.name] = element;
  }
  ReaderBackgroundColor? result = await chooseMapDialog<ReaderBackgroundColor>(
    context,
    map,
    "选择阅读器背景色",
  );
  if (result != null) {
    await method.saveProperty(_propertyName, result.name);
    readerBackgroundColor = result;
  }
}

Widget readerBackgroundColorSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("阅读器背景色"),
        subtitle: Text(readerBackgroundColor.name),
        onTap: () async {
          await chooseReaderBackgroundColor(context);
          setState(() {});
        },
      );
    },
  );
}
