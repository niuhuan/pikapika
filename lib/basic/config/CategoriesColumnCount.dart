/// 多线程下载并发数

import 'package:easy_localization/easy_localization.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Method.dart';

String _propertyName = "categoriesColumnCount";
late int categoriesColumnCount;

Event categoriesColumnCountEvent = Event();

Future initCategoriesColumnCount() async {
  categoriesColumnCount =
      int.parse(await method.loadProperty(_propertyName, "0"));
}

Widget categoriesColumnCountSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(
          tr('settings.categories_column_count.title'),
        ),
        subtitle:
            Text(categoriesColumnCount == 0 ? tr('settings.categories_column_count.auto') : "$categoriesColumnCount"),
        onTap: () async {
          int? value = await chooseMapDialog(
              context,
              {
                tr('settings.categories_column_count.auto'): 0,
                "2": 2,
                "3": 3,
                "4": 4,
                "5": 5,
              },
              tr('settings.categories_column_count.choose'));
          if (value != null) {
            await method.saveProperty(_propertyName, "$value");
            categoriesColumnCount = value;
            setState(() {});
            categoriesColumnCountEvent.broadcast();
          }
        },
      );
    },
  );
}
