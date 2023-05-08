import 'package:flutter/material.dart';
import 'package:pikapika/basic/Cross.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/components/ItemBuilder.dart';

import 'components/GameTitleCard.dart';
import 'components/ListView.dart';
import 'components/RightClickPop.dart';

// 游戏下载地址列表页
class GameDownloadScreen extends StatefulWidget {
  final GameInfo info;

  const GameDownloadScreen(this.info, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GameDownloadScreenState();
}

class _GameDownloadScreenState extends State<GameDownloadScreen> {
  late Future<List<String>> _future =
      method.downloadGame(widget.info.androidLinks[0]);

  @override
  Widget build(BuildContext context){
    return rightClickPop(
      child: buildScreen(context),
      context: context,
      canPop: true,
    );
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("下载 - ${widget.info.title}"),
      ),
      body: PikaListView(
        children: [
          GameTitleCard(widget.info),
          ItemBuilder(
            future: _future,
            onRefresh: () async  {
              setState(() {
                _future =
                    method.downloadGame(widget.info.androidLinks[0]);
              });
            },
            successBuilder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    child: const Text('获取到下载链接, 您只需要选择其中一个'),
                  ),
                  ...snapshot.data!.map((e) => _copyCard(e)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _copyCard(String string) {
    return InkWell(
      onTap: () {
        copyToClipBoard(context, string);
      },
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade500,
                  width: .5,
                  style: BorderStyle.solid,
                ),
              ),
              child: Text(string),
            ),
          ),
        ],
      ),
    );
  }
}
