import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/config/PagerAction.dart';
import 'package:pikapika/basic/config/ShadowCategoriesEvent.dart';
import 'package:pikapika/basic/enum/Sort.dart';
import 'package:pikapika/screens/components/ComicList.dart';
import 'package:pikapika/screens/components/ContentError.dart';
import 'package:pikapika/screens/components/FitButton.dart';
import '../../basic/Common.dart';
import '../../basic/config/IsPro.dart';
import 'ContentLoading.dart';

// 漫画列页
class ComicPager extends StatefulWidget {
  final ComicListController? comicListController;
  final Future<ComicsPage> Function(String sort, int page) fetchPage;

  const ComicPager({
    required this.fetchPage,
    Key? key,
    // required
    this.comicListController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicPagerState();
}

class _ComicPagerState extends State<ComicPager> {
  @override
  void initState() {
    shadowCategoriesEvent.subscribe(_onShadowChange);
    super.initState();
  }

  @override
  void dispose() {
    shadowCategoriesEvent.unsubscribe(_onShadowChange);
    super.dispose();
  }

  void _onShadowChange(EventArgs? args) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    switch (currentPagerAction()) {
      case PagerAction.CONTROLLER:
        return ControllerComicPager(
          fetchPage: widget.fetchPage,
          comicListController: widget.comicListController,
        );
      case PagerAction.STREAM:
        return StreamComicPager(
          fetchPage: widget.fetchPage,
          comicListController: widget.comicListController,
        );
      default:
        return Container();
    }
  }
}

class ControllerComicPager extends StatefulWidget {
  final ComicListController? comicListController;
  final Future<ComicsPage> Function(String sort, int page) fetchPage;

  const ControllerComicPager({
    Key? key,
    required this.fetchPage,
    required this.comicListController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ControllerComicPagerState();
}

class _ControllerComicPagerState extends State<ControllerComicPager> {
  final TextEditingController _textEditController =
      TextEditingController(text: '');
  late String _currentSort = SORT_DEFAULT;
  late int _currentPage = 1;
  late Future<ComicsPage> _pageFuture;

  Future<dynamic> _load() async {
    setState(() {
      _pageFuture = widget.fetchPage(_currentSort, _currentPage);
    });
  }

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _pageFuture,
      builder: (BuildContext context, AsyncSnapshot<ComicsPage> snapshot) {
        if (snapshot.connectionState == ConnectionState.none) {
          return const Text('初始化');
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const ContentLoading(label: '加载中');
        }
        if (snapshot.hasError) {
          return ContentError(
            error: snapshot.error,
            stackTrace: snapshot.stackTrace,
            onRefresh: _load,
          );
        }
        var comicsPage = snapshot.data!;
        return Scaffold(
          appBar: _buildAppBar(comicsPage, context),
          body: ComicList(
            comicsPage.docs,
            appendWidget: _buildNextButton(comicsPage),
            listController: widget.comicListController,
          ),
        );
      },
    );
  }

