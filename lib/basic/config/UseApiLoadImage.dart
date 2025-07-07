import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../Method.dart';

// var _useApiLoadImages = {
//   "false": "否",
//   "true": "是",
// };

Map<String, String> _useApiLoadImages = {};

late String _currentUseApiLoadImage;

Future<void> initUseApiLoadImage() async {
  _useApiLoadImages.addAll({
    tr("app.no"): "false",
    tr("app.yes"): "true",
  });
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
        title: Text(tr("net.use_api_load_image")),
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
        title: Text(tr("net.use_api_load_image")),
        subtitle: Text(currentUseApiLoadImageName()),
        onTap: () async {
          await chooseUseApiLoadImage(context);
          setState(() {});
        },
      );
    },
  );
}
