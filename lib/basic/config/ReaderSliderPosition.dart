import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/Method.dart';

import '../Common.dart';

enum ReaderSliderPosition { BOTTOM, RIGHT, LEFT }

// const _positionNames = {
//   ReaderSliderPosition.BOTTOM: '下方',
//   ReaderSliderPosition.RIGHT: '右侧',
//   ReaderSliderPosition.LEFT: '左侧',
// };

Map<ReaderSliderPosition, String> _positionNames = {};

const _propertyName = "readerSliderPosition";
late ReaderSliderPosition _readerSliderPosition;

Future initReaderSliderPosition() async {
  _positionNames.addAll({
    ReaderSliderPosition.BOTTOM: tr("settings.reader_slider_position.bottom"),
    ReaderSliderPosition.RIGHT: tr("settings.reader_slider_position.right"),
    ReaderSliderPosition.LEFT: tr("settings.reader_slider_position.left"),
  });
  _readerSliderPosition = _readerSliderPositionFromString(
    await method.loadProperty(_propertyName, ""),
  );
}

ReaderSliderPosition _readerSliderPositionFromString(String str) {
  for (var value in ReaderSliderPosition.values) {
    if (str == value.toString()) return value;
  }
  return ReaderSliderPosition.BOTTOM;
}

ReaderSliderPosition currentReaderSliderPosition() => _readerSliderPosition;

String currentReaderSliderPositionName() =>
    _positionNames[_readerSliderPosition] ?? "";

Future<void> chooseReaderSliderPosition(BuildContext context) async {
  Map<String, ReaderSliderPosition> map = {};
  _positionNames.forEach((key, value) {
    map[value] = key;
  });
  ReaderSliderPosition? result =
      await chooseMapDialog<ReaderSliderPosition>(context, map, tr("settings.reader_slider_position.choose"));
  if (result != null) {
    await method.saveProperty(_propertyName, result.toString());
    _readerSliderPosition = result;
  }
}

Widget readerSliderPositionSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr("settings.reader_slider_position.title")),
        subtitle: Text(currentReaderSliderPositionName()),
        onTap: () async {
          await chooseReaderSliderPosition(context);
          setState(() {});
        },
      );
    },
  );
}
