import 'dart:io';

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "authentication";
late bool _authentication;

Future<void> initAuthentication() async {
  _authentication =
      (await method.loadProperty(_propertyName, "false")) == "true";
}

bool currentAuthentication() {
  return _authentication;
}

Future<void> _chooseAuthentication(BuildContext context) async {
  if (await method.verifyAuthentication()) {
    String? result =
        await chooseListDialog<String>(context, "进入APP时验证身份", ["是", "否"]);
    if (result != null) {
      var target = result == "是";
      await method.saveProperty(_propertyName, "$target");
      _authentication = target;
    }
  }
}

Widget authenticationSetting() {
  if (Platform.isIOS != true) {
    return Container();
  }
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("进入APP时验证身份"),
        subtitle: Text(_authentication ? "是" : "否"),
        onTap: () async {
          await _chooseAuthentication(context);
          setState(() {});
        },
      );
    },
  );
}
