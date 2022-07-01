import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapika/basic/config/Version.dart';
import 'package:pikapika/screens/components/Badge.dart';
import 'package:uni_links/uni_links.dart';
import 'package:uri_to_file/uri_to_file.dart';

import '../basic/Common.dart';
import 'CategoriesScreen.dart';
import 'PkzArchiveScreen.dart';
import 'SpaceScreen.dart';

// MAIN UI 底部导航栏
class AppScreen extends StatefulWidget {
  const AppScreen({Key? key}) : super(key: key);

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  late StreamSubscription<String?> _linkSubscription;

  @override
  void initState() {
    versionEvent.subscribe(_onVersion);
    _linkSubscription = linkSubscript(context);
    super.initState();
  }

  @override
  void dispose() {
    versionEvent.unsubscribe(_onVersion);
    _linkSubscription.cancel();
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
          const BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: '浏览',
          ),
          BottomNavigationBarItem(
            icon: Badged(
              child: const Icon(Icons.face),
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
