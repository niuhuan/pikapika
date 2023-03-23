/// 下载的同时导出到文件系统

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Cross.dart';

import '../Method.dart';

late String _downloadCachePath;

Future initDownloadCachePath() async {
  if (Platform.isWindows ||
      Platform.isMacOS ||
      Platform.isAndroid ||
      Platform.isLinux) {
    _downloadCachePath = await method.loadDownloadCachePath();
  }
}

Widget downloadCachePathSetting() {
  if (Platform.isWindows ||
      Platform.isMacOS ||
      Platform.isAndroid ||
      Platform.isLinux) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
          title: const Text("使用下载缓存"),
          subtitle: Text(_downloadCachePath),
          onTap: () async {
            if (_downloadCachePath == "") {
              bool b = await confirmDialog(
                context,
                "使用其他软件的下载内容加速",
                "您即将选择一个目录, 这个目录拷贝自 ${base64Decode("L0FuZHJvaWQvZGF0YS9jb20ucGljYWNvbWljLmZyZWdhdGEvZmlsZXMv")}",
              );
              if (b) {
                late String? folder;
                try {
                  folder = await chooseFolder(context);
                } catch (e) {
                  defaultToast(context, "$e");
                  return;
                }
                if (folder != null) {
                  await method.saveDownloadCachePath(folder);
                  _downloadCachePath = folder;
                  setState(() {});
                }
              }
            } else {
              bool b = await confirmDialog(
                context,
                "使用其他软件的下载内容加速",
                "您确定取消使用其他软件的下载内容加速的功能吗? 取消之后您可以再次点击设置",
              );
              if (b) {
                var folder = "";
                await method.saveDownloadCachePath(folder);
                _downloadCachePath = folder;
                setState(() {});
              }
            }
          },
        );
      },
    );
  }
  return Container();
}
