import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../Method.dart';
import 'Address.dart';

var _imageAddresses = {
  "0": "不分流",
  "1": "分流1",
  "2": "分流2",
  "3": "分流3",
  "4": "分流4",
  "5": "分流5",
  "6": "分流6",
};

late String _currentImageAddress;

Future<void> initImageAddress() async {
  _currentImageAddress = await method.getImageSwitchAddress();
}

int currentImageAddress() {
  return int.parse(_currentImageAddress);
}

String currentImageAddressName() => _imageAddresses[_currentImageAddress] ?? "";

Future<void> chooseImageAddress(BuildContext context) async {
  String? choose = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text('选择图片分流'),
        children: <Widget>[
          ..._imageAddresses.entries.map(
            (e) => SimpleDialogOption(
              child: ApiOptionRowImg(
                e.value,
                e.key,
                key: Key("API:${e.key}"),
              ),
              onPressed: () {
                Navigator.of(context).pop(e.key);
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
        title: const Text("图片分流"),
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
    }else{
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
