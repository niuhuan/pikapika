import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/basic/config/AutoFullScreen.dart';
import 'package:pikapika/basic/config/FullScreenUI.dart';
import 'package:pikapika/basic/config/Quality.dart';
import 'package:pikapika/basic/config/ReaderDirection.dart';
import 'package:pikapika/basic/config/ReaderType.dart';
import 'package:pikapika/basic/const.dart';
import 'package:pikapika/screens/components/ContentError.dart';
import 'package:pikapika/screens/components/ContentLoading.dart';
import 'components/ImageReader.dart';

// 在线阅读漫画
class ComicReaderScreen extends StatefulWidget {
  final ComicInfo comicInfo;
  final List<Ep> epList;
  final currentEpOrder;
  final int? initPicturePosition;
  final ReaderType pagerType = currentReaderType();
  final ReaderDirection pagerDirection = gReaderDirection;
  late final bool autoFullScreen;

  ComicReaderScreen({
    Key? key,
    required this.comicInfo,
    required this.epList,
    required this.currentEpOrder,
    this.initPicturePosition,
    bool? autoFullScreen,
  }) : super(key: key) {
    this.autoFullScreen = autoFullScreen ?? currentAutoFullScreen();
  }

  @override
  State<StatefulWidget> createState() => _ComicReaderScreenState();
}

class _ComicReaderScreenState extends State<ComicReaderScreen> {
  late Ep _ep;
  late bool _fullScreen = false;
  late Future<List<RemoteImageInfo>> _future;
  int? _lastChangeRank;
  bool _replacement = false;

  Future<List<RemoteImageInfo>> _load() async {
    if (widget.initPicturePosition == null) {
      await method.storeViewEp(widget.comicInfo.id, _ep.order, _ep.title, 0);
    }
    List<RemoteImageInfo> list = [];
    var _needLoadPage = 0;
    late PicturePage page;
    do {
      page = await method.comicPicturePageWithQuality(
        widget.comicInfo.id,
        widget.currentEpOrder,
        ++_needLoadPage,
        currentQualityCode(),
      );
      list.addAll(page.docs.map((element) => element.media));
    } while (page.pages > page.page);
    if (widget.autoFullScreen) {
      setState(() {
        SystemChrome.setEnabledSystemUIOverlays([]);
        _fullScreen = true;
      });
    }
    return list;
  }

  Future _onPositionChange(int position) async {
    _lastChangeRank = position;
    return method.storeViewEp(
        widget.comicInfo.id, _ep.order, _ep.title, position);
  }

  FutureOr<dynamic> Function() _previousAction = () => null;

  String _nextText = "";
  FutureOr<dynamic> Function() _nextAction = () => null;

  @override
  void initState() {
    // NEXT
    var orderMap = Map<int, Ep>();
    widget.epList.forEach((element) {
      orderMap[element.order] = element;
    });
    if (orderMap.containsKey(widget.currentEpOrder - 1)) {
      _previousAction = () {
        _replacement = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ComicReaderScreen(
              comicInfo: widget.comicInfo,
              epList: widget.epList,
              currentEpOrder: widget.currentEpOrder - 1,
              autoFullScreen: _fullScreen,
            ),
          ),
        );
      };
    } else {
      _previousAction = () => defaultToast(context, "已经到头了");
    }
    if (orderMap.containsKey(widget.currentEpOrder + 1)) {
      _nextText = "下一章";
      _nextAction = () {
        _replacement = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ComicReaderScreen(
              comicInfo: widget.comicInfo,
              epList: widget.epList,
              currentEpOrder: widget.currentEpOrder + 1,
              autoFullScreen: _fullScreen,
            ),
          ),
        );
      };
    } else {
      _nextText = "阅读结束";
      _nextAction = () => Navigator.of(context).pop();
    }
    // EP
    widget.epList.forEach((element) {
      if (element.order == widget.currentEpOrder) {
        _ep = element;
      }
    });
    // INIT
    _future = _load();
    addVolumeListen();
    super.initState();
  }

  @override
  void dispose() {
    if (!_replacement) {
      switchFullScreenUI();
    }
    delVolumeListen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return readerKeyboardHolder(_build(context));
  }

  Future  _onSelectDirection() async {
    await choosePagerDirection(context);
    if (widget.pagerDirection != gReaderDirection) {
      _reloadReader();
    }
  }

  Future _onSelectReaderType() async {
    await choosePagerType(context);
    if (widget.pagerType != currentReaderType()) {
      _reloadReader();
    }
  }

  Widget _build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context,
          AsyncSnapshot<List<RemoteImageInfo>> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: _fullScreen
                ? null
                : AppBar(
                    backgroundColor: readerAppbarColor,
                    title: Text("${_ep.title} - ${widget.comicInfo.title}"),
                    actions: [
                      IconButton(
                        onPressed: _onSelectDirection,
                        icon: Icon(Icons.grid_goldenratio),
                      ),
                      IconButton(
                        onPressed: _onSelectReaderType,
                        icon: Icon(Icons.view_day_outlined),
                      ),
                    ],
                  ),
            body: ContentError(
              error: snapshot.error,
              stackTrace: snapshot.stackTrace,
              onRefresh: () async {
                setState(() {
                  _future = _load();
                });
              },
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: _fullScreen
                ? null
                : AppBar(
                    backgroundColor: readerAppbarColor,
                    title: Text("${_ep.title} - ${widget.comicInfo.title}"),
                    actions: [
                      IconButton(
                        onPressed: _onSelectDirection,
                        icon: Icon(Icons.grid_goldenratio),
                      ),
                      IconButton(
                        onPressed: _onSelectReaderType,
                        icon: Icon(Icons.view_day_outlined),
                      ),
                    ],
                  ),
            body: ContentLoading(label: '加载中'),
          );
        }
        var epNameMap = Map<int, String>();
        widget.epList.forEach((element) {
          epNameMap[element.order] = element.title;
        });
        return Scaffold(
          body:  ImageReader(
            ImageReaderStruct(
              images: snapshot.data!
                  .map((e) => ReaderImageInfo(
                e.fileServer,
                e.path,
                null,
                null,
                null,
                null,
                null,
              ))
                  .toList(),
              fullScreen: _fullScreen,
              onFullScreenChange: _onFullScreenChange,
              onNextText: _nextText,
              onPreviousAction: _previousAction,
              onNextAction: _nextAction,
              onPositionChange: _onPositionChange,
              initPosition: widget.initPicturePosition,
              pagerType: widget.pagerType,
              pagerDirection: widget.pagerDirection,
              epNameMap: epNameMap,
              epOrder: _ep.order,
              comicTitle: widget.comicInfo.title,
              onSelectDirection: _onSelectDirection,
              onSelectReaderType: _onSelectReaderType,
            ),
          ),
        );
      },
    );
  }

  Future _onFullScreenChange(bool fullScreen) async {
    setState(() {
      SystemChrome.setEnabledSystemUIOverlays(
          fullScreen ? [] : SystemUiOverlay.values);
      _fullScreen = fullScreen;
    });
  }

  // 重新加载本页
  void _reloadReader() {
    _replacement = true;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => ComicReaderScreen(
        comicInfo: widget.comicInfo,
        epList: widget.epList,
        currentEpOrder: widget.currentEpOrder,
        initPicturePosition: _lastChangeRank ?? widget.initPicturePosition,
        // maybe null
        autoFullScreen: _fullScreen,
      ),
    ));
  }
}
