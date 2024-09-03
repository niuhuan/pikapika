import 'package:flutter/material.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/components/ComicList.dart';
import 'package:pikapika/screens/components/CommonData.dart';
import 'package:pikapika/screens/components/ContentBuilder.dart';

import 'components/Badge.dart';
import 'components/Common.dart';

class IntoComicSubscribesScreenButton extends StatefulWidget {
  const IntoComicSubscribesScreenButton({Key? key}) : super(key: key);

  @override
  State<IntoComicSubscribesScreenButton> createState() =>
      _IntoComicSubscribesScreenButtonState();
}

class _IntoComicSubscribesScreenButtonState
    extends State<IntoComicSubscribesScreenButton> {
  @override
  void initState() {
    super.initState();
    subscribedEvent.subscribe(_setState);
    _sync();
  }

  @override
  void dispose() {
    subscribedEvent.unsubscribe(_setState);
    super.dispose();
  }

  _setState(_) {
    setState(() {});
  }

  void _sync() async {
    await updateSubscribed();
  }

  @override
  Widget build(BuildContext context) {
    final count = allSubscribed.values
        .map((e) => e.newEpCount)
        .reduce((value, element) => value + element);
    return Badged(
      badge: count == 0 ? null : count.toString(),
      child: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ComicSubscribesScreen(),
            ),
          );
        },
        icon: const Icon(Icons.alarm),
      ),
    );
  }
}

class ComicSubscribesScreen extends StatefulWidget {
  const ComicSubscribesScreen({Key? key}) : super(key: key);

  @override
  State<ComicSubscribesScreen> createState() => _ComicSubscribesScreenState();
}

class _ComicSubscribesScreenState extends State<ComicSubscribesScreen> {
  Future<List<ComicSubscribe>> _future = method.allSubscribed();
  Key _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订阅'),
        actions: [
          commonPopMenu(context),
        ],
      ),
      body: ContentBuilder(
        future: _future,
        key: _key,
        onRefresh: () async {
          setState(() {
            _future = method.allSubscribed();
            _key = UniqueKey();
          });
        },
        successBuilder: (BuildContext context,
            AsyncSnapshot<List<ComicSubscribe>> snapshot) {
          List<ComicSimple> comicList = [];
          for (var comicSubscribe in snapshot.requireData) {
            comicList.add(ComicSimple.fromJson(comicSubscribe.toSimpleJson()));
          }
          return ComicList(comicList);
        },
      ),
    );
  }
}
