/// 分流地址

// addr = "172.67.7.24:443"
// addr = "104.20.180.50:443"
// addr = "172.67.208.169:443"

import 'package:flutter/material.dart';

import '../Method.dart';

var _addresses = {
  "不分流": "",
  "分流1": "172.67.7.24:443",
  "分流2": "104.20.180.50:443",
  "分流3": "72.67.208.169:443",
};

late String _currentAddress;

Future<void> initAddress() async {
  _currentAddress = await method.getSwitchAddress();
}

String currentAddressName() {
  for (var value in _addresses.entries) {
    if (value.value == _currentAddress) {
      return value.key;
    }
  }
  return "";
}

Future<void> chooseAddress(BuildContext context) async {
  String? choose = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text('选择分流'),
        children: <Widget>[
          ..._addresses.entries.map(
            (e) => SimpleDialogOption(
              child: Text(e.key),
              onPressed: () {
                Navigator.of(context).pop(e.value);
              },
            ),
          ),
        ],
      );
    },
  );
  if (choose != null) {
    await method.setSwitchAddress(choose);
    _currentAddress = choose;
  }
}
