import 'package:flutter/material.dart';

import '../Method.dart';

var _useApiLoadImages = {
  "false": "否",
  "true": "是",
};

late String _currentUseApiLoadImage;

Future<void> initUseApiLoadImage() async {
  _currentUseApiLoadImage = await method.getUseApiClientLoadImage();
}

int currentUseApiLoadImage() {
  return int.parse(_currentUseApiLoadImage);
}

String currentUseApiLoadImageName() => _useApiLoadImages[_currentUseApiLoadImage] ?? "";

Future<void> chooseUseApiLoadImage(BuildContext context) async {
  String? choose = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text('用API加载图片'),
        children: <Widget>[
          ..._useApiLoadImages.entries.map(
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
    await method.setUseApiClientLoadImage(choose);
    _currentUseApiLoadImage = choose;
  }
}

Widget useApiLoadImageSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("用API加载图片"),
        subtitle: Text(currentUseApiLoadImageName()),
        onTap: () async {
          await chooseUseApiLoadImage(context);
          setState(() {});
        },
      );
    },
  );
}
