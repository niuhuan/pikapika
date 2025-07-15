import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';
import '../Common.dart';
import '../Method.dart';

const _propertyName = "copyFullNameTemplate";

late String _copyFullNameTemplate;

Future initCopyFullNameTemplate() async {
  _copyFullNameTemplate =
      await method.loadProperty(_propertyName, "[{author}] {title}");
}

String copyFullNameTemplate() {
  return _copyFullNameTemplate;
}

Widget copyFullNameTemplateSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr("settings.copy_full_name_template.title")),
        subtitle: Text(_copyFullNameTemplate),
        onTap: () async {
          var result = await displayTextInputDialog(
            context,
            title: tr("settings.copy_full_name_template.title"),
            hint: tr("settings.copy_full_name_template.hint"),
            src: _copyFullNameTemplate,
          );
          if (result == null) {
            return;
          }
          await method.saveProperty(_propertyName, result);
          _copyFullNameTemplate = result;
          setState(() {});
        },
      );
    },
  );
}
