import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/config/ContentFailedReloadAction.dart';

import 'package:pikapika/basic/enum/ErrorTypes.dart';

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
    late IconData iconData;
    switch (type) {
      case ERROR_TYPE_NETWORK:
        iconData = Icons.wifi_off_rounded;
        message = tr("app.network_error");
        break;
      case ERROR_TYPE_PERMISSION:
        iconData = Icons.highlight_off;
        message = tr("app.no_permission");
        break;
      case ERROR_TYPE_TIME:
        iconData = Icons.timer_off;
        message = tr("app.check_device_time");
        break;
      case ERROR_TYPE_UNDER_REVIEW:
        iconData = Icons.highlight_off;
        message = tr("app.resource_not_available");
        break;
      default:
        iconData = Icons.highlight_off;
        message = tr("app.something_went_wrong");
        break;
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
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
                SizedBox(
                  height: height,
                  child: Column(
                    children: [
                      Expanded(child: Container()),
                      Icon(
                        iconData,
                        size: iconSize,
                        color: Colors.grey.shade600,
                      ),
                      Container(height: min / 10),
                      Container(
                        padding: const EdgeInsets.only(
                          left: 30,
                          right: 30,
                        ),
                        child: Text(
                          message,
                          style: TextStyle(fontSize: textSize),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text('(${tr("app.click_refresh")})', style: TextStyle(fontSize: tipSize)),
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
              SizedBox(
                height: height,
                child: Column(
                  children: [
                    Expanded(child: Container()),
                    Icon(
                      iconData,
                      size: iconSize,
                      color: Colors.grey.shade600,
                    ),
                    Container(height: min / 10),
                    Container(
                      padding: const EdgeInsets.only(
                        left: 30,
                        right: 30,
                      ),
                      child: Text(
                        message,
                        style: TextStyle(fontSize: textSize),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text('(${tr("app.pull_down_refresh")})', style: TextStyle(fontSize: tipSize)),
                    Container(height: min / 15),
                    Text('$error', style: TextStyle(fontSize: infoSize)),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
