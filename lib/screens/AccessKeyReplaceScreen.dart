import 'package:flutter/material.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/components/ContentLoading.dart';

import '../basic/config/IsPro.dart';

class AccessKeyReplaceScreen extends StatefulWidget {
  final String accessKey;

  const AccessKeyReplaceScreen({Key? key, required this.accessKey})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AccessKeyReplaceScreenState();
}

class _AccessKeyReplaceScreenState extends State<AccessKeyReplaceScreen> {
  var _loading = false;
  var _message = "";
  var _success = false;

  _set() async {
    setState(() {
      _loading = true;
    });
    try {
      await method.setPatAccessKey(widget.accessKey);
      await reloadIsPro();
      _success = true;
    } catch (e) {
      _message = "错误 : $e";
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _content() {
    if (_loading) {
      return const ContentLoading(label: "加载中");
    }
    if (_success) {
      return const Text("您的赞助登录成功, 请返回");
    }
    return Column(
      children: [
        Expanded(child: Container()),
        Text(widget.accessKey),
        Text(_message),
        Container(
          height: 10,
        ),
        MaterialButton(
          color: Colors.grey,
          onPressed: _set,
          child: const Text("确认"),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("更换PAT账户"),
      ),
      body: Center(
        child: _content(),
      ),
    );
  }
}
