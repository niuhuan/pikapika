import 'package:flutter/material.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/components/ComicList.dart';
import 'package:pikapika/screens/components/CommonData.dart';
import 'package:pikapika/screens/components/ContentBuilder.dart';

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
    _sync();
  }

  void _sync() async {
    await method.updateSubscribed();
    final _allSubscribed = await method.allSubscribed();
    allSubscribed.clear();
    for (var subscribed in _allSubscribed) {
      allSubscribed[subscribed.id] = subscribed;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ComicSubscribesScreen(),
          ),
        );
      },
      icon: const Icon(Icons.alarm),
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
