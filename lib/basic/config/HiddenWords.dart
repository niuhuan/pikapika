import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../screens/HiddenWordsScreen.dart';
import '../Method.dart';

const _key = "hiddenWords";

final List<String> _hiddenWords = [];

List<String> get hiddenWords => _hiddenWords;

Future<String> initHiddenWords() async {
  final words = await method.loadProperty(_key, "[]");
  _hiddenWords.clear();
  _hiddenWords.addAll((jsonDecode(words) as List).cast<String>());
  return words;
}

Future<void> saveHiddenWords(List<String> words) async {
  _hiddenWords.clear();
  _hiddenWords.addAll(words);
  await method.saveProperty(_key, jsonEncode(words));
}

Future<void> addHiddenWord(String word) async {
  if (word.trim().isEmpty) return;
  if (!_hiddenWords.contains(word)) {
    _hiddenWords.add(word);
    await method.saveProperty(_key, jsonEncode(_hiddenWords));
  }
}

Future<void> removeHiddenWord(String word) async {
  _hiddenWords.remove(word);
  await method.saveProperty(_key, jsonEncode(_hiddenWords));
}

Future<void> clearHiddenWords() async {
  _hiddenWords.clear();
  await method.saveProperty(_key, "[]");
}

Widget hiddenWordsSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr("settings.hidden_words.title")),
        subtitle: Text(subString(jsonEncode(_hiddenWords))),
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const HiddenWordsScreen(),
          ));
          setState(() {});
        },
      );
    },
  );
}

String subString(String str) {
  if (str.length > 20) {
    return str.substring(0, 20) + "...";
  }
  return str;
}
