import 'dart:io';

import 'package:flutter/material.dart';

class CloseAppScreen extends StatelessWidget {
  const CloseAppScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("提示"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 关闭应用
            exit(0);
          },
          child: const Text("请关闭应用重新打开"),
        ),
      ),
    );
  }
}
