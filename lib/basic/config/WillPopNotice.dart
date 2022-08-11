import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "willPopNotice";

late bool _willPopNotice;

Future initWillPopNotice() async {
  _willPopNotice = (await method.loadProperty(_propertyName, "false")) == "true";
}

bool willPopNotice() {
  return _willPopNotice;
}

Future<void> _chooseWillPopNotice(BuildContext context) async {
  String? result =
  await chooseListDialog<String>(context, "退出APP的提示", ["是", "否"]);
  if (result != null) {
    var target = result == "是";
    await method.saveProperty(_propertyName, "$target");
    _willPopNotice = target;
  }
}

Widget willPopNoticeSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("退出APP的提示"),
        subtitle: Text(_willPopNotice ? "是" : "否"),
        onTap: () async {
          await _chooseWillPopNotice(context);
          setState(() {});
        },
      );
    },
  );
}
