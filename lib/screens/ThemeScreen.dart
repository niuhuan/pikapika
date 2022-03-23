import 'package:flutter/material.dart';

import '../basic/config/Themes.dart';
import 'components/RightClickPop.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  @override
  Widget build(BuildContext context) {
    return RightClickPop(buildScreen(context));
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("主题设置")),
      body: ListView(
        children: [
          const Divider(),
          ListTile(
            onTap: () async {
              await chooseLightTheme(context);
              setState(() {});
            },
            title: const Text('主题'),
            subtitle: Text(currentLightThemeName()),
          ),
          const Divider(),
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
          const Divider(),
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
          const Divider(),
        ],
      ),
    );
  }
}
