import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/screens/ComicInfoScreen.dart';
import 'package:pikapi/basic/Method.dart';

import 'ItemBuilder.dart';
import 'Images.dart';

// 看过此本子的也在看
// 一直返回空数组, 所以没有使用
class Recommendation extends StatefulWidget {
  final String comicId;

  const Recommendation({Key? key, required this.comicId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecommendationState();
}

class _RecommendationState extends State<Recommendation> {
  late Future<List<ComicSimple>> _future = method.recommendation(widget.comicId);

  @override
  Widget build(BuildContext context) {
    return ItemBuilder(
      future: _future,
      successBuilder:
          (BuildContext context, AsyncSnapshot<List<ComicSimple>> snapshot) {
        var _comicList = snapshot.data!;
        var size = MediaQuery.of(context).size;
        var min = size.width < size.height ? size.width : size.height;
        var width = (min - 45) / 4;
        return Wrap(
          alignment: WrapAlignment.spaceAround,
          children: _comicList
              .map((e) => InkWell(
                    onTap: () {
                      var i = 0;
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ComicInfoScreen(comicId: e.id)),
                          (route) => i++ < 10);
                    },
                    child: Card(
                      child: Container(
                        width: width,
                        child: Column(
                          children: [
                            LayoutBuilder(builder: (BuildContext context,
                                BoxConstraints constraints) {
                              return RemoteImage(
                                width: width,
                                fileServer: e.thumb.fileServer,
                                path: e.thumb.path,
                              );
                            }),
                            Text(
                              e.title + '\n',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(height: 1.4),
                              strutStyle: StrutStyle(height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        );
      },
      onRefresh: () async =>
          setState(() => _future = method.recommendation(widget.comicId)),
    );
  }
}
