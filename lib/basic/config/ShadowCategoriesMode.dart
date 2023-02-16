/// 屏蔽方式

import 'package:flutter/material.dart';
import '../Common.dart';
import '../Method.dart';
import 'ShadowCategoriesEvent.dart';

enum ShadowCategoriesMode {
  BLACK_LIST,
  WHITE_LIST,
}

Map<String, ShadowCategoriesMode> _fullScreenActionMap = {
  "黑名单": ShadowCategoriesMode.BLACK_LIST,
  "白名单": ShadowCategoriesMode.WHITE_LIST,
};

const _propertyName = "shadowCategoriesMode";
late ShadowCategoriesMode _shadowCategoriesMode;

Future<void> initShadowCategoriesMode() async {
  _shadowCategoriesMode = _shadowCategoriesModeFromString(await method.loadProperty(
    _propertyName,
    ShadowCategoriesMode.BLACK_LIST.toString(),
  ));
}

ShadowCategoriesMode currentShadowCategoriesMode() {
  return _shadowCategoriesMode;
}

ShadowCategoriesMode _shadowCategoriesModeFromString(String string) {
  for (var value in ShadowCategoriesMode.values) {
    if (string == value.toString()) {
      return value;
    }
  }
  return ShadowCategoriesMode.BLACK_LIST;
}

String _currentShadowCategoriesMode() {
  for (var e in _fullScreenActionMap.entries) {
    if (e.value == _shadowCategoriesMode) {
      return e.key;
    }
  }
  return '';
}

Future<void> _chooseShadowCategoriesMode(BuildContext context) async {
  ShadowCategoriesMode? result = await chooseMapDialog<ShadowCategoriesMode>(
      context, _fullScreenActionMap, "封印模式");
  if (result != null) {
    await method.saveProperty(_propertyName, result.toString());
    _shadowCategoriesMode = result;
    shadowCategoriesEvent.broadcast();
  }
}

Widget shadowCategoriesModeSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("封印模式"),
        subtitle: Text(_currentShadowCategoriesMode()),
        onTap: () async {
          await _chooseShadowCategoriesMode(context);
          setState(() {});
        },
      );
    },
  );
}

Widget shadowSwitchActionButton(BuildContext context) {
  return IconButton(
    onPressed: () {
      _chooseShadowCategoriesMode(context);
    },
    icon: const Icon(Icons.do_not_disturb_on_outlined),
  );
}

const chooseShadowCategoriesMode = _chooseShadowCategoriesMode;
