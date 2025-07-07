import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';


final List<ReaderBackgroundColor> _colors = [];

//  [
//   ReaderBackgroundColor(
//     "黑色",
//     Colors.black,
//   ),
//   ReaderBackgroundColor(
//     "灰度",
//     Colors.grey,
//   ),
//   ReaderBackgroundColor(
//     "白色",
//     Colors.white,
//   ),
// ];

const _propertyName = "readerBackgroundColor";
late ReaderBackgroundColor readerBackgroundColor;

Color get readerBackgroundColorObj => readerBackgroundColor.color;

Future<void> initReaderBackgroundColor() async {
  _colors.addAll([
    ReaderBackgroundColor(tr("settings.reader_background_color.black"), Colors.black),
    ReaderBackgroundColor(tr("settings.reader_background_color.gray"), Colors.grey),
    ReaderBackgroundColor(tr("settings.reader_background_color.white"), Colors.white),
  ]);
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

Future<void> chooseReaderBackgroundColor(BuildContext context) async {
  Map<String, ReaderBackgroundColor> map = {};
  for (var element in _colors) {
    map[element.name] = element;
  }
  ReaderBackgroundColor? result = await chooseMapDialog<ReaderBackgroundColor>(
    context,
    map,
    tr("settings.reader_background_color.choose"),
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
        title: Text(tr("settings.reader_background_color.title")),
        subtitle: Text(readerBackgroundColor.name),
        onTap: () async {
          await chooseReaderBackgroundColor(context);
          setState(() {});
        },
      );
    },
  );
}
