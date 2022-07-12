import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/components/ContentBuilder.dart';
import 'package:pikapika/screens/components/PkzComicInfoCard.dart';
import 'package:uni_links/uni_links.dart';
import 'package:uri_to_file/uri_to_file.dart';

import '../basic/Common.dart';
import '../basic/Navigator.dart';
import 'PkzComicInfoScreen.dart';

class PkzArchiveScreen extends StatefulWidget {
  final bool holdPkz;
  final String pkzPath;

  const PkzArchiveScreen({
    Key? key,
    required this.pkzPath,
    this.holdPkz = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PkzArchiveScreenState();
}

class _PkzArchiveScreenState extends State<PkzArchiveScreen> with RouteAware {
  Map<String, PkzComicViewLog> _logMap = {};
  late String _fileName;
  late Future _future;
  late Key _key;
  late PkzArchive _info;
  StreamSubscription<String?>? _linkSubscription;

  @override
  void initState() {
    if (widget.holdPkz) {
      _linkSubscription = linkSubscript(context);
    }
    _fileName = p.basename(widget.pkzPath);
    _future = _load();
    _key = UniqueKey();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    () async {
      var a = await method.pkzComicViewLogs(_fileName, widget.pkzPath);
      for (var value in a) {
        _logMap[value.lastViewComicId] = value;
      }
      setState(() {});
    }();
  }

  Future _load() async {
    await method.viewPkz(_fileName, widget.pkzPath);
    var p = await Permission.storage.request();
    if (!p.isGranted) {
      throw 'error permission';
    }
    _info = await method.pkzInfo(widget.pkzPath);
    if (_info.comics.length == 1) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => PkzComicInfoScreen(
          pkzPath: widget.pkzPath,
          pkzComic: _info.comics.first,
          holdPkz: widget.holdPkz,
        ),
      ));
    }
    var a = await method.pkzComicViewLogs(_fileName, widget.pkzPath);
    for (var value in a) {
      _logMap[value.lastViewComicId] = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_fileName),
      ),
      body: ContentBuilder(
        key: _key,
        future: _future,
        onRefresh: () async {
          setState(() {
            _future = _load();
            _key = UniqueKey();
          });
        },
        successBuilder: (
          BuildContext context,
          AsyncSnapshot snapshot,
        ) {
          return ListView(children: [
            ..._info.comics
                .map((e) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) {
                            return PkzComicInfoScreen(
                              pkzComic: e,
                              pkzPath: widget.pkzPath,
                            );
                          },
                        ));
                      },
                      child: PkzComicInfoCard(
                        info: e,
                        pkzPath: widget.pkzPath,
                        displayViewLog: _logMap[e.id],
                      ),
                    ))
                .toList(),
          ]);
        },
      ),
    );
  }
}
