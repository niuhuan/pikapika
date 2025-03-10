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

class ComicSearchAuthorScreenButton extends StatelessWidget {
  const ComicSearchAuthorScreenButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.person_search),
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SearchAuthorScreen(
                author: '',
              ),
            ),
          );
        },
      );
}

// 搜索页面
class SearchAuthorScreen extends StatefulWidget {
  final String author;
  final String? category;

  const SearchAuthorScreen({
    Key? key,
    required this.author,
    this.category,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchAuthorScreenState();
}

class _SearchAuthorScreenState extends State<SearchAuthorScreen> {
  late final _comicListController = ComicListController();
  late final TextEditingController _textEditController =
      TextEditingController(text: widget.author);
  late final fsb.SearchBar _searchBar = fsb.SearchBar(
    hintText: '搜索 按作者 + ${categoryTitle(widget.category)}',
    controller: _textEditController,
    inBar: false,
    setState: setState,
    onSubmitted: (value) {
      if (value.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          mixRoute(
            builder: (context) => SearchAuthorScreen(
              author: value,
              category: widget.category,
            ),
          ),
        );
      }
    },
    buildDefaultAppBar: (BuildContext context) {
      return AppBar(
        title:
            Text("按作者: ${widget.author} + ${categoryTitle(widget.category)}"),
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
                return SearchAuthorScreen(
                  category: category,
                  author: widget.author,
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
      return method.comics(
        _currentSort,
        _currentPage,
        author: widget.author,
      );
    } else {
      return method.comics(
        _currentSort,
        _currentPage,
        author: widget.author,
        category: widget.category!,
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
