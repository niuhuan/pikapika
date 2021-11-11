import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

const _versionAssets = 'lib/assets/version.txt';
RegExp _versionExp = RegExp(r"^v\d+\.\d+.\d+$");

late String _version;

Future initVersion() async {
  try {
    _version = (await rootBundle.loadString(_versionAssets)).trim();
  } catch (e) {
    _version = "dirty";
  }
}

Future versionCheck() async {
  if (_versionExp.hasMatch(_version)) {
  } else {
    // dirtyVersion
  }
  // String latestVersion = (await method.httpGet(_versionAddress)).trim();
}