  PreferredSize _buildAppBar(ComicsPage comicsPage, BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(40),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: .5,
              style: BorderStyle.solid,
              color: Colors.grey[200]!,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(width: 10),
                DropdownButton(
                  items: items,
                  value: _currentSort,
                  onChanged: (String? value) {
                    if (value != null) {
                      _currentPage = 1;
                      _currentSort = value;
                      _load();
                    }
                  },
                ),
              ],
            ),
            InkWell(
              onTap: () {
                _textEditController.clear();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Card(
                        child: TextField(
                          controller: _textEditController,
                          decoration: const InputDecoration(
                            labelText: "请输入页数：",
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'\d+')),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('取消'),
                        ),
                        MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                            var text = _textEditController.text;
                            if (text.isEmpty || text.length > 5) {
                              return;
                            }
                            var num = int.parse(text);
                            if (num == 0 || num > comicsPage.pages) {
                              return;
                            }
                            if (num > 10 && !isPro) {
                              defaultToast(context, "发电以后才能看10页以后的内容");
                              return;
                            }
                            _currentPage = num;
                            _load();
                          },
                          child: const Text('确定'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Row(
                children: [
                  Text("第 ${comicsPage.page} / ${comicsPage.pages} 页"),
                ],
              ),
            ),
            Row(
              children: [
                MaterialButton(
                  minWidth: 0,
                  onPressed: () {
                    if (comicsPage.page > 1) {
                      _currentPage = comicsPage.page - 1;
                      _load();
                    }
                  },
                  child: const Text('上一页'),
                ),
                MaterialButton(
                  minWidth: 0,
                  onPressed: () {
                    if (comicsPage.page < comicsPage.pages) {
                      if (_currentPage >= 10 && !isPro) {
                        defaultToast(context, "发电以后才能看10页以后的内容");
                        return;
                      }
                      _currentPage = comicsPage.page + 1;
                      _load();
                    }
                  },
                  child: const Text('下一页'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildNextButton(ComicsPage comicsPage) {
    if (comicsPage.page < comicsPage.pages) {
      return FitButton(
        onPressed: () {
          if (_currentPage >= 10 && !isPro) {
            defaultToast(context, "发电以后才能看10页以后的内容");
            return;
          }
          _currentPage = comicsPage.page + 1;
          _load();
        },
        text: '下一页',
      );
    }
    return null;
  }
}

class StreamComicPager extends StatefulWidget {
  final ComicListController? comicListController;
  final Future<ComicsPage> Function(String sort, int page) fetchPage;

  const StreamComicPager({
    Key? key,
    required this.fetchPage,
    required this.comicListController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StreamComicPagerState();
}

class _StreamComicPagerState extends State<StreamComicPager> {
  final TextEditingController _textEditController =
      TextEditingController(text: '');
  final _scrollController = ScrollController();
  late String _currentSort = SORT_DEFAULT;
  late int _currentPage = 1;
  late int _maxPage = 0;
  late List<ComicSimple> _list = [];
  late bool _loading = false;
  late bool _over = false;
  late bool _error = false;
  late bool _noPro = false;

  // late Future<dynamic> _pageFuture;

  _onSetOffset(int i) {
    _list.clear();
    _currentPage = i;
    _load();
  }

  void _onScroll() {
    if (_over || _error || _loading || _noPro) {
      return;
    }
    if (_scrollController.offset + MediaQuery.of(context).size.height / 2 <
        _scrollController.position.maxScrollExtent) {
      return;
    }
    _load();
  }

  Future<dynamic> _load() async {
    setState(() {
      //_pageFuture =
      _fetch();
    });
  }

  Future<dynamic> _fetch() async {
    _error = false;
    setState(() {
      _loading = true;
    });
    try {
      var page = await widget.fetchPage(_currentSort, _currentPage);
      setState(() {
        _currentPage++;
        _maxPage = page.pages;
        _list.addAll(page.docs);
        _over = page.page >= page.pages;
        _noPro = _currentPage > 10 && !isPro;
      });
    } catch (e, s) {
      _error = true;
      print("$e\n$s");
      rethrow;
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    _load();
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _textEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: ComicList(
        _list,
        scrollController: _scrollController,
        appendWidget: _buildLoadingCell(),
        listController: widget.comicListController,
      ),
    );
  }

  PreferredSize _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(40),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: .5,
              style: BorderStyle.solid,
              color: Colors.grey[200]!,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(width: 10),
                DropdownButton(
                  items: items,
                  value: _currentSort,
                  onChanged: (String? value) {
                    if (value != null) {
                      _list = [];
                      _currentPage = 1;
                      _currentSort = value;
                      _load();
                    }
                  },
                ),
              ],
            ),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    _textEditController.clear();
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Card(
                            child: TextField(
                              controller: _textEditController,
                              decoration: const InputDecoration(
                                labelText: "请输入页数：",
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'\d+')),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            MaterialButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('取消'),
                            ),
                            MaterialButton(
                              onPressed: () {
                                Navigator.pop(context);
                                var text = _textEditController.text;
                                if (text.isEmpty || text.length > 5) {
                                  return;
                                }
                                var num = int.parse(text);
                                if (num == 0 || num > _maxPage) {
                                  return;
                                }
                                if (_currentPage >= 10 && !isPro) {
                                  defaultToast(context, "发电以后才能看10页以后的内容");
                                  return;
                                }
                                _currentPage = num;
                                _onSetOffset(num);
                              },
                              child: const Text('确定'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Text("已经加载 ${_currentPage - 1} / $_maxPage 页"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildLoadingCell() {
    if (_noPro) {
      return FitButton(onPressed: () {}, text: '发电以后才能看10页以后的内容');
    }
    if (_error) {
      return FitButton(
          onPressed: () {
            setState(() {
              _error = false;
            });
            _load();
          },
          text: '网络错误 / 点击刷新');
    }
    if (_loading) {
      return FitButton(onPressed: () {}, text: '加载中');
    }
    return null;
  }
}
