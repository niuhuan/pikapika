import 'package:flutter/material.dart';
import 'package:pikapika/basic/config/Address.dart';
import 'package:pikapika/basic/config/ImageAddress.dart';
import 'package:pikapika/basic/config/Proxy.dart';

// 网络设置
class NetworkSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          switchAddressSetting(),
          imageSwitchAddressSetting(),
          proxySetting(),
        ],
      ),
    );
  }
}
