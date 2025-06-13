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
        title: Text("自由放大阅读器翻页距离 : $_readerScrollByScreenPercentage%屏幕尺寸"),
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

