/// 阅读器的方向

import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/Method.dart';

enum ReaderTwoPageDirection {
  CLOSE_TO,
  PULL_AWAY,
  EACH_CENTERED,
}

// const _types = {
//   '靠近': ReaderTwoPageDirection.CLOSE_TO,
//   '远离': ReaderTwoPageDirection.PULL_AWAY,
//   '各自居中': ReaderTwoPageDirection.EACH_CENTERED,
// };

Map<ReaderTwoPageDirection, String> _types = {};

const _propertyName = "readerTwoPageDirection";
late ReaderTwoPageDirection gReaderTwoPageDirection;

Future<void> initReaderTwoPageDirection() async {
  _types.addAll({
    ReaderTwoPageDirection.CLOSE_TO: tr("settings.reader_two_page_direction.close_to"),
    ReaderTwoPageDirection.PULL_AWAY: tr("settings.reader_two_page_direction.pull_away"),
    ReaderTwoPageDirection.EACH_CENTERED: tr("settings.reader_two_page_direction.each_centered"),
  });
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
    if (e.key == gReaderTwoPageDirection) {
      return e.value;
    }
  }
  return '';
}

var gReaderTwoPageDirectionName  = _currentReaderTwoPageDirectionName;

/// ?? to ActionButton And Event ??
Future<void> chooseTwoPagerDirection(BuildContext buildContext) async {
  ReaderTwoPageDirection? choose = await showDialog<ReaderTwoPageDirection>(
    context: buildContext,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(tr("settings.reader_two_page_direction.choose")),
        children: _types.entries
            .map((e) => SimpleDialogOption(
                  child: Text(e.value),
                  onPressed: () {
                    Navigator.of(context).pop(e.key);
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
        title: Text(tr("settings.reader_two_page_direction.title")),
        subtitle: Text(_currentReaderTwoPageDirectionName()),
        onTap: () async {
          await chooseTwoPagerDirection(context);
          setState(() {});
        },
      );
    },
  );
}
