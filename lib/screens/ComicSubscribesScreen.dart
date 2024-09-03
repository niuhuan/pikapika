import 'package:flutter/material.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/components/ComicList.dart';
import 'package:pikapika/screens/components/CommonData.dart';
import 'package:pikapika/screens/components/ContentBuilder.dart';

import '../basic/config/Address.dart';
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
    final count = allSubscribed.values.isEmpty
        ? 0
        : allSubscribed.values
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
  @override
  void initState() {
    super.initState();
    subscribedEvent.subscribe(_setState);
  }

  @override
  void dispose() {
    subscribedEvent.unsubscribe(_setState);
    super.dispose();
  }

  void _setState(_) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('更新提醒'),
        actions: [
          commonPopMenu(context),
          addressPopMenu(context),
          _popMenu(context),
        ],
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final subs = allSubscribed.values.toList();
    List<ComicSimple> comicList = [];
    for (var comicSubscribe in subs) {
      comicList.add(ComicSimple.fromJson(comicSubscribe.toSimpleJson()));
    }
    return ComicList(comicList);
  }
}

Widget _popMenu(BuildContext context) {
  return PopupMenuButton<int>(
    icon: const Icon(Icons.more_vert),
    itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
      const PopupMenuItem<int>(
        value: 0,
        child: ListTile(
          leading: Icon(Icons.share),
          title: Text("检查更新"),
        ),
      ),
      const PopupMenuItem<int>(
        value: 1,
        child: ListTile(
          leading: Icon(Icons.image_search),
          title: Text("取消所有更新提醒"),
        ),
      ),
    ],
    onSelected: (int value) {
      switch (value) {
        case 0:
          updateSubscribedForce();
          break;
        case 1:
          removeAllSubscribed();
          break;
      }
    },
  );
}
