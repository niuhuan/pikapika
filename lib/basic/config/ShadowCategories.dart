/// 屏蔽的分类

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../Method.dart';
import '../store/Categories.dart';

late List<String> shadowCategories;

var shadowCategoriesEvent = Event<EventArgs>();

Future<void> initShadowCategories() async {
  shadowCategories = await method.getShadowCategories();
}

Future<void> chooseShadowCategories(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (ctx) {
      var initialValue = <String>[];
      shadowCategories.forEach((element) {
        if (shadowCategories.contains(element)) {
          initialValue.add(element);
        }
      });
      return MultiSelectDialog<String>(
        title: Text('封印'),
        searchHint: '搜索',
        cancelText: Text('取消'),
        confirmText: Text('确定'),
        items: storedCategories.map((e) => MultiSelectItem(e, e)).toList(),
        initialValue: initialValue,
        onConfirm: (List<String>? value) async {
          if (value != null) {
            await method.setShadowCategories(value);
            shadowCategories = value;
            shadowCategoriesEvent.broadcast();
          }
        },
      );
    },
  );
}

Widget shadowCategoriesActionButton(BuildContext context) {
  return IconButton(
    onPressed: () {
      chooseShadowCategories(context);
    },
    icon: Icon(Icons.hide_source),
  );
}
