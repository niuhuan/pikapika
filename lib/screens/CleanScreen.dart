import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pikapi/basic/Channels.dart';
import 'package:pikapi/basic/Method.dart';
import 'components/ContentLoading.dart';

// 清理
class CleanScreen extends StatefulWidget {
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
        title: Text('清理'),
      ),
      body: ListView(
        children: [
          MaterialButton(
            onPressed: () async {
              try {
                setState(() {
                  _cleaning = true;
                });
                await method.clean();
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
            },
            child: Container(
              padding: EdgeInsets.all(20),
              child: Text('清理'),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: _cleanResult != "" ? Text(_cleanResult) : Container(),
          )
        ],
      ),
    );
  }
}
