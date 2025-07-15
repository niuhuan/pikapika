/// 图片质量

import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';
import '../Method.dart';

const _ImageQualityOriginal = "original";
const _ImageQualityLow = "low";
const _ImageQualityMedium = "medium";
const _ImageQualityHigh = "high";

// const _LabelOriginal = "原图";
// const _LabelLow = "低";
// const _LabelMedium = "中";
// const _LabelHigh = "高";

// var _qualities = {
//   _LabelOriginal: _ImageQualityOriginal,
//   _LabelLow: _ImageQualityLow,
//   _LabelMedium: _ImageQualityMedium,
//   _LabelHigh: _ImageQualityHigh,
// };

Map<String, String> _qualities = {};

const _propertyName = "quality";
late String _currentQualityCode;
const _defaultValue = _ImageQualityOriginal;

Future<void> initQuality() async {
  _qualities.addAll({
    tr("settings.quality.original"): _ImageQualityOriginal,
    tr("settings.quality.low"): _ImageQualityLow,
    tr("settings.quality.medium"): _ImageQualityMedium,
    tr("settings.quality.high"): _ImageQualityHigh,
  });
  _currentQualityCode = await method.loadProperty(_propertyName, _defaultValue);
}

String currentQualityCode() {
  return _currentQualityCode;
}

String currentQualityName() {
  for (var e in _qualities.entries) {
    if (e.value == _currentQualityCode) {
      return e.key;
    }
  }
  return '';
}

Future<void> chooseQuality(BuildContext context) async {
  String? code = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(tr("settings.quality.choose")),
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
    method.saveProperty(_propertyName, code);
    _currentQualityCode = code;
  }
}

Widget qualitySetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr("settings.quality.title")),
        subtitle: Text(currentQualityName()),
        onTap: () async {
          await chooseQuality(context);
          setState(() {});
        },
      );
    },
  );
}
