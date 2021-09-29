import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Method.dart';
import 'package:pikapi/basic/config/ListLayout.dart';

import 'components/ComicListBuilder.dart';

class RandomComicsScreen extends StatefulWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('随机本子'),
        actions: [
          chooseLayoutAction(context),
        ],
      ),
      body: ComicListBuilder(_future, _reload),
    );
  }
}
