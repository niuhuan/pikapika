/// 阅读器的类型

import 'package:flutter/material.dart';

import '../Method.dart';

late ReaderType gReaderType;

const _propertyName = "readerType";

Future<dynamic> initReaderType() async {
  gReaderType = _readerTypeFromString(
      await method.loadProperty(_propertyName, ReaderType.WEB_TOON.toString()));
}

enum ReaderType {
  WEB_TOON,
  WEB_TOON_ZOOM,
  GALLERY,
}

var _types = {
  'WebToon (默认)': ReaderType.WEB_TOON,
  'WebToon + 双击放大': ReaderType.WEB_TOON_ZOOM,
  '相册': ReaderType.GALLERY,
};

ReaderType _readerTypeFromString(String pagerTypeString) {
  for (var value in ReaderType.values) {
    if (pagerTypeString == value.toString()) {
      return value;
    }
  }
  return ReaderType.WEB_TOON;
}

String currentReaderTypeName() {
  for (var e in _types.entries) {
    if (e.value == gReaderType) {
      return e.key;
    }
  }
  return '';
}

Future<void> choosePagerType(BuildContext buildContext) async {
  ReaderType? t = await showDialog<ReaderType>(
    context: buildContext,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text("选择阅读模式"),
        children: _types.entries
            .map((e) => SimpleDialogOption(
                  child: Text(e.key),
                  onPressed: () {
                    Navigator.of(context).pop(e.value);
                  },
                ))
            .toList(),
      );
    },
  );
  if (t != null) {
    await method.saveProperty(_propertyName, t.toString());
    gReaderType = t;
  }
}
