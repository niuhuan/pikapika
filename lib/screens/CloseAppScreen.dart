import 'dart:io';

import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';

class CloseAppScreen extends StatelessWidget {
  const CloseAppScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('screen.close_app.title')),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 关闭应用
            exit(0);
          },
          child: Text(tr('screen.close_app.close_app')),
        ),
      ),
    );
  }
}
