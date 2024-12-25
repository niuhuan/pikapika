import 'package:flutter/material.dart';
import '../basic/config/PagerAction.dart';
import 'components/flutter_search_bar.dart' as fsb;
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/config/ShadowCategories.dart';
import 'package:pikapika/basic/store/Categories.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/components/RightClickPop.dart';
import '../basic/Entities.dart';
import '../basic/config/Address.dart';
import '../basic/config/IconLoading.dart';
import 'components/ComicList.dart';
import 'components/ComicPager.dart';
import 'components/Common.dart';
import 'components/GoDownloadSelect.dart';

// 搜索页面
class SearchScreen extends StatefulWidget {
  final String keyword;
  final String? category;

  const SearchScreen({
    Key? key,
    required this.keyword,
    this.category,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final _comicListController = ComicListController();
  late final TextEditingController _textEditController =
      TextEditingController(text: widget.keyword);
  late final fsb.SearchBar _searchBar = fsb.SearchBar(
    hintText: '搜索 ${categoryTitle(widget.category)}',
    controller: _textEditController,
    inBar: false,
    setState: setState,
    onSubmitted: (value) {
      if (value.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          mixRoute(
            builder: (context) => SearchScreen(
              keyword: value,
              category: widget.category,
            ),
          ),
        );
      }
    },
    buildDefaultAppBar: (BuildContext context) {
      return AppBar(
        title: Text("${categoryTitle(widget.category)} ${widget.keyword}"),
        actions: [
          commonPopMenu(
            context,
            setState: setState,
            comicListController: _comicListController,
          ),
          addressPopMenu(context),
          _chooseCategoryAction(),
          _searchBar.getSearchAction(context),
        ],
      );
    },
  );

  Widget _chooseCategoryAction() => IconButton(
        onPressed: () async {
          String? category = await chooseListDialog(context, '请选择分类', [
            categoryTitle(null),
            ...filteredList(
              storedCategories,
              (c) => !shadowCategories.contains(c),
            ),
          ]);
          if (category != null) {
            if (category == categoryTitle(null)) {
              category = null;
            }
            Navigator.of(context).pushReplacement(mixRoute(
              builder: (context) {
                return SearchScreen(
                  category: category,
                  keyword: widget.keyword,
                );
              },
            ));
          }
        },
        icon: const Icon(Icons.category),
      );

  Future<ComicsPage> _fetch(String _currentSort, int _currentPage) {
    if (currentPagerAction() == PagerAction.CONTROLLER &&
        _comicListController.selecting) {
      setState(() {
        _comicListController.selecting = false;
      });
    }
    if (widget.category == null) {
      return method.searchComics(widget.keyword, _currentSort, _currentPage);
    } else {
      return method.searchComicsInCategories(
        widget.keyword,
        _currentSort,
        _currentPage,
        [widget.category!],
      );
    }
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
      appBar: _comicListController.selecting
          ? downAppBar(context, _comicListController, setState)
          : _searchBar.build(context),
      body: ComicPager(
        fetchPage: _fetch,
        comicListController: _comicListController,
      ),
    );
  }
}
