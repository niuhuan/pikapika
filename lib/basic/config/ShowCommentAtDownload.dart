import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "showCommentAtDownload";

late bool _showCommentAtDownload;

Future initShowCommentAtDownload() async {
  _showCommentAtDownload = (await method.loadProperty(_propertyName, "false")) == "true";
}

bool showCommentAtDownload() {
  return _showCommentAtDownload;
}

Future<void> _chooseShowCommentAtDownload(BuildContext context) async {
  String? result =
  await chooseListDialog<String>(context, "在下载显示评论区", ["是", "否"]);
  if (result != null) {
    var target = result == "是";
    await method.saveProperty(_propertyName, "$target");
    _showCommentAtDownload = target;
  }
}

Widget showCommentAtDownloadSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("在下载显示评论区"),
        subtitle: Text(_showCommentAtDownload ? "是" : "否"),
        onTap: () async {
          await _chooseShowCommentAtDownload(context);
          setState(() {});
        },
      );
    },
  );
}
