import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/Method.dart';
import '../basic/Entities.dart';
import 'components/ComicPager.dart';
import 'components/RightClickPop.dart';

// 收藏的漫画
class FavouritePaperScreen extends StatefulWidget {
  const FavouritePaperScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FavouritePaperScreen();
}

class _FavouritePaperScreen extends State<FavouritePaperScreen> {
  Future<ComicsPage> _fetch(String _currentSort, int _currentPage) {
    return method.favouriteComics(_currentSort, _currentPage);
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
        title: Text(tr('screen.favourite_paper.favourite')),
      ),
      body: ComicPager(
        fetchPage: _fetch,
      ),
    );
  }
}
