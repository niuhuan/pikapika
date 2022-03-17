import 'package:flutter/material.dart';
import 'package:pikapika/basic/config/Version.dart';
import 'package:pikapika/screens/components/Badge.dart';

import 'CategoriesScreen.dart';
import 'SpaceScreen.dart';

// MAIN UI 底部导航栏
class AppScreen extends StatefulWidget {
  const AppScreen({Key? key}) : super(key: key);

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  @override
  void initState() {
    versionEvent.subscribe(_onVersion);
    super.initState();
  }

  @override
  void dispose() {
    versionEvent.unsubscribe(_onVersion);
    super.dispose();
  }

  void _onVersion(dynamic a) {
    setState(() {});
  }

  static const List<Widget> _widgetOptions = <Widget>[
    CategoriesScreen(),
    SpaceScreen(),
  ];

  late int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: '浏览',
          ),
          BottomNavigationBarItem(
            icon: Badged(
              child: Icon(Icons.face),
              badge: latestVersion() == null ? null : "1",
            ),
            label: '我的',
          ),
        ],
        currentIndex: _selectedIndex,
        iconSize: 20,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: _onItemTapped,
      ),
    );
  }
}
