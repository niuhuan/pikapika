import 'package:event/event.dart';
import 'package:flutter/material.dart';
import '../Method.dart';

const _propertyName = "hiddenSubIcon";

late bool _hiddenSubIcon;

bool get hiddenSubIcon => _hiddenSubIcon;

var hiddenSubIconEvent = Event<EventArgs>();

Future initHiddenSubIcon() async {
  _hiddenSubIcon =
      (await method.loadProperty(_propertyName, "false")) == "true";
}

Widget hiddenSubIconSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        title: const Text("隐藏订阅功能"),
        value: _hiddenSubIcon,
        onChanged: (value) async {
          await method.saveProperty(_propertyName, "$value");
          _hiddenSubIcon = value;
          setState(() {});
          hiddenSubIconEvent.broadcast();
          await method.removeAllSubscribed();
        },
      );
    },
  );
}
