import 'package:flutter/material.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/screens/ComicInfoScreen.dart';
import 'package:pikapika/basic/Method.dart';

import '../../basic/config/IconLoading.dart';
import 'ItemBuilder.dart';
import 'Images.dart';

// 看过此本子的也在看
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
                          mixRoute(
                              builder: (context) =>
                                  ComicInfoScreen(comicId: e.id)),
                          (route) => i++ < 10);
                    },
                    child: Card(
                      child: SizedBox(
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
                              style: const TextStyle(height: 1.4),
                              strutStyle: const StrutStyle(height: 1.4),
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
