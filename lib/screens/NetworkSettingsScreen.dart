import 'package:flutter/material.dart';
import 'package:pikapika/screens/components/NetworkSetting.dart';

import 'components/ListView.dart';
import 'components/RightClickPop.dart';

class NetworkSettingsScreen extends StatelessWidget {
  const NetworkSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return rightClickPop(
      child: buildScreen(context),
      context: context,
      canPop: true,
    );
  }

  Widget buildScreen(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('网络设置')),
        body: PikaListView(
          children: const [
            NetworkSetting(),
          ],
        ),
      );
}
