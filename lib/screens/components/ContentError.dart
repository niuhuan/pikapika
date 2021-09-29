import 'package:flutter/material.dart';
import 'package:pikapi/basic/config/ContentFailedReloadAction.dart';
import 'dart:ui';

import 'package:pikapi/basic/enum/ErrorTypes.dart';

class ContentError extends StatelessWidget {
  final Object? error;
  final StackTrace? stackTrace;
  final Future<void> Function() onRefresh;

  const ContentError({
    Key? key,
    required this.error,
    required this.stackTrace,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var type = errorType("$error");
    late String message;
    switch (type) {
      case ERROR_TYPE_NETWORK:
        message = "连接不上啦, 请检查网络";
        break;
      default:
        message = "啊哦, 被玩坏了";
        break;
    }
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      print("$error");
      print("$stackTrace");
      var width = constraints.maxWidth;
      var height = constraints.maxHeight;
      var min = width < height ? width : height;
      var iconSize = min / 2.3;
      var textSize = min / 16;
      var tipSize = min / 20;
      var infoSize = min / 30;
      if (contentFailedReloadAction ==
          ContentFailedReloadAction.TOUCH_LOADER) {
        return GestureDetector(
          onTap: onRefresh,
          child: ListView(
            children: [
              Container(
                height: height,
                child: Column(
                  children: [
                    Expanded(child: Container()),
                    Container(
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: iconSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Container(height: min / 10),
                    Container(
                      padding: EdgeInsets.only(
                        left: 30,
                        right: 30,
                      ),
                      child: Text(
                        message,
                        style: TextStyle(fontSize: textSize),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text('(点击刷新)', style: TextStyle(fontSize: tipSize)),
                    Container(height: min / 15),
                    Text('$error', style: TextStyle(fontSize: infoSize)),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            Container(
              height: height,
              child: Column(
                children: [
                  Expanded(child: Container()),
                  Container(
                    child: Icon(
                      Icons.wifi_off_rounded,
                      size: iconSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Container(height: min / 10),
                  Container(
                    padding: EdgeInsets.only(
                      left: 30,
                      right: 30,
                    ),
                    child: Text(
                      message,
                      style: TextStyle(fontSize: textSize),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text('(下拉刷新)', style: TextStyle(fontSize: tipSize)),
                  Container(height: min / 15),
                  Text('$error', style: TextStyle(fontSize: infoSize)),
                  Expanded(child: Container()),
                ],
              ),
            ),
          ],
        ),
      );
    },);
  }
}
