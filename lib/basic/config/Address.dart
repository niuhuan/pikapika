/// 分流地址

// addr = "172.67.7.24:443"
// addr = "104.20.180.50:443"
// addr = "172.67.208.169:443"

import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';

import '../Method.dart';

var _addresses = {
  "0": "不分流",
  "1": "分流1",
  "2": "分流2",
  "3": "分流3 (推荐)",
  "4": "分流4",
  "5": "分流5",
  "6": "分流6",
  "7": "分流7",
  "8": "分流8",
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

Widget reloadSwitchAddressSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("==== 分流 ===="),
        onTap: () async {
          String? choose = await chooseListDialog(context, "==== 分流 ====", [
            "从服务器获取最新的分流地址",
            "重制分流为默认值",
          ]);
          if (choose != null) {
            if (choose == "从服务器获取最新的分流地址") {
              try {
                await method.reloadSwitchAddress();
                defaultToast(context, "分流2/3已同步");
              } catch (e, s) {
                print("$e\$s");
                defaultToast(context, "分流同步失败");
              }
            } else if (choose == "重制分流为默认值") {
              try {
                await method.resetSwitchAddress();
                defaultToast(context, "分流2/3已重制为默认值");
              } catch (e, s) {
                print("$e\$s");
                defaultToast(context, "分流重制失败");
              }
            }
          }
        },
      );
    },
  );
}
