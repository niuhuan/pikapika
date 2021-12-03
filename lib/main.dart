import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/screens/InitScreen.dart';
import 'package:pikapika/basic/Navigatior.dart';

import 'basic/config/Themes.dart';

void main() {
  runApp(PikapikaApp());
}

class PikapikaApp extends StatefulWidget {
  const PikapikaApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PikapikaAppState();
}

class _PikapikaAppState extends State<PikapikaApp> {
  @override
  void initState() {
    themeEvent.subscribe(_onChangeTheme);
    super.initState();
  }

  @override
  void dispose() {
    themeEvent.unsubscribe(_onChangeTheme);
    super.dispose();
  }

  void _onChangeTheme(EventArgs? args) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: currentThemeData(),
      darkTheme: currentDarkTheme(),
      navigatorObservers: [navigatorObserver, routeObserver],
      home: InitScreen(),
    );
  }
}
