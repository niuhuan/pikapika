import 'package:pikapika/i18.dart';
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
        appBar: AppBar(title: Text(tr('screen.network_settings.title'))),
        body: PikaListView(
          children: const [
            NetworkSetting(),
          ],
        ),
      );
}
