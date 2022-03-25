import 'package:flutter/material.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/basic/config/ListLayout.dart';
import 'package:pikapika/basic/config/ShadowCategories.dart';

import 'components/ComicListBuilder.dart';
import 'components/RightClickPop.dart';

// 排行榜
class RankingsScreen extends StatelessWidget {
  const RankingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return rightClickPop(
      child: buildScreen(context),
      context: context,
      canPop: true,
    );
  }

  Widget buildScreen(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('排行榜'),
        actions: [
          shadowCategoriesActionButton(context),
          chooseLayoutActionButton(context),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              height: 40,
              color: theme.colorScheme.secondary.withOpacity(.025),
              child: TabBar(
                indicatorColor: theme.colorScheme.secondary,
                labelColor: theme.colorScheme.secondary,
                tabs: const [
                  Tab(text: '天'),
                  Tab(text: '周'),
                  Tab(text: '月'),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _Leaderboard("H24"),
                  _Leaderboard("D7"),
                  _Leaderboard("D30"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Leaderboard extends StatefulWidget {
  final String type;

  const _Leaderboard(this.type);

  @override
  State<StatefulWidget> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<_Leaderboard> {
  late Future<List<ComicSimple>> _future = method.leaderboard(widget.type);

  Future<void> _reload() async {
    setState(() {
      _future = method.leaderboard(widget.type);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ComicListBuilder(_future, _reload);
  }
}
