import 'package:flutter/material.dart';
import 'package:pikapi/basic/config/Address.dart';
import 'package:pikapi/basic/config/Proxy.dart';

// 网络设置
class NetworkSetting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NetworkSettingState();
}

class _NetworkSettingState extends State<NetworkSetting> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListTile(
            title: Text("分流"),
            subtitle: Text(currentAddressName()),
            onTap: () async {
              await chooseAddress(context);
              setState(() {});
            },
          ),
          ListTile(
            title: Text("代理服务器"),
            subtitle: Text(currentProxyName()),
            onTap: () async {
              await inputProxy(context);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
