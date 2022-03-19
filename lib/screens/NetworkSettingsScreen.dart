import 'package:flutter/material.dart';
import 'package:pikapika/screens/components/NetworkSetting.dart';

import 'components/RightClickPop.dart';

class NetworkSettingsScreen extends StatelessWidget {
  const NetworkSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return RightClickPop(buildScreen(context));
  }

  Widget buildScreen(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('网络设置')),
        body: ListView(
          children: const [
            NetworkSetting(),
          ],
        ),
      );
}
