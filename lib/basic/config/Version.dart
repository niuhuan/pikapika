import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

import '../Method.dart';

const _versionUrl =
    "https://api.github.com/repos/niuhuan/pikapi-flutter/releases/latest";
const _versionAssets = 'lib/assets/version.txt';
RegExp _versionExp = RegExp(r"^v\d+\.\d+.\d+$");

late String _version;
var _latestVersion = "";

Future initVersion() async {
  try {
    _version = (await rootBundle.loadString(_versionAssets)).trim();
  } catch (e) {
    _version = "dirty";
  }
}

Future autoCheckNewVersion() async {}

Future _versionCheck() async {
  if (_versionExp.hasMatch(_version)) {
    // exception
    String latestVersion = (await method.httpGet(_versionUrl)).trim();
    if (latestVersion != _version) {
      // new Version
    }
  } else {
    // dirtyVersion
  }
  //
}
