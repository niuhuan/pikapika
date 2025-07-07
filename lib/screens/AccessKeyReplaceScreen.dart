import 'package:easy_localization/easy_localization.dart';
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
      _message = tr("app.error") + " : $e";
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _content() {
    if (_loading) {
      return ContentLoading(label: tr('app.loading'));
    }
    if (_success) {
      return Text(tr('app.pat.success'));
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
          child: Text(tr("app.confirm")),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("screen.access_key_replace.title")),
      ),
      body: Center(
        child: _content(),
      ),
    );
  }
}
