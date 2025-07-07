// AppOrientation.dart

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Method.dart';

const _propertyName = "appOrientation";
late AppOrientation _appOrientation;

enum AppOrientation {
  normal,
  landscape,
  portrait,
}

String appOrientationName(AppOrientation type) {
  switch (type) {
    case AppOrientation.normal:
      return tr('settings.app_orientation.normal');
    case AppOrientation.landscape:
      return tr('settings.app_orientation.landscape');
    case AppOrientation.portrait:
      return tr('settings.app_orientation.portrait');
  }
}

Future initAppOrientation() async {
  _appOrientation = _fromString(await method.loadProperty(
      _propertyName, AppOrientation.normal.toString()));
  _set();
}

AppOrientation _fromString(String valueForm) {
  for (var value in AppOrientation.values) {
    if (value.toString() == valueForm) {
      return value;
    }
  }
  return AppOrientation.values.first;
}

AppOrientation get currentAppOrientation => _appOrientation;

Future chooseAppOrientation(BuildContext context) async {
  final Map<String, AppOrientation> map = {};
  for (var element in AppOrientation.values) {
    map[appOrientationName(element)] = element;
  }
  final newAppOrientation = await chooseMapDialog(
    context,
    map,
    tr('settings.app_orientation.choose'),
  );
  if (newAppOrientation != null) {
    await method.saveProperty(_propertyName, "$newAppOrientation");
    _appOrientation = newAppOrientation;
    _set();
  }
}

Widget appOrientationWidget() {
  if (!Platform.isAndroid && !Platform.isIOS) {
    return const SizedBox.shrink();
  }
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr('settings.app_orientation.title')),
        subtitle: Text(appOrientationName(_appOrientation)),
        onTap: () async {
          await chooseAppOrientation(context);
          setState(() {});
        },
      );
    },
  );
}

void _set() {
  if (Platform.isAndroid || Platform.isIOS) {
    switch (_appOrientation) {
      case AppOrientation.normal:
        SystemChrome.setPreferredOrientations([]);
        break;
      case AppOrientation.landscape:
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        break;
      case AppOrientation.portrait:
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        break;
    }
  }
}
