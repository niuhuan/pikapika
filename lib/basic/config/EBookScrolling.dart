import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../Method.dart';

const _propertyName = "eBookScrolling";

late bool _eBookScrolling;

bool get eBookScrolling => _eBookScrolling;

Future initEBookScrolling() async {
  _eBookScrolling =
      (await method.loadProperty(_propertyName, "false")) == "true";
}

Widget eBookScrollingSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        title: Text(tr("settings.ebook_scrolling.title")),
        value: _eBookScrolling,
        onChanged: (value) async {
          await method.saveProperty(_propertyName, "$value");
          _eBookScrolling = value;
          setState(() {});
        },
      );
    },
  );
}
