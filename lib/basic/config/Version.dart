import 'dart:async' show Future;
import 'dart:convert';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pikapika/basic/Common.dart';

import '../Method.dart';

const _versionUrl =
    "https://api.github.com/repos/niuhuan/pikapika/releases/latest";
const _versionAssets = 'lib/assets/version.txt';

late String _version;
String? _latestVersion;
String? _latestVersionInfo;

Future initVersion() async {
  // 当前版本
  try {
    _version = (await rootBundle.loadString(_versionAssets)).trim();
  } catch (e) {
    _version = "dirty";
  }
}

var versionEvent = Event<EventArgs>();

String currentVersion() {
  return _version;
}

String? latestVersion() {
  return _latestVersion;
}

String? latestVersionInfo() {
  return _latestVersionInfo;
}

Future autoCheckNewVersion() {
  return _versionCheck();
}

Future manualCheckNewVersion(BuildContext context) async {
  try {
    defaultToast(context, "检查更新中");
    await _versionCheck();
    defaultToast(context, "检查更新成功");
  } catch (e) {
    defaultToast(context, "检查更新失败 : $e");
  }
}

bool dirtyVersion() {
  return "dirty" == _version;
}

// maybe exception
Future _versionCheck() async {
  if (!dirtyVersion()) {
    // 检查更新只能使用defaultHttpClient, 而不能使用pika的client, 否则会 "tls handshake failure"
    var json = jsonDecode(await method.defaultHttpClientGet(_versionUrl));
    if (json["name"] != null) {
      String latestVersion = (json["name"]);
      if (latestVersion != _version) {
        _latestVersion = latestVersion;
        _latestVersionInfo = json["body"] ?? "";
      }
    }
  } // else dirtyVersion
  versionEvent.broadcast();
}
