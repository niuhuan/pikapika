import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Widget languageListTile() {
  if (Platform.isIOS || Platform.isAndroid) {
  } else {
    return Container();
  }
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr('language.title')),
        subtitle: Text(tr('language.name')),
        onTap: () async {
          var choose = await showDialog<Locale>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(tr('language.title')),
                  content: Column(
                    children: [
                      ListTile(
                        title: const Text("English - United States"),
                        onTap: () {
                          Navigator.pop(context, const Locale('en', 'US'));
                        },
                      ),
                      ListTile(
                        title: const Text("简体中文 - 中国大陆"),
                        onTap: () {
                          Navigator.pop(context, const Locale('zh', 'CN'));
                        },
                      ),
                      ListTile(
                        title: const Text("繁體中文 - 中國台灣"),
                        onTap: () {
                          Navigator.pop(context, const Locale('zh', 'TW'));
                        },
                      ),
                      ListTile(
                        title: const Text("日本語 - 日本"),
                        onTap: () {
                          Navigator.pop(context, const Locale('ja', 'JP'));
                        },
                      ),
                      ListTile(
                        title: const Text("한국어 - 대한민국"),
                        onTap: () {
                          Navigator.pop(context, const Locale('ko', 'KR'));
                        },
                      ),
                    ],
                  ),
                );
              });
          if (choose != null) {
              context.setLocale(choose);
          }
        },
      );
    },
  );
}
