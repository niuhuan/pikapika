/// 代理设置

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

late String _currentProxy;

Future<String?> initProxy() async {
  _currentProxy = await method.getProxy();
}

String currentProxyName() {
  return _currentProxy == "" ? "未设置" : _currentProxy;
}

Future<dynamic> inputProxy(BuildContext context) async {
  String? input = await displayTextInputDialog(
    context,
    '代理服务器',
    '请输入代理服务器',
    _currentProxy,
    " ( 例如 socks5://127.0.0.1:1080/ ) ",
  );
  if (input != null) {
    await method.setProxy(input);
    _currentProxy = input;
  }
}
