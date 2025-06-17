import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapika/basic/config/Platform.dart';
import 'package:pikapika/screens/DesktopAuthenticationScreen.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "authentication";
late bool _authentication;

Future<void> initAuthentication() async {
  if (Platform.isIOS || androidVersion >= 29) {
    _authentication =
        (await method.loadProperty(_propertyName, "false")) == "true";
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    _authentication = await needDesktopAuthentication();
  } else {
    _authentication = false;
  }
}

bool currentAuthentication() {
  return _authentication;
}

Future<bool> verifyAuthentication(BuildContext context) async {
  if (Platform.isIOS || androidVersion >= 29) {
    return await method.verifyAuthentication();
  }
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    return await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const VerifyPassword())) ==
        true;
  }
  return false;
}

Widget authenticationSetting() {
  if (Platform.isIOS || androidVersion >= 29) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return SwitchListTile(
          value: _authentication,
          title: const Text("进入APP时验证身份(如果系统已经录入密码或指纹)"),
          onChanged: (target) async {
            await method.saveProperty(_propertyName, "$target");
            _authentication = target;
            setState(() {});
          },
        );
      },
    );
  }
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    return StatefulBuilder(builder: (
      BuildContext context,
      void Function(void Function()) setState,
    ) {
      return ListTile(
        title: const Text("设置应用程序密码"),
        onTap: () async {
          await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SetPassword()));
          await initAuthentication();
        },
      );
    });
  }
  return Container();
}
