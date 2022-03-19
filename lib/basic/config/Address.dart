/// 分流地址

// addr = "172.67.7.24:443"
// addr = "104.20.180.50:443"
// addr = "172.67.208.169:443"

import 'package:flutter/material.dart';

import '../Method.dart';

var _addresses = {
  "0": "不分流",
  "1": "分流1 (推荐)",
  "2": "分流2",
  "3": "分流3",
};

late String _currentAddress;

Future<void> initAddress() async {
  _currentAddress = await method.getSwitchAddress();
}

String currentAddressName() => _addresses[_currentAddress] ?? "";

Future<void> chooseAddress(BuildContext context) async {
  String? choose = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text('选择分流'),
        children: <Widget>[
          ..._addresses.entries.map(
            (e) => SimpleDialogOption(
              child: Text(e.value),
              onPressed: () {
                Navigator.of(context).pop(e.key);
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

Widget switchAddressSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("分流"),
        subtitle: Text(currentAddressName()),
        onTap: () async {
          await chooseAddress(context);
          setState(() {});
        },
      );
    },
  );
}
