import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Method.dart';

var _imageAddresses = {
  "-1": "跟随api分流",
  "0": "不分流",
  "1": "分流1 (推荐)",
  "2": "分流2",
  "3": "分流3",
};

late String _currentImageAddress;

Future<void> initImageAddress() async {
  _currentImageAddress = await method.getImageSwitchAddress();
}

int currentImageAddress() {
  return int.parse(_currentImageAddress);
}

String currentImageAddressName() => _imageAddresses[_currentImageAddress] ?? "";

Future<void> chooseImageAddress(BuildContext context) async {
  String? choose = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text('选择图片分流'),
        children: <Widget>[
          ..._imageAddresses.entries.map(
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
    await method.setImageSwitchAddress(choose);
    _currentImageAddress = choose;
  }
}

Widget imageSwitchAddressSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text("图片分流"),
        subtitle: Text(currentImageAddressName()),
        onTap: () async {
          await chooseImageAddress(context);
          setState(() {});
        },
      );
    },
  );
}
