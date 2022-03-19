import 'package:flutter/material.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/basic/config/ListLayout.dart';
import 'package:pikapika/basic/config/ShadowCategories.dart';

import 'components/ComicListBuilder.dart';
import 'components/RightClickPop.dart';

// 随机漫画页面
class RandomComicsScreen extends StatefulWidget {
  const RandomComicsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RandomComicsScreenState();
}

class _RandomComicsScreenState extends State<RandomComicsScreen> {
  Future<List<ComicSimple>> _future = method.randomComics();

  Future<void> _reload() async {
    setState(() {
      _future = method.randomComics();
    });
  }

  @override
  Widget build(BuildContext context){
    return RightClickPop(buildScreen(context));
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('随机本子'),
        actions: [
          shadowCategoriesActionButton(context),
          chooseLayoutActionButton(context),
        ],
      ),
      body: ComicListBuilder(_future, _reload),
    );
  }
}
