import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "showCommentAtDownload";

late bool _showCommentAtDownload;

Future initShowCommentAtDownload() async {
  _showCommentAtDownload =
      (await method.loadProperty(_propertyName, "false")) == "true";
}

bool showCommentAtDownload() {
  return _showCommentAtDownload;
}

Widget showCommentAtDownloadSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        value: _showCommentAtDownload,
        title: Text(tr("settings.show_comment_at_download.title")),
        onChanged: (target) async {
          await method.saveProperty(_propertyName, "$target");
          _showCommentAtDownload = target;
          setState(() {});
        },
      );
    },
  );
}
