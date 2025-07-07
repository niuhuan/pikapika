/// 时区设置

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "timeOffsetHour";
int _timeOffsetHour = 8;

Future<void> initTimeZone() async {
  _timeOffsetHour = int.parse(await method.loadProperty(_propertyName, "8"));
}

int currentTimeOffsetHour() {
  return _timeOffsetHour;
}

Future<void> _chooseTimeZone(BuildContext context) async {
  List<String> timeZones = [];
  for (var i = -12; i <= 12; i++) {
    var str = i.toString();
    if (!str.startsWith("-")) {
      str = "+" + str;
    }
    timeZones.add(str);
  }
  String? result = await chooseListDialog<String>(context, tr("settings.time_zone.title"), timeZones);
  if (result != null) {
    if (result.startsWith("+")) {
      result = result.substring(1);
    }
    _timeOffsetHour = int.parse(result);
    await method.saveProperty(_propertyName, result);
  }
}

Widget timeZoneSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      var c = "$_timeOffsetHour";
      if (!c.startsWith("-")) {
        c = "+" + c;
      }
      return ListTile(
        title: Text(tr("settings.time_zone.title")),
        subtitle: Text(c),
        onTap: () async {
          await _chooseTimeZone(context);
          setState(() {});
        },
      );
    },
  );
}
