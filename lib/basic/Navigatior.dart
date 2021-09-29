import 'dart:async';

import 'package:flutter/material.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

Future<dynamic> navPushOrReplace(
    BuildContext context, WidgetBuilder builder) async {
  if (_depth < _depthMax) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: builder),
    );
  } else {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: builder),
    );
  }
}

var navigatorObserver = _NavigatorObserver();

const _depthMax = 15;
var _depth = 0;

int currentDepth() {
  return _depth;
}

class _NavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    _depth--;
    print("DEPTH : $_depth");
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _depth++;
    print("DEPTH : $_depth");
    super.didPush(route, previousRoute);
  }
}
