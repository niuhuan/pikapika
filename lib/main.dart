import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:pikapi/screens/InitScreen.dart';
import 'package:pikapi/basic/Navigatior.dart';

import 'basic/config/Themes.dart';

void main() {
  runApp(PikachuApp());
}

class PikachuApp extends StatefulWidget {
  const PikachuApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PikachuAppState();
}

class _PikachuAppState extends State<PikachuApp> {
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
      theme: currentThemeData(),
      navigatorObservers: [navigatorObserver, routeObserver],
      home: InitScreen(),
    );
  }
}
