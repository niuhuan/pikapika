import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/config/AutoFullScreen.dart';
import 'package:pikapika/basic/config/FullScreenUI.dart';
import 'package:pikapika/basic/config/ReaderDirection.dart';
import 'package:pikapika/basic/config/ReaderType.dart';
import 'package:pikapika/screens/components/ContentBuilder.dart';
import 'package:pikapika/basic/Method.dart';
import 'components/ContentError.dart';
import 'components/ContentLoading.dart';
import 'components/ImageReader.dart';

// 阅读下载的内容
class DownloadReaderScreen extends StatefulWidget {
  final DownloadComic comicInfo;
  final List<DownloadEp> epList;
  final int currentEpOrder;
  final int? initPicturePosition;
  final ReaderType pagerType = currentReaderType();
  final ReaderDirection pagerDirection = gReaderDirection;
  late final bool autoFullScreen;

  DownloadReaderScreen({
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
  State<StatefulWidget> createState() => _DownloadReaderScreenState();
}

class _DownloadReaderScreenState extends State<DownloadReaderScreen> {
  late DownloadEp _ep;
  late bool _fullScreen = false;
  late List<DownloadPicture> pictures = [];
  late Future _future = _load();
  int? _lastChangeRank;
  bool _replacement = false;

  Future _load() async {
    if (widget.initPicturePosition == null) {
      await method.storeViewEp(widget.comicInfo.id, _ep.epOrder, _ep.title, 0);
    }
    pictures.clear();
    for (var ep in widget.epList) {
      if (ep.epOrder == widget.currentEpOrder) {
        pictures.addAll((await method.downloadPicturesByEpId(ep.id)));
      }
    }
    if (widget.autoFullScreen) {
      setState(() {
        SystemChrome.setEnabledSystemUIOverlays([]);
        _fullScreen = true;
      });
    }
  }

  Future _onPositionChange(int position) async {
    _lastChangeRank = position;
    return method.storeViewEp(
        widget.comicInfo.id, _ep.epOrder, _ep.title, position);
  }

  FutureOr<dynamic> Function() _previousAction = () => null;

  String _nextText = "";
  FutureOr<dynamic> Function() _nextAction = () => null;

  @override
  void initState() {
    // NEXT
    var orderMap = Map<int, DownloadEp>();
    widget.epList.forEach((element) {
      orderMap[element.epOrder] = element;
    });
    if (orderMap.containsKey(widget.currentEpOrder - 1)) {
      _previousAction = () {
        _replacement = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DownloadReaderScreen(
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
            builder: (context) => DownloadReaderScreen(
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
      if (element.epOrder == widget.currentEpOrder) {
        _ep = element;
      }
    });
    // INIT
    _future = _load();
    super.initState();
  }

  @override
  void dispose() {
    if (!_replacement) {
      switchFullScreenUI();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return readerKeyboardHolder(_build(context));
  }

  Future _onSelectDirection() async {
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
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: _fullScreen
                ? null
                : AppBar(
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
          epNameMap[element.epOrder] = element.title;
        });
        return Scaffold(
          body: ImageReader(
            ImageReaderStruct(
              images: pictures
                  .map((e) => ReaderImageInfo(e.fileServer, e.path, e.localPath,
                      e.width, e.height, e.format, e.fileSize))
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
              epOrder: _ep.epOrder,
              epNameMap: epNameMap,
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DownloadReaderScreen(
          comicInfo: widget.comicInfo,
          epList: widget.epList,
          currentEpOrder: widget.currentEpOrder,
          initPicturePosition: _lastChangeRank ?? widget.initPicturePosition,
          // maybe null
          autoFullScreen: _fullScreen,
        ),
      ),
    );
  }
}
