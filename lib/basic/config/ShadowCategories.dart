/// 屏蔽的分类

import 'dart:convert';

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../Method.dart';
import '../store/Categories.dart';

late List<String> shadowCategories;
var shadowCategoriesEvent = Event<EventArgs>();

// mapper

const _propertyName = "shadowCategories";

/// 获取封印的类型
Future<List<String>> _loadShadowCategories() async {
  var value = await method.loadProperty(_propertyName, jsonEncode(<String>[]));
  return List.of(jsonDecode(value)).map((e) => "$e").toList();
}

/// 保存封印的类型
Future<dynamic> _saveShadowCategories(List<String> value) {
  return method.saveProperty(_propertyName, jsonEncode(value));
}

Future<void> initShadowCategories() async {
  shadowCategories = await _loadShadowCategories();
}

Future<void> _chooseShadowCategories(BuildContext context) async {
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
            await _saveShadowCategories(value);
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
      _chooseShadowCategories(context);
    },
    icon: Icon(Icons.hide_source),
  );
}

Widget shadowCategoriesSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text("封印"),
        subtitle: Text(jsonEncode(shadowCategories)),
        onTap: () async {
          await _chooseShadowCategories(context);
          setState(() {});
        },
      );
    },
  );
}
