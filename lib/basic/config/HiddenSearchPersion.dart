import 'package:easy_localization/easy_localization.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import '../Method.dart';

const _propertyName = "hiddenSearchPersion";

late bool _hiddenSearchPersion;

bool get hiddenSearchPersion => _hiddenSearchPersion;

var hiddenSearchPersionEvent = Event<EventArgs>();

Future initHiddenSearchPersion() async {
  _hiddenSearchPersion =
      (await method.loadProperty(_propertyName, "false")) == "true";
}

Widget hiddenSearchPersionSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        title: Text(tr("settings.hidden_search_persion.title")),
        value: _hiddenSearchPersion,
        onChanged: (value) async {
          await method.saveProperty(_propertyName, "$value");
          _hiddenSearchPersion = value;
          setState(() {});
          hiddenSearchPersionEvent.broadcast();
          await method.removeAllSubscribed();
        },
      );
    },
  );
}
