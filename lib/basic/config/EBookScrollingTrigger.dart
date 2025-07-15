import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';

import '../Method.dart';

const _propertyName = "eBookScrollingTrigger";

late double _eBookScrollingTrigger;

Future initEBookScrollingTrigger() async {
  _eBookScrollingTrigger =
      double.parse((await method.loadProperty(_propertyName, "0.3")));
}

double get eBookScrollingTrigger => _eBookScrollingTrigger;

Widget eBookScrollingTriggerSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr("settings.ebook_scrolling_trigger.title") + " - " + tr("settings.ebook_scrolling_trigger.desc") + " : $_eBookScrollingTrigger ${tr("settings.ebook_scrolling_trigger.cm")}"),
        subtitle: Slider(
          min: 0.1.toDouble(),
          max: 2.0.toDouble(),
          value: _eBookScrollingTrigger.toDouble(),
          onChanged: (double value) async {
            await method.saveProperty(_propertyName, "$value");
            setState((){
              _eBookScrollingTrigger = value;
            });
          },
          divisions: (20 - 1),
        ),
      );
    },
  );
}
