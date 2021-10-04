/// 主题

import 'dart:io';

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Method.dart';

// 主题包
abstract class _ThemePackage {
  String code();

  String name();

  ThemeData themeData();
}

class _OriginTheme extends _ThemePackage {
  @override
  String code() => "origin";

  @override
  String name() => "原生";

  @override
  ThemeData themeData() => ThemeData();
}

class _PinkTheme extends _ThemePackage {
  @override
  String code() => "pink";

  @override
  String name() => "粉色";

  @override
  ThemeData themeData() =>
      ThemeData().copyWith(
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          secondary: Colors.pink.shade200,
        ),
        appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
          color: Colors.pink.shade200,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.pink[300],
          unselectedItemColor: Colors.grey[500],
        ),
        dividerColor: Colors.grey.shade200,
      );
}

class _BlackTheme extends _ThemePackage {
  @override
  String code() => "black";

  @override
  String name() => "酷黑";

  @override
  ThemeData themeData() =>
      ThemeData().copyWith(
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          secondary: Colors.pink.shade200,
        ),
        appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
          color: Colors.grey.shade800,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.grey.shade800,
        ),
        dividerColor: Colors.grey.shade200,
      );
}

class _DarkTheme extends _ThemePackage {
  @override
  String code() => "dark";

  @override
  String name() => "暗黑";

  @override
  ThemeData themeData() =>
      ThemeData.dark().copyWith(
        colorScheme: ColorScheme.light(
          secondary: Colors.pink.shade200,
        ),
        appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
          color: Color(0xFF1E1E1E),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey.shade300,
          backgroundColor: Colors.grey.shade900,
        ),
      );
}

final _themePackages = <_ThemePackage>[
  _OriginTheme(),
  _PinkTheme(),
  _BlackTheme(),
  _DarkTheme(),
];

// 主题更换事件
var themeEvent = Event<EventArgs>();

int _androidVersion = 1;
String? _themeCode;
ThemeData? _themeData;
bool _androidNightMode = false;
bool _systemNight = false;

String currentThemeName() {
  for (var package in _themePackages) {
    if (_themeCode == package.code()) {
      return package.name();
    }
  }
  return "";
}

ThemeData? currentThemeData() {
  return (_androidNightMode && _systemNight)
      ? _themePackages[3].themeData()
      : _themeData;
}

// 根据Code选择主题, 并发送主题更换事件
void _changeThemeByCode(String themeCode) {
  for (var package in _themePackages) {
    if (themeCode == package.code()) {
      _themeCode = themeCode;
      _themeData = package.themeData();
      break;
    }
  }
  themeEvent.broadcast();
}

// 为了匹配安卓夜间模式增加的配置文件
const _nightModePropertyName = "androidNightMode";

Future<dynamic> initTheme() async {
  if (Platform.isAndroid) {
    _androidVersion = await method.androidGetVersion();
    if (_androidVersion >= 29) {
      _androidNightMode =
          (await method.loadProperty(_nightModePropertyName, "false")) ==
              "true";
      _systemNight = (await method.androidGetUiMode()) == "NIGHT";
      EventChannel("ui_mode").receiveBroadcastStream().listen((event) {
        _systemNight = "$event" == "NIGHT";
        themeEvent.broadcast();
      });
    }
  }
  _changeThemeByCode(await method.loadTheme());
}

// 选择主题的对话框
Future<dynamic> chooseTheme(BuildContext buildContext) async {
  String? theme = await showDialog<String>(
    context: buildContext,
    builder: (BuildContext context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            var list = <SimpleDialogOption>[];
            if (_androidVersion >= 29) {
              var onChange = (bool? v) async {
                if (v != null) {
                  await method.saveProperty(
                      _nightModePropertyName, "$v");
                  _androidNightMode = v;
                }
                setState(() {});
                themeEvent.broadcast();
              };
              list.add(
                SimpleDialogOption(
                  child: GestureDetector(
                    onTap: () {
                      onChange(!_androidNightMode);
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 3, bottom: 3),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: Theme
                                  .of(context)
                                  .dividerColor,
                              width: 0.5,
                          ),
                          bottom: BorderSide(
                              color: Theme
                                  .of(context)
                                  .dividerColor,
                              width: 0.5
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _androidNightMode,
                            onChanged: onChange,
                          ),
                          Text("随手机进入黑暗模式"),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            list.addAll(_themePackages
                .map((e) =>
                SimpleDialogOption(
                  child: Text(e.name()),
                  onPressed: () {
                    Navigator.of(context).pop(e.code());
                  },
                )
            ));
            return SimpleDialog(
              title: Text("选择主题"),
              children: list,
            );
          })
    },
  );
  if (theme != null) {
    method.saveTheme(theme);
    _changeThemeByCode(theme);
  }
}
