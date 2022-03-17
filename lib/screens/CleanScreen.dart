import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pikapika/basic/Channels.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/components/FitButton.dart';
import 'components/ContentLoading.dart';

// 清理
class CleanScreen extends StatefulWidget {
  const CleanScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CleanScreenState();
}

class _CleanScreenState extends State<CleanScreen> {
  late bool _cleaning = false;
  late String _cleaningMessage = "清理中";
  late String _cleanResult = "";

  @override
  void initState() {
    registerEvent(_onMessageChange, "EXPORT");
    super.initState();
  }

  @override
  void dispose() {
    unregisterEvent(_onMessageChange);
    super.dispose();
  }

  void _onMessageChange(String event) {
    setState(() {
      _cleaningMessage = event;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cleaning) {
      return Scaffold(
        body: ContentLoading(label: _cleaningMessage),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('清理'),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: _cleanResult != "" ? Text(_cleanResult) : Container(),
          ),
          SizedBox(
            height: 50,
            child: FitButton(
              text: '清理网络缓存',
              onPressed: () {
                processCleanAction(method.cleanNetworkCache);
              },
            ),
          ),
          SizedBox(
            height: 50,
            child: FitButton(
              text: '清理图片缓存',
              onPressed: () {
                processCleanAction(method.cleanImageCache);
              },
            ),
          ),
          SizedBox(
            height: 50,
            child: FitButton(
              text: '清理全部缓存',
              onPressed: () {
                processCleanAction(method.clean);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future processCleanAction(Future Function() action) async {
    try {
      setState(() {
        _cleaning = true;
      });
      await action();
      setState(() {
        _cleanResult = "清理成功";
      });
    } catch (e) {
      setState(() {
        _cleanResult = "清理失败 $e";
      });
    } finally {
      setState(() {
        _cleaning = false;
      });
    }
  }
}
