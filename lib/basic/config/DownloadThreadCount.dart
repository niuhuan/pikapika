/// 多线程下载并发数

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Method.dart';

import 'IsPro.dart';

late int _downloadThreadCount;
const _values = [1, 2, 3, 4, 5];

Future initDownloadThreadCount() async {
  _downloadThreadCount = await method.loadDownloadThreadCount();
}

Widget downloadThreadCountSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(
          tr("settings.download_thread_count.title") + (!isPro ? "(${tr("app.pro")})" : ""),
          style: TextStyle(
            color: !isPro ? Colors.grey : null,
          ),
        ),
        subtitle: Text("$_downloadThreadCount"),
        onTap: () async {
          if (!isPro) {
            defaultToast(context, tr("app.pro_required"));
            return;
          }
          int? value = await chooseListDialog(context, tr("settings.download_thread_count.choose"), _values);
          if (value != null) {
            await method.saveDownloadThreadCount(value);
            _downloadThreadCount = value;
            setState(() {});
          }
        },
      );
    },
  );
}
