import 'package:flutter/material.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/components/ContentError.dart';
import 'package:pikapika/screens/components/ListView.dart';

import '../basic/Entities.dart';
import '../basic/config/CategoriesColumnCount.dart';
import '../basic/config/CategoriesSort.dart';
import 'CategoriesScreen.dart';
import 'components/Images.dart';

class CategoriesSortScreen extends StatefulWidget {
  const CategoriesSortScreen({Key? key}) : super(key: key);

  @override
  _CategoriesSortScreenState createState() => _CategoriesSortScreenState();
}

class _CategoriesSortScreenState extends State<CategoriesSortScreen> {
  late Key _key = UniqueKey();
  late Future<List<Category>> _future = method.categories();

  _reload() {
    setState(() {
      _key = UniqueKey();
      _future = method.categories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      key: _key,
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('分类排序'),
            ),
            body: ContentError(
              error: snapshot.error,
              stackTrace: snapshot.stackTrace,
              onRefresh: () async {
                _reload();
              },
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('分类排序'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return CategoriesSortPanel(snapshot.requireData);
      },
    );
  }
}

class CategoriesSortPanel extends StatefulWidget {
  final List<Category> requireData;

  const CategoriesSortPanel(this.requireData, {Key? key}) : super(key: key);

  @override
  _CategoriesSortPanelState createState() => _CategoriesSortPanelState();
}

class _CategoriesSortPanelState extends State<CategoriesSortPanel> {
  final List<String> _categoriesSort = [];

  _switch(String value) {
    setState(() {
      if (_categoriesSort.contains(value)) {
        _categoriesSort.remove(value);
      } else {
        _categoriesSort.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //
    late double blockSize;
    late double imageSize;
    late double imageRs;
    if (categoriesColumnCount == 0) {
      var size = MediaQuery.of(context).size;
      var min = size.width < size.height ? size.width : size.height;
      blockSize = (min ~/ 3).floorToDouble();
    } else {
      var size = MediaQuery.of(context).size;
      var min = size.width;
      blockSize = (min ~/ categoriesColumnCount).floorToDouble();
    }
    imageSize = blockSize - 15;
    imageRs = imageSize / 10;
    List<CategoriesItem> items = [];
    //
    items.addAll(_buildChannels(imageSize));
    items.addAll(_buildCategories(widget.requireData, imageSize));
    var names = items.map((e) => e.title).toList();
    var sort = getCategoriesSort();
    items.sort((a, b) {
      var aIndex = sort.indexOf(a.title);
      var bIndex = sort.indexOf(b.title);
      if (aIndex == bIndex) {
        aIndex = names.indexOf(a.title);
        bIndex = names.indexOf(b.title);
      }
      if (aIndex == -1) {
        return 1;
      } else if (bIndex == -1) {
        return -1;
      } else {
        return aIndex - bIndex;
      }
    });
    List<Widget> wrapItems = _wrapItems(items, blockSize, imageRs, imageSize);
    //
    return Scaffold(
      appBar: AppBar(
        title: const Text('分类排序'),
        actions: [
          _saveIcon(),
        ],
      ),
      body: PikaListView(
        children: [
          Container(height: 20),
          Wrap(
            runSpacing: 20,
            alignment: WrapAlignment.spaceAround,
            children: wrapItems,
          ),
          Container(height: 20),
        ],
      ),
    );
  }

  List<Widget> _wrapItems(
    List<CategoriesItem> items,
    double blockSize,
    double imageRs,
    double imageSize,
  ) {
    List<Widget> list = [];

    append(Widget widget, String title, Function() onTap) {
      list.add(
        GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: blockSize,
            child: Column(
              children: [
                Stack(
                  children: [
                    Card(
                      elevation: .5,
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.all(Radius.circular(imageRs)),
                        child: widget,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(imageRs)),
                      ),
                    ),
                    if (!_categoriesSort.contains(title))
                      Container(
                        width: imageSize,
                        height: imageSize,
                        color: Colors.black.withOpacity(.6),
                        margin: const EdgeInsets.all(4.0),
                      ),
                    if (_categoriesSort.contains(title))
                      Container(
                        width: imageSize,
                        height: imageSize,
                        color: Colors.black.withOpacity(.2),
                        margin: const EdgeInsets.all(4.0),
                      ),
                    if (_categoriesSort.contains(title))
                      Container(
                        color: Colors.black.withOpacity(.2),
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "${_categoriesSort.indexOf(title) + 1}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                Container(height: 5),
                Center(
                  child: Text(title),
                ),
              ],
            ),
          ),
        ),
      );
    }

    for (var value in items) {
      append(value.icon, value.title, value.onTap);
    }

    return list;
  }

  List<CategoriesItem> _buildCategories(
    List<Category> cList,
    double imageSize,
  ) {
    List<CategoriesItem> items = [];

    items.add(CategoriesItem(
      buildSvg('lib/assets/books.svg', imageSize, imageSize, margin: 20),
      "全分类",
      () => _switch("全分类"),
    ));

    items.add(CategoriesItem(
      Icon(
        Icons.recommend_outlined,
        size: imageSize,
        color: Colors.grey,
      ),
      "推荐",
      () => _switch("推荐"),
    ));

    for (var i = 0; i < cList.length; i++) {
      var c = cList[i];
      if (c.isWeb) continue;
      items.add(CategoriesItem(
        RemoteImage(
          fileServer: c.thumb.fileServer,
          path: c.thumb.path,
          width: imageSize,
          height: imageSize,
        ),
        c.title,
        () => _switch(c.title),
      ));
    }

    return items;
  }

  List<CategoriesItem> _buildChannels(double imageSize) {
    List<CategoriesItem> items = [];

    items.add(CategoriesItem(
      buildSvg('lib/assets/rankings.svg', imageSize, imageSize,
          margin: 20, color: Colors.red.shade700),
      "排行榜",
      () => _switch("排行榜"),
    ));

    items.add(CategoriesItem(
      buildSvg('lib/assets/random.svg', imageSize, imageSize,
          margin: 20, color: Colors.orangeAccent.shade700),
      "随机本子",
      () => _switch("随机本子"),
    ));

    items.add(CategoriesItem(
      buildSvg('lib/assets/gamepad.svg', imageSize, imageSize,
          margin: 20, color: Colors.blue.shade500),
      "游戏专区",
      () => _switch("游戏专区"),
    ));

    return items;
  }

  Widget _saveIcon() {
    return IconButton(
      onPressed: () async {
        await saveCategoriesSort(_categoriesSort);
        Navigator.of(context).pop();
      },
      icon: const Icon(Icons.save),
    );
  }
}
