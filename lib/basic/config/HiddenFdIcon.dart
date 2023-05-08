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
        title: const Text("隐藏个人空间的发电图标"),
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
