import 'dart:convert';
import 'package:event/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/screens/CategoriesSortScreen.dart';
import '../Method.dart';

const _propertyName = "categoriesSort";
List<String> _categoriesSort = [];

Future initCategoriesSort() async {
  var json = await method.loadProperty(_propertyName, "[]");
  _categoriesSort = List<String>.from(jsonDecode(json));
}

Future saveCategoriesSort(List<String> categoriesSort) async {
  _categoriesSort = categoriesSort;
  await method.saveProperty(_propertyName, jsonEncode(categoriesSort));
  categoriesSortEvent.broadcast();
}

List<String> getCategoriesSort() {
  return _categoriesSort;
}

var categoriesSortEvent = Event();

Widget categoriesSortSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) {
              return const CategoriesSortScreen();
            },
          ));
        },
        title: const Text(
          "首页分类排序",
        ),
      );
    },
  );
}
