import 'package:flutter/material.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/components/ComicList.dart';
import 'package:pikapika/screens/components/ContentBuilder.dart';
import 'package:pikapika/screens/components/ContentMessage.dart';

import 'components/RightClickPop.dart';

class ComicCollectionsScreen extends StatefulWidget {
  const ComicCollectionsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicCollectionsScreenState();
}

class _ComicCollectionsScreenState extends State<ComicCollectionsScreen> {
  late Future<List<Collection>> _future;

  @override
  void initState() {
    _future = method.collections();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
      appBar: AppBar(title: const Text("推荐")),
      body: ContentBuilder(
        future: _future,
        onRefresh: () async {
          setState(() {
            _future = method.collections();
          });
        },
        successBuilder: (
          BuildContext context,
          AsyncSnapshot<List<Collection>> snapshot,
        ) {
          final collection = snapshot.requireData;
          if (collection.isEmpty) {
            return ContentMessage(
              message: "这里没有资源呀",
              icon: Icons.no_sim_outlined,
              onRefresh: () async {
                setState(() {
                  _future = method.collections();
                });
              },
            );
          }
          final ThemeData theme = Theme.of(context);
          final AppBarTheme appBarTheme = AppBarTheme.of(context);
          return DefaultTabController(
            length: collection.length,
            child: Scaffold(
              appBar: PreferredSizeContainer(
                color: appBarTheme.backgroundColor,
                child: TabBar(
                  indicatorColor: theme.dividerColor,
                  tabs: collection
                      .map((e) => Tab(
                          text: e.title.indexOf("推薦") > 0
                              ? e.title.substring(0, e.title.indexOf("推薦"))
                              : e.title))
                      .toList(),
                ),
              ),
              body: TabBarView(
                children: collection.map((e) => ComicList(e.comics)).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PreferredSizeContainer extends StatelessWidget
    implements PreferredSizeWidget {
  final PreferredSizeWidget child;
  final Color? color;

  const PreferredSizeContainer({
    required this.child,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: child,
    );
  }
}
