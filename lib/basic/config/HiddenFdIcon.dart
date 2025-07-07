import 'package:easy_localization/easy_localization.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import '../Method.dart';

const _propertyName = "hiddenFdIcon";

late bool _hiddenFdIcon;

 bool get hiddenFdIcon => _hiddenFdIcon;

var hiddenFdIconEvent = Event<EventArgs>();

Future initHiddenFdIcon() async {
  _hiddenFdIcon = (await method.loadProperty(_propertyName, "false")) == "true";
}

Widget hiddenFdIconSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        title:  Text(tr("settings.hidden_fd_icon.title")),
        value: _hiddenFdIcon,
        onChanged: (value) async {
          await method.saveProperty(_propertyName, "$value");
          _hiddenFdIcon = value;
          setState(() {});
          hiddenFdIconEvent.broadcast();
        },
      );
    },
  );
}
