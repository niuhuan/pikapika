/// 阅读器的类型

import 'package:flutter/material.dart';
import '../Method.dart';

enum ReaderType {
  WEB_TOON,
  WEB_TOON_ZOOM,
  GALLERY,
  WEB_TOON_FREE_ZOOM,
  TWO_PAGE_GALLERY,
}

const _types = {
  'WebToon (默认)': ReaderType.WEB_TOON,
  'WebToon (双击放大)': ReaderType.WEB_TOON_ZOOM,
  '相册': ReaderType.GALLERY,
  'WebToon (ListView双击放大)\n(此模式进度条无效)': ReaderType.WEB_TOON_FREE_ZOOM,
  '双页模式\n(实验)': ReaderType.TWO_PAGE_GALLERY,
};

const _propertyName = "readerType";
late ReaderType _readerType;

Future<dynamic> initReaderType() async {
  _readerType = _readerTypeFromString(
      await method.loadProperty(_propertyName, ReaderType.WEB_TOON.toString()));
}

ReaderType currentReaderType() {
  return _readerType;
}

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
    if (e.value == _readerType) {
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
        title: const Text("选择阅读模式"),
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
    _readerType = t;
  }
}

Widget readerTypeSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("阅读器模式"),
        subtitle: Text(currentReaderTypeName()),
        onTap: () async {
          await choosePagerType(context);
          setState(() {});
        },
      );
    },
  );
}
