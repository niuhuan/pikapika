/// 阅读器的方向

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/Method.dart';

enum ReaderDirection {
  TOP_TO_BOTTOM,
  LEFT_TO_RIGHT,
  RIGHT_TO_LEFT,
}

// const _types = {
//   '从上到下': ReaderDirection.TOP_TO_BOTTOM,
//   '从左到右': ReaderDirection.LEFT_TO_RIGHT,
//   '从右到左': ReaderDirection.RIGHT_TO_LEFT,
// };

Map<String, ReaderDirection> _types = {};

const _propertyName = "readerDirection";
late ReaderDirection gReaderDirection;

Future<void> initReaderDirection() async {
  _types.addAll({
    tr("settings.reader_direction.top_to_bottom"): ReaderDirection.TOP_TO_BOTTOM,
    tr("settings.reader_direction.left_to_right"): ReaderDirection.LEFT_TO_RIGHT,
    tr("settings.reader_direction.right_to_left"): ReaderDirection.RIGHT_TO_LEFT,
  });
  gReaderDirection = _pagerDirectionFromString(await method.loadProperty(
      _propertyName, ReaderDirection.TOP_TO_BOTTOM.toString()));
}

ReaderDirection _pagerDirectionFromString(String pagerDirectionString) {
  for (var value in ReaderDirection.values) {
    if (pagerDirectionString == value.toString()) {
      return value;
    }
  }
  return ReaderDirection.TOP_TO_BOTTOM;
}

String _currentReaderDirectionName() {
  for (var e in _types.entries) {
    if (e.value == gReaderDirection) {
      return e.key;
    }
  }
  return '';
}

var gReaderDirectionName  = _currentReaderDirectionName;

/// ?? to ActionButton And Event ??
Future<void> choosePagerDirection(BuildContext buildContext) async {
  ReaderDirection? choose = await showDialog<ReaderDirection>(
    context: buildContext,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(tr("settings.reader_direction.choose")),
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
        title: Text(tr("settings.reader_direction.title")),
        subtitle: Text(_currentReaderDirectionName()),
        onTap: () async {
          await choosePagerDirection(context);
          setState(() {});
        },
      );
    },
  );
}
