/// 多线程下载并发数

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
        title: const Text(
          "首页分类展示列数",
        ),
        subtitle:
            Text(categoriesColumnCount == 0 ? "自动" : "$categoriesColumnCount"),
        onTap: () async {
          int? value = await chooseMapDialog(
              context,
              {
                "自动": 0,
                "2": 2,
                "3": 3,
                "4": 4,
                "5": 5,
              },
              "选择首页分类展示列数");
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
