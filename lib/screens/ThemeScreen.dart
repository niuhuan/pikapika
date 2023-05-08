import 'package:flutter/material.dart';

import '../basic/config/Themes.dart';
import 'components/ListView.dart';
import 'components/RightClickPop.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  @override
  Widget build(BuildContext context) {
    return rightClickPop(
      child: buildScreen(context),
      context: context,
      canPop: true,
    );
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("主题设置")),
      body: PikaListView(
        children: themeWidgets(context, setState),
      ),
    );
  }
}

List<Widget> themeWidgets(BuildContext context, void Function(VoidCallback fn) setState) {
  return [
    ListTile(
      onTap: () async {
        await chooseLightTheme(context);
        setState(() {});
      },
      title: const Text('主题'),
      subtitle: Text(currentLightThemeName()),
    ),
    ...androidNightModeDisplay
        ? [
      SwitchListTile(
          title: const Text("深色模式下使用不同的主题"),
          value: androidNightMode,
          onChanged: (value) async {
            await setAndroidNightMode(value);
            setState(() {});
          }),
    ]
        : [],
    ...androidNightModeDisplay && androidNightMode
        ? [
      ListTile(
        onTap: () async {
          await chooseDarkTheme(context);
          setState(() {});
        },
        title: const Text('主题 (深色模式)'),
        subtitle: Text(currentDarkThemeName()),
      ),
    ]
        : [],
  ];
}
