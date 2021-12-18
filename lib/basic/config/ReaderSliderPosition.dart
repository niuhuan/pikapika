import 'package:flutter/material.dart';
import 'package:pikapika/basic/Method.dart';

import '../Common.dart';

enum ReaderSliderPosition { BOTTOM, RIGHT, LEFT }

const _positionNames = {
  ReaderSliderPosition.BOTTOM: '下方',
  ReaderSliderPosition.RIGHT: '右侧',
  ReaderSliderPosition.LEFT: '左侧',
};

const _propertyName = "readerSliderPosition";
late ReaderSliderPosition _readerSliderPosition;

Future initReaderSliderPosition() async {
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
      await chooseMapDialog<ReaderSliderPosition>(context, map, "选择滑动条位置");
  if (result != null) {
    await method.saveProperty(_propertyName, result.toString());
    _readerSliderPosition = result;
  }
}

Widget readerSliderPositionSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text("滚动条的位置"),
        subtitle: Text(currentReaderSliderPositionName()),
        onTap: () async {
          await chooseReaderSliderPosition(context);
          setState(() {});
        },
      );
    },
  );
}
