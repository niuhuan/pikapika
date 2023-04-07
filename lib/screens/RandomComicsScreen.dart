import 'package:flutter/material.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/basic/config/ListLayout.dart';
import 'package:pikapika/basic/config/ShadowCategories.dart';

import '../basic/config/Address.dart';
import 'components/ComicListBuilder.dart';
import 'components/Common.dart';
import 'components/RightClickPop.dart';

// 随机漫画页面
class RandomComicsScreen extends StatefulWidget {
  const RandomComicsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RandomComicsScreenState();
}

class _RandomComicsScreenState extends State<RandomComicsScreen> {

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
        title: const Text('随机本子'),
        actions: [
          commonPopMenu(context),
          addressPopMenu(context),
        ],
      ),
      body: ComicListBuilder(method.randomComics),
    );
  }
}
