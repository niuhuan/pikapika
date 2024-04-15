/// 分流地址

// addr = "172.67.7.24:443"
// addr = "104.20.180.50:443"
// addr = "172.67.208.169:443"

import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/config/ImageAddress.dart';
import 'package:pikapika/basic/config/UseApiLoadImage.dart';

import '../Method.dart';

var _addresses = {
  "0": "不分流",
  "1": "分流1",
  "2": "分流2",
  "3": "分流3",
  "4": "分流4",
  "5": "分流5",
  "6": "分流6",
  "7": "分流7",
  "8": "分流8",
  "9": "分流9",
  "10": "分流A",
};

late String _currentAddress;

Future<void> initAddress() async {
  _currentAddress = await method.getSwitchAddress();
}

String currentAddress() => _currentAddress;

String currentAddressName() => _addresses[_currentAddress] ?? "";

Widget switchAddressSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("分流"),
        subtitle: Text(currentAddressName()),
        onTap: () async {
          await chooseAddressAndSwitch(context);
          setState(() {});
        },
      );
    },
  );
}

Widget reloadSwitchAddressSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("分流同步"),
        onTap: () async {
          String? choose = await chooseListDialog(context, "分流同步", [
            "从服务器获取最新的分流地址",
            "重制分流为默认值",
          ]);
          if (choose != null) {
            if (choose == "从服务器获取最新的分流地址") {
              try {
                await method.reloadSwitchAddress();
                defaultToast(context, "分流2/3已同步");
              } catch (e, s) {
                print("$e\n$s");
                defaultToast(context, "分流同步失败");
              }
            } else if (choose == "重制分流为默认值") {
              try {
                await method.resetSwitchAddress();
                defaultToast(context, "分流2/3已重制为默认值");
              } catch (e, s) {
                print("$e\n$s");
                defaultToast(context, "分流重制失败");
              }
            }
          }
        },
      );
    },
  );
}

Future chooseAddressAndSwitch(BuildContext context) async {
  String? choose = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text('选择分流'),
        children: <Widget>[
          ..._addresses.entries.map(
            (e) => SimpleDialogOption(
              child: ApiOptionRow(
                e.value,
                e.key,
                key: Key("API:${e.key}"),
              ),
              onPressed: () {
                Navigator.of(context).pop(e.key);
              },
            ),
          ),
          SimpleDialogOption(
            child: const Text("分流同步"),
            onPressed: () {
              Navigator.of(context).pop("分流同步");
            },
          )
        ],
      );
    },
  );
  if (choose != null) {
    if ("分流同步" == choose) {
      try {
        await method.reloadSwitchAddress();
        defaultToast(context, "分流2/3已同步");
      } catch (e, s) {
        print("$e\n$s");
        defaultToast(context, "分流同步失败");
      }
      return;
    }
    await method.setSwitchAddress(choose);
    _currentAddress = choose;
  }
}

Widget addressPopMenu(BuildContext context) {
  return PopupMenuButton<int>(
    icon: const Icon(Icons.webhook),
    itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
      PopupMenuItem<int>(
        value: 0,
        child: ListTile(
          leading: const Icon(Icons.share),
          title: Text("分流 (${currentAddressName()})"),
        ),
      ),
      PopupMenuItem<int>(
        value: 1,
        child: ListTile(
          leading: const Icon(Icons.image_search),
          title: Text("图片分流 (${currentImageAddressName()})"),
        ),
      ),
       PopupMenuItem<int>(
        value: 2,
        child: ListTile(
          leading: const Icon(Icons.network_ping),
          title: Text("用API加载图片 (${currentUseApiLoadImageName()})"),
        ),
      ),
    ],
    onSelected: (int value) {
      switch (value) {
        case 0:
          chooseAddressAndSwitch(context);
          break;
        case 1:
          chooseImageAddress(context);
          break;
        case 2:
          chooseUseApiLoadImage(context);
          break;
      }
    },
  );
}

class ApiOptionRow extends StatefulWidget {
  final String title;
  final String value;

  const ApiOptionRow(this.title, this.value, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ApiOptionRowState();
}

class _ApiOptionRowState extends State<ApiOptionRow> {
  late Future<int> _feature;

  @override
  void initState() {
    super.initState();
    _feature = method.ping(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.title),
        Expanded(child: Container()),
        FutureBuilder(
          future: _feature,
          builder: (
            BuildContext context,
            AsyncSnapshot<int> snapshot,
          ) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const PingStatus(
                "测速中",
                Colors.blue,
              );
            }
            if (snapshot.hasError) {
              return const PingStatus(
                "失败",
                Colors.red,
              );
            }
            int ping = snapshot.requireData;
            if (ping <= 200) {
              return PingStatus(
                "${ping}ms",
                Colors.green,
              );
            }
            if (ping <= 500) {
              return PingStatus(
                "${ping}ms",
                Colors.yellow,
              );
            }
            return PingStatus(
              "${ping}ms",
              Colors.orange,
            );
          },
        ),
      ],
    );
  }
}

class PingStatus extends StatelessWidget {
  final String title;
  final Color color;

  const PingStatus(this.title, this.color, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '\u2022',
          style: TextStyle(
            color: color,
          ),
        ),
        Text(" $title"),
      ],
    );
  }
}
