import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../Method.dart';
import 'Address.dart';

var _imageAddresses = [
  "0",
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
];

late String _currentImageAddress;

Future<void> initImageAddress() async {
  _currentImageAddress = await method.getImageSwitchAddress();
}

int currentImageAddress() {
  return int.parse(_currentImageAddress);
}

String currentImageAddressName() => _currentImageAddress == "0"
    ? tr('net.no_address')
    : tr('net.address') + _currentImageAddress;

Future<void> chooseImageAddress(BuildContext context) async {
  String? choose = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(tr('settings.image_address.title')),
        children: <Widget>[
          ..._imageAddresses.map(
            (e) => SimpleDialogOption(
              child: ApiOptionRowImg(
                e == "0" ? tr('net.no_address') : tr('net.address') + e,
                e,
                key: Key("API:${e}"),
              ),
              onPressed: () {
                Navigator.of(context).pop(e);
              },
            ),
          ),
        ],
      );
    },
  );
  if (choose != null) {
    await method.setImageSwitchAddress(choose);
    _currentImageAddress = choose;
  }
}

Widget imageSwitchAddressSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr('settings.image_address.title')),
        subtitle: Text(currentImageAddressName()),
        onTap: () async {
          await chooseImageAddress(context);
          setState(() {});
        },
      );
    },
  );
}

class ApiOptionRowImg extends StatefulWidget {
  final String title;
  final String value;

  const ApiOptionRowImg(this.title, this.value, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ApiOptionRowImgState();
}

class _ApiOptionRowImgState extends State<ApiOptionRowImg> {
  late Future<int> _feature;

  @override
  void initState() {
    super.initState();
    if ("0" != widget.value) {
      _feature = method.pingImg(widget.value);
    } else {
      _feature = method.ping(currentAddress());
    }
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
                tr('settings.image_address.pinging'),
                Colors.blue,
              );
            }
            if (snapshot.hasError) {
              return PingStatus(
                tr('settings.image_address.failed'),
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
