import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/services.dart';

Map<String, String> translations = {};

Future<void> loadTranslations() async {
  String data =
      await rootBundle.loadString('lib/assets/translations/zh-CN.json');
  Map<String, dynamic> jsonData = json.decode(data);
  putMap("", jsonData);
}

void putMap(String prefix, Map<String, dynamic> map) {
  for (String key in map.keys) {
    if (map[key] is Map<String, dynamic>) {
      putMap("$prefix$key.", map[key] as Map<String, dynamic>);
    } else if (map[key] is String) {
      translations["$prefix$key"] = map[key] as String;
    } else {
      throw Exception("Unsupported type for key: $prefix$key");
    }
  }
}

String tr(String key) {
  if (Platform.isIOS || Platform.isAndroid) {
    return el.tr(key);
  }
  return translations[key] ?? key;
}
