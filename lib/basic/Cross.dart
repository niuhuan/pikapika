/// 与平台交互的操作
import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/config/CopySkipConfirm.dart';
import 'package:pikapika/basic/config/Platform.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Method.dart';
import 'config/ChooserRoot.dart';

/// 复制内容到剪切板
void copyToClipBoard(BuildContext context, String string) {
  FlutterClipboard.copy(string);
  defaultToast(context, "已复制到剪切板");
}

void copyToClipBoardTips(BuildContext context, String string) {
  FlutterClipboard.copy(string);
  defaultToast(context, "已复制到剪切板 :\n$string");
}

/// 打开web页面
Future<dynamic> openUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: false,
    );
  }
}

/// 保存图片
Future<dynamic> saveImage(String path, BuildContext context) async {
  Future? future;
  if (Platform.isIOS) {
    future = method.iosSaveFileToImage(path);
  } else if (Platform.isAndroid) {
    future = _saveImageAndroid(path, context);
  } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    String? folder = await chooseFolder(context);
    if (folder != null) {
      future = method.convertImageToJPEG100(path, folder);
    }
  } else {
    defaultToast(context, '暂不支持该平台');
    return;
  }
  if (future == null) {
    defaultToast(context, '保存取消');
    return;
  }
  try {
    await future;
    defaultToast(context, '保存成功');
  } catch (e, s) {
    print("$e\n$s");
    defaultToast(context, '保存失败');
  }
}

/// 保存图片且保持静默, 用于批量导出到相册
Future<dynamic> saveImageQuiet(String path, BuildContext context) async {
  if (Platform.isIOS) {
    return method.iosSaveFileToImage(path);
  } else if (Platform.isAndroid) {
    return _saveImageAndroid(path, context);
  } else {
    throw Exception("only mobile");
  }
}

Future<dynamic> _saveImageAndroid(String path, BuildContext context) async {
  late bool g;
  if (androidVersion < 30) {
    g = await Permission.storage.request().isGranted;
  } else {
    g = await Permission.manageExternalStorage.request().isGranted;
  }
  if (!g) {
    return;
  }
  return method.androidSaveFileToImage(path);
}

/// 选择一个文件夹用于保存文件
Future<String?> chooseFolder(BuildContext context) async {
  return FilePicker.platform.getDirectoryPath(
    dialogTitle: "选择一个文件夹, 将文件保存到这里",
    initialDirectory:
        Directory.fromUri(Uri.file(await currentChooserRoot())).absolute.path,
  );
}

/// 复制对话框
void confirmCopy(BuildContext context, String content) async {
  if (copySkipConfirm()) {
    copyToClipBoardTips(context, content);
  } else {
    if (await confirmDialog(context, "复制", content)) {
      copyToClipBoard(context, content);
    }
  }
}
