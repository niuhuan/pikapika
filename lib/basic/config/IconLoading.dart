/// 自动全屏

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "iconLoading";
late bool _iconLoading;

Future<void> initIconLoading() async {
  _iconLoading = (await method.loadProperty(_propertyName, "false")) == "true";
}

bool currentIconLoading() {
  return _iconLoading;
}

Future<void> _chooseIconLoading(BuildContext context) async {
  String? result =
      await chooseListDialog<String>(context, "尽量减少UI动画", ["是", "否"]);
  if (result != null) {
    var target = result == "是";
    await method.saveProperty(_propertyName, "$target");
    _iconLoading = target;
  }
}

Widget iconLoadingSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("尽量减少UI动画"),
        subtitle: Text(_iconLoading ? "是" : "否"),
        onTap: () async {
          await _chooseIconLoading(context);
          setState(() {});
        },
      );
    },
  );
}

Route<T> mixRoute<T>({required WidgetBuilder builder}) {
  if (currentIconLoading()) {
    return PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) => builder.call(context),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
  return MaterialPageRoute(builder: builder);
}
