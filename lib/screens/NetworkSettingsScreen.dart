import 'package:flutter/material.dart';
import 'package:pikapi/screens/components/NetworkSetting.dart';

class NetworkSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('网络设置')),
        body: ListView(
          children: [
            NetworkSetting(),
          ],
        ),
      );
}
