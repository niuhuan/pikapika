/// 图片质量

import 'package:flutter/material.dart';

import '../Method.dart';

late String currentQualityCode;

Future<void> initQuality() async {
  currentQualityCode = await method.loadQuality();
}

const ImageQualityOriginal = "original";
const ImageQualityLow = "low";
const ImageQualityMedium = "medium";
const ImageQualityHigh = "high";

const LabelOriginal = "原图";
const LabelLow = "低";
const LabelMedium = "中";
const LabelHigh = "高";

var _qualities = {
  LabelOriginal: ImageQualityOriginal,
  LabelLow: ImageQualityLow,
  LabelMedium: ImageQualityMedium,
  LabelHigh: ImageQualityHigh,
};

Future<void> chooseQuality(BuildContext context) async {
  String? code = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text("请选择图片质量"),
        children: <Widget>[
          ..._qualities.entries.map(
            (e) => SimpleDialogOption(
              child: Text(e.key),
              onPressed: () {
                Navigator.of(context).pop(e.value);
              },
            ),
          ),
        ],
      );
    },
  );
  if (code != null) {
    method.saveQuality(code);
    currentQualityCode = code;
  }
}

String currentQualityName() {
  for (var e in _qualities.entries) {
    if (e.value == currentQualityCode) {
      return e.key;
    }
  }
  return '';
}
