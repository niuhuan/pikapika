import 'package:flutter/material.dart';
import 'package:pikapika/i18.dart';

import '../basic/Method.dart';
import 'components/ContentError.dart';
import 'components/ContentLoading.dart';
import 'components/ListView.dart';
import 'components/RightClickPop.dart';

class WebServerScreen extends StatefulWidget {
  const WebServerScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WebServerScreenState();
}

class _WebServerScreenState extends State<WebServerScreen> {
  late final Future<String> _ipFuture = method.clientIpSet();
  late Future _future = method.startWebServer();

  @override
  void dispose() {
    method.stopWebServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(
      child: buildScreen(context),
      context: context,
      canPop: true,
    );
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('screen.web_server.title')),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return ContentError(
                error: snapshot.error,
                stackTrace: snapshot.stackTrace,
                onRefresh: () async {
                  setState(() {
                    _future = method.startWebServer();
                  });
                });
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return ContentLoading(label: tr('app.loading'));
          }
          return PikaListView(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    FutureBuilder(
                      future: _ipFuture,
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasError) {
                          return Text(tr('screen.web_server.get_ip_failed'));
                        }
                        if (snapshot.connectionState != ConnectionState.done) {
                          return Text(tr('screen.web_server.getting_ip'));
                        }
                        return Text('${snapshot.data}');
                      },
                    ),
                    Text(tr('screen.web_server.port')),
                    const Text(''),
                    Text(tr('screen.web_server.usage_instruction')),
                    const Text(''),
                    Text(tr('screen.web_server.leave_notice')),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
