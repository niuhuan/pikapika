import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Navigator.dart';
import 'package:pikapika/basic/Method.dart';
import 'ComicInfoScreen.dart';
import 'DownloadExportToFileScreen.dart';
import 'DownloadReaderScreen.dart';
import 'components/ComicDescriptionCard.dart';
import 'components/ComicTagsCard.dart';
import 'components/ContentError.dart';
import 'components/ContentLoading.dart';
import 'components/ContinueReadButton.dart';
import 'components/DownloadInfoCard.dart';

// 下载详情
class DownloadInfoScreen extends StatefulWidget {
  final String comicId;
  final String comicTitle;

  DownloadInfoScreen({
    required this.comicId,
    required this.comicTitle,
  });

  @override
  State<StatefulWidget> createState() => _DownloadInfoScreenState();
}

class _DownloadInfoScreenState extends State<DownloadInfoScreen>
    with RouteAware {
  late Future<ViewLog?> _viewFuture = _loadViewLog();
  late DownloadComic _task;
  late List<DownloadEp> _epList = [];
  late Future _future = _load();

  Future _load() async {
    _task = (await method.loadDownloadComic(widget.comicId))!;
    _epList = await method.downloadEpList(widget.comicId);
  }

  Future<ViewLog?> _loadViewLog() {
    return method.loadView(widget.comicId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    setState(() {
      _viewFuture = _loadViewLog();
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.comicTitle),
        actions: [
          IconButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DownloadExportToFileScreen(
                    comicId: widget.comicId,
                    comicTitle: widget.comicTitle,
                  ),
                ),
              );
            },
            icon: Icon(Icons.add_to_home_screen),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ComicInfoScreen(
                    comicId: widget.comicId,
                  ),
                ),
              );
            },
            icon: Icon(Icons.settings_ethernet_outlined),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return ContentError(
                error: snapshot.error,
                stackTrace: snapshot.stackTrace,
                onRefresh: () async {
                  setState(() {
                    _future = _load();
                  });
                });
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return ContentLoading(label: '加载中');
          }
          List<dynamic> tagsDynamic = json.decode(_task.tags);
          List<String> tags = tagsDynamic.map((e) => "$e").toList();
          return ListView(
            children: [
              DownloadInfoCard(task: _task, linkItem: true),
              ComicTagsCard(tags),
              ComicDescriptionCard(description: _task.description),
              Container(height: 5),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.spaceAround,
                children: [
                  ContinueReadButton(
                    viewFuture: _viewFuture,
                    onChoose: (int? epOrder, int? pictureRank) {
                      if (epOrder != null && pictureRank != null) {
                        for (var i in _epList) {
                          if (i.epOrder == epOrder) {
                            _push(_task, _epList, epOrder, pictureRank);
                            return;
                          }
                        }
                      } else {
                        _push(_task, _epList, _epList.first.epOrder, null);
                      }
                    },
                  ),
                  ..._epList.map((e) {
                    return Container(
                      child: MaterialButton(
                        onPressed: () {
                          _push(_task, _epList, e.epOrder, null);
                        },
                        color: Colors.white,
                        child: Text(e.title,
                            style: TextStyle(color: Colors.black)),
                      ),
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _push(
    DownloadComic task,
    List<DownloadEp> epList,
    int epOrder,
    int? rank,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DownloadReaderScreen(
          comicInfo: _task,
          epList: _epList,
          currentEpOrder: epOrder,
          initPicturePosition: rank,
        ),
      ),
    );
  }
}
