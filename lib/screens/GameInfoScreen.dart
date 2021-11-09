import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Method.dart';
import 'package:pikapi/screens/components/ContentError.dart';
import 'package:pikapi/screens/components/ContentLoading.dart';
import 'package:pikapi/screens/components/Images.dart';

import 'GameDownloadScreen.dart';
import 'components/GameTitleCard.dart';

// 游戏详情
class GameInfoScreen extends StatefulWidget {
  final String gameId;

  const GameInfoScreen(this.gameId);

  @override
  State<StatefulWidget> createState() => _GameInfoScreenState();
}

class _GameInfoScreenState extends State<GameInfoScreen> {
  late var _future = method.game(widget.gameId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<GameInfo> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('加载出错'),
            ),
            body: ContentError(
                error: snapshot.error,
                stackTrace: snapshot.stackTrace,
                onRefresh: () async {
                  setState(() {
                    _future = method.game(widget.gameId);
                  });
                }),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: Text('加载中'),
            ),
            body: ContentLoading(label: '加载中'),
          );
        }

        BorderRadius iconRadius = BorderRadius.all(Radius.circular(6));
        double screenShootMargin = 10;
        double screenShootHeight = 200;
        TextStyle descriptionStyle = TextStyle();

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            var info = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: Text(info.title),
              ),
              body: ListView(
                children: [
                  GameTitleCard(info),
                  Container(
                    padding: EdgeInsets.only(
                      left: 20, right: 20, top: 5, bottom: 10,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      child: MaterialButton(
                        color: Theme.of(context).colorScheme.secondary,
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GameDownloadScreen(info)),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: Text('下载'),
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
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Text(info.description, style: descriptionStyle),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
