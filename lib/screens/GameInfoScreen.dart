import 'package:flutter/material.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/components/CommentMainType.dart';
import 'package:pikapika/screens/components/ContentError.dart';
import 'package:pikapika/screens/components/ContentLoading.dart';
import 'package:pikapika/screens/components/Images.dart';

import '../basic/config/IconLoading.dart';
import 'GameDownloadScreen.dart';
import 'components/CommentList.dart';
import 'components/GameTitleCard.dart';
import 'components/RightClickPop.dart';

// 游戏详情
class GameInfoScreen extends StatefulWidget {
  final String gameId;

  const GameInfoScreen(this.gameId, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GameInfoScreenState();
}

class _GameInfoScreenState extends State<GameInfoScreen> {
  late var _future = method.game(widget.gameId);
  late var _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return rightClickPop(
      child: buildScreen(context),
      context: context,
      canPop: true,
    );
  }

  Widget buildScreen(BuildContext context) {
    return FutureBuilder(
      key: _key,
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<GameInfo> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('加载出错'),
            ),
            body: ContentError(
                error: snapshot.error,
                stackTrace: snapshot.stackTrace,
                onRefresh: () async {
                  setState(() {
                    _future = method.game(widget.gameId);
                    _key = UniqueKey();
                  });
                }),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('加载中'),
            ),
            body: const ContentLoading(label: '加载中'),
          );
        }

        BorderRadius iconRadius = const BorderRadius.all(Radius.circular(6));
        double screenShootMargin = 10;
        double screenShootHeight = 200;
        TextStyle descriptionStyle = const TextStyle();

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            var info = snapshot.data!;
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: Text(info.title),
                ),
                body: ListView(
                  children: [
                    GameTitleCard(info),
                    Container(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 5,
                        bottom: 10,
                      ),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        child: MaterialButton(
                          color: Theme.of(context).colorScheme.secondary,
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.push(
                              context,
                              mixRoute(
                                builder: (context) => GameDownloadScreen(info),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: const Text('下载'),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: screenShootMargin,
                        bottom: screenShootMargin,
                      ),
                      height: screenShootHeight,
                      child: ListView(
                        padding: EdgeInsets.only(
                          left: screenShootMargin,
                          right: screenShootMargin,
                        ),
                        scrollDirection: Axis.horizontal,
                        children: info.screenshots
                            .map((e) => Container(
                                  margin: EdgeInsets.only(
                                    left: screenShootMargin,
                                    right: screenShootMargin,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: iconRadius,
                                    child: RemoteImage(
                                      height: screenShootHeight,
                                      fileServer: e.fileServer,
                                      path: e.path,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    Container(height: 20),
                    Column(
                      children: [
                        Container(
                          height: 40,
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(.025),
                          child: TabBar(
                            tabs: <Widget>[
                              const Tab(text: '详情 '),
                              Tab(text: '评论 (${info.commentsCount})'),
                            ],
                            indicatorColor:
                                Theme.of(context).colorScheme.secondary,
                            labelColor: Theme.of(context).colorScheme.secondary,
                            onTap: (val) async {
                              setState(() {
                                _tabIndex = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    _tabIndex == 0
                        ? Container(
                            padding: const EdgeInsets.all(20),
                            child:
                                Text(info.description, style: descriptionStyle),
                          )
                        : CommentList(CommentMainType.GAME, info.id),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  var _tabIndex = 0;
}
