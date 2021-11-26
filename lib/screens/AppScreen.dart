import 'package:flutter/material.dart';
import 'package:pikapika/basic/config/GuiAnimation.dart';
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
    const CategoriesScreen(),
    const SpaceScreen(),
  ];

  late int _selectedIndex = 0;
  PageController _pageController = PageController(initialPage: 0);

  void _onItemTapped(int index) {
    if (currentGuiAnimation()) {
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      );
    } else {
      _pageController.jumpToPage(index);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      this._selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _widgetOptions,
        onPageChanged: _onPageChanged,
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
