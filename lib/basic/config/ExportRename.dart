/// 自动全屏
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';
import 'IsPro.dart';

const _propertyName = "exportRename";
late bool _exportRename;

Future<void> initExportRename() async {
  _exportRename = (await method.loadProperty(_propertyName, "false")) == "true";
}

bool currentExportRename() {
  return _exportRename;
}

Future<void> _chooseExportRename(BuildContext context) async {
  String? result =
      await chooseListDialog<String>(context, tr("settings.export_rename.title"), ["是", "否"]);
  if (result != null) {
    var target = result == "是";
    await method.saveProperty(_propertyName, "$target");
    _exportRename = target;
  }
}

Widget exportRenameSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(
          tr("settings.export_rename.title") + (!isPro ? "(${tr("app.pro")})" : ""),
          style: TextStyle(
            color: !isPro ? Colors.grey : null,
          ),
        ),
        subtitle: Text(_exportRename ? tr("settings.yes") : tr("settings.no")),
        onTap: () async {
          if (!isPro) {
            defaultToast(context, tr("app.pro_required"));
            return;
          }
          await _chooseExportRename(context);
          setState(() {});
        },
      );
    },
  );
}
