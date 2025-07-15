import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';

import '../Method.dart';

const _propertyName = "readerScrollByScreenPercentage";

late int _readerScrollByScreenPercentage;

Future initReaderScrollByScreenPercentage() async {
  _readerScrollByScreenPercentage =
      int.parse((await method.loadProperty(_propertyName, "80")));
}

double get readerScrollByScreenPercentage => _readerScrollByScreenPercentage / 100;

Widget readerScrollByScreenPercentageSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr("settings.reader_scroll_by_screen_percentage.title") + " : $_readerScrollByScreenPercentage%" + tr("settings.reader_scroll_by_screen_percentage.screen_size")),
        subtitle: Slider(
          min: 5.toDouble(),
          max: 110.toDouble(),
          value: _readerScrollByScreenPercentage.toDouble(),
          onChanged: (double value) async {
            final va = value.toInt();
            await method.loadProperty(_propertyName, "$va");
            setState(() {
              _readerScrollByScreenPercentage = va;
            });
          },
          divisions: (110 - 5),
        ),
      );
    },
  );
}

