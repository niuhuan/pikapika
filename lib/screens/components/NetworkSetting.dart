import 'package:flutter/material.dart';
import 'package:pikapika/basic/config/Address.dart';
import 'package:pikapika/basic/config/ImageAddress.dart';
import 'package:pikapika/basic/config/Proxy.dart';
import 'package:pikapika/basic/config/UseApiLoadImage.dart';

// 网络设置
class NetworkSetting extends StatelessWidget {
  const NetworkSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        switchAddressSetting(),
        imageSwitchAddressSetting(),
        useApiLoadImageSetting(),
        proxySetting(),
        reloadSwitchAddressSetting(),
      ],
    );
  }
}
