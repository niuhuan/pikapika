/// 分流地址

// addr = "172.67.7.24:443"
// addr = "104.20.180.50:443"
// addr = "172.67.208.169:443"

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/config/ImageAddress.dart';
import 'package:pikapika/basic/config/UseApiLoadImage.dart';

import '../Method.dart';

var _addresses = [
  "0",
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  "10",
];

late String _currentAddress;

Future<void> initAddress() async {
  _currentAddress = await method.getSwitchAddress();
}

String currentAddress() => _currentAddress;

String currentAddressName() => _currentAddress == "0" ? tr('app.no_address') : tr('net.address') + _currentAddress;

Widget switchAddressSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr('net.address')),
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
        title: Text(tr('net.address_sync')),
        onTap: () async {
          String? choose = await chooseListDialog(context, tr('net.address_sync'), [
            tr('net.address_sync_from_server'),
            tr('net.address_sync_reset'),
          ]);
          if (choose != null) {
            if (choose == tr('net.address_sync_from_server')) {
              try {
                await method.reloadSwitchAddress();
                defaultToast(context, tr('net.address_sync_success'));
              } catch (e, s) {
                print("$e\n$s");
                defaultToast(context, tr('net.address_sync_failed'));
              }
            } else if (choose == tr('net.address_sync_reset')) {
              try {
                await method.resetSwitchAddress();
                defaultToast(context, tr('net.address_sync_reset_success'));
              } catch (e, s) {
                print("$e\n$s");
                defaultToast(context, tr('net.address_sync_reset_failed'));
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
        title: Text(tr('net.choose_address')),
        children: <Widget>[
          ..._addresses.map(
            (e) => SimpleDialogOption(
              child: ApiOptionRow(
                "${tr('net.address')}$e",
                e,
                key: Key("API:$e"),
              ),
              onPressed: () {
                Navigator.of(context).pop(e);
              },
            ),
          ),
          SimpleDialogOption(
            child: Text(tr('net.address_sync')),
            onPressed: () {
              Navigator.of(context).pop(tr('net.address_sync'));
            },
          )
        ],
      );
    },
  );
  if (choose != null) {
    if (tr('net.address_sync') == choose) {
      try {
        await method.reloadSwitchAddress();
        defaultToast(context, tr('net.address_sync_success'));
      } catch (e, s) {
        print("$e\n$s");
        defaultToast(context, tr('net.address_sync_failed'));
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
          title: Text("${tr('net.address')} (${currentAddressName()})"),
        ),
      ),
      PopupMenuItem<int>(
        value: 1,
        child: ListTile(
          leading: const Icon(Icons.image_search),
          title: Text("${tr('net.image_address')} (${currentImageAddressName()})"),
        ),
      ),
      PopupMenuItem<int>(
        value: 2,
        child: ListTile(
          leading: const Icon(Icons.network_ping),
          title: Text("${tr('net.use_api_load_image')} (${currentUseApiLoadImageName()})"),
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
              return PingStatus(
                tr('net.ping_testing'),
                Colors.blue,
              );
            }
            if (snapshot.hasError) {
              return PingStatus(
                tr('net.ping_failed'),
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
