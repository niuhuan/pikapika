import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../Method.dart';

const _propertyName = "eBookScrollingRange";

late int _eBookScrollingRange;

Future initEBookScrollingRange() async {
  _eBookScrollingRange =
      int.parse((await method.loadProperty(_propertyName, "80")));
}

double get eBookScrollingRange => _eBookScrollingRange / 100;

Widget eBookScrollingRangeSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr("settings.ebook_scrolling_range.title") + " - " + tr("settings.ebook_scrolling_range.desc") + " : $_eBookScrollingRange%${tr("settings.ebook_scrolling_range.screen_height")}"),
        subtitle: Slider(
          min: 30.toDouble(),
          max: 80.toDouble(),
          value: _eBookScrollingRange.toDouble(),
          onChanged: (double value) async {
            final va = value.toInt();
            await method.loadProperty(_propertyName, "$va");
            setState(() {
              _eBookScrollingRange = va;
            });
          },
          divisions: (80 - 30),
        ),
      );
    },
  );
}
