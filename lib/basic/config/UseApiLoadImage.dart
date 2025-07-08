import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../Method.dart';

late bool _currentUseApiLoadImage;

Future<void> initUseApiLoadImage() async {
  _currentUseApiLoadImage = await method.getUseApiClientLoadImage() == "true";
}

String currentUseApiLoadImageName() =>
    _currentUseApiLoadImage ? tr("app.yes") : tr("app.no");

Widget useApiLoadImageSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        title: Text(tr("net.use_api_load_image")),
        subtitle: Text(currentUseApiLoadImageName()),
        value: _currentUseApiLoadImage,
        onChanged: (bool value) async {
          _currentUseApiLoadImage = !_currentUseApiLoadImage;
          await method
              .setUseApiClientLoadImage(_currentUseApiLoadImage.toString());
          setState(() {});
        },
      );
    },
  );
}

Future<void> chooseUseApiLoadImage(BuildContext context) async {
  String? choose = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(tr("net.use_api_load_image")),
        children: <Widget>[
          SimpleDialogOption(
            child: Text(tr("app.yes")),
            onPressed: () {
              Navigator.of(context).pop("true");
            },
          ),
          SimpleDialogOption(
            child: Text(tr("app.no")),
            onPressed: () {
              Navigator.of(context).pop("false");
            },
          ),
        ],
      );
    },
  );
  if (choose != null) {
    await method.setUseApiClientLoadImage(choose);
    _currentUseApiLoadImage = choose == "true";
  }
}
