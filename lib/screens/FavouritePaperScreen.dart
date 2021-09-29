import 'package:flutter/material.dart';
import 'package:pikapi/basic/Method.dart';
import '../basic/Entities.dart';
import 'components/ComicPager.dart';

// 收藏的漫画
class FavouritePaperScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FavouritePaperScreen();
}

class _FavouritePaperScreen extends State<FavouritePaperScreen> {
  Future<ComicsPage> _fetch(String _currentSort, int _currentPage) {
    return method.favouriteComics(_currentSort, _currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('收藏'),
      ),
      body: ComicPager(
        fetchPage: _fetch,
      ),
    );
  }
}
