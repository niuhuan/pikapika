/// 代理设置

import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

late String _currentProxy;

Future<String?> initProxy() async {
  _currentProxy = await method.getProxy();
  return null;
}

String currentProxyName() {
  return _currentProxy == "" ? tr("settings.proxy.no_proxy") : _currentProxy;
}

Future<dynamic> inputProxy(BuildContext context) async {
  String? input = await displayTextInputDialog(
    context,
    src: _currentProxy,
    title: tr("settings.proxy.title"),
    hint: tr("settings.proxy.hint"),
    desc: tr("settings.proxy.desc"),
  );
  if (input != null) {
    await method.setProxy(input);
    _currentProxy = input;
  }
}

Widget proxySetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr("settings.proxy.title")),
        subtitle: Text(currentProxyName()),
        onTap: () async {
          await inputProxy(context);
          setState(() {});
        },
      );
    },
  );
}
