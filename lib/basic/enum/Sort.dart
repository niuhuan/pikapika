/// 官方提供的排序方式

import 'package:flutter/material.dart';

const SORT_DEFAULT = "ua";
const SORT_TIME_NEWEST = "dd";
const SORT_TIME_OLDEST = "da";
const SORT_LIKE_MOST = "ld";
const SORT_GIVE_MOST = "vd";

const LABEL_DEFAULT = '默认排序';
const LABEL_TIME_NEWEST = "时间最新";
const LABEL_TIME_OLDEST = "时间最久";
const LABEL_LIKE_MOST = "点赞最多";
const LABEL_GIVE_MOST = "查看最多";

class _Sort {
  final String code;
  final String label;

  _Sort.of({
    required this.code,
    required this.label,
  });
}

final sortList = [
  //_Sort.of(code: SORT_DEFAULT, label: LABEL_DEFAULT),
  _Sort.of(code: SORT_TIME_NEWEST, label: LABEL_TIME_NEWEST),
  _Sort.of(code: SORT_TIME_OLDEST, label: LABEL_TIME_OLDEST),
  _Sort.of(code: SORT_LIKE_MOST, label: LABEL_LIKE_MOST),
  _Sort.of(code: SORT_GIVE_MOST, label: LABEL_GIVE_MOST),
];

List<DropdownMenuItem<String>> items = sortList
    .map((e) => DropdownMenuItem(
          value: e.code,
          child: Text(e.label),
        ))
    .toList();


final collSortList = [
  _Sort.of(code: SORT_TIME_NEWEST, label: LABEL_TIME_NEWEST),
  _Sort.of(code: SORT_TIME_OLDEST, label: LABEL_TIME_OLDEST),
];

List<DropdownMenuItem<String>> collItems = collSortList
    .map((e) => DropdownMenuItem(
          value: e.code,
          child: Text(e.label),
        ))
    .toList();