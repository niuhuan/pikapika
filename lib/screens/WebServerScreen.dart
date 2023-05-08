import 'package:flutter/material.dart';

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
        title: const Text("下载 - Web服务器"),
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
            return const ContentLoading(label: '加载中');
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
                          return const Text('获取IP失败');
                        }
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Text('正在获取IP');
                        }
                        return Text('${snapshot.data}');
                      },
                    ),
                    const Text('端口号:8080'),
                    const Text(''),
                    const Text('在浏览器中输入"http://本设备ip:8080/"访问下载的漫画'),
                    const Text(''),
                    const Text('离开页面后服务器将关闭'),
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
