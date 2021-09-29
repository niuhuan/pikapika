import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/config/AutoFullScreen.dart';
import 'package:pikapi/basic/config/FullScreenUI.dart';
import 'package:pikapi/basic/config/ReaderDirection.dart';
import 'package:pikapi/basic/config/ReaderType.dart';
import 'package:pikapi/screens/components/ContentBuilder.dart';
import 'package:pikapi/basic/Method.dart';
import 'components/ImageReader.dart';

// 阅读下载的内容
class DownloadReaderScreen extends StatefulWidget {
  final DownloadComic comicInfo;
  final List<DownloadEp> epList;
  final int currentEpOrder;
  final int? initPictureRank;
  final ReaderType pagerType = gReaderType;
  final ReaderDirection pagerDirection = gReaderDirection;
  late final bool autoFullScreen;

  DownloadReaderScreen({
    Key? key,
    required this.comicInfo,
    required this.epList,
    required this.currentEpOrder,
    this.initPictureRank,
    bool? autoFullScreen,
  }) : super(key: key) {
    this.autoFullScreen = autoFullScreen ?? gAutoFullScreen;
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
    if (widget.initPictureRank == null) {
      await method.storeViewEp(widget.comicInfo.id, _ep.epOrder, _ep.title, 1);
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
    _lastChangeRank = position + 1;
    return method.storeViewEp(
        widget.comicInfo.id, _ep.epOrder, _ep.title, position + 1);
  }

  String _nextText = "";
  FutureOr<dynamic> Function() _nextAction = () => null;

  @override
  void initState() {
    // NEXT
    var orderMap = Map<int, DownloadEp>();
    widget.epList.forEach((element) {
      orderMap[element.epOrder] = element;
    });
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

  Widget _build(BuildContext context) {
    return Scaffold(
      appBar: _fullScreen
          ? null
          : AppBar(
              title: Text("${_ep.title} - ${widget.comicInfo.title}"),
              actions: [
                IconButton(
                  onPressed: () async {
                    await choosePagerDirection(context);
                    if (widget.pagerDirection != gReaderDirection) {
                      _reloadReader();
                    }
                  },
                  icon: Icon(Icons.grid_goldenratio),
                ),
                IconButton(
                  onPressed: () async {
                    await choosePagerType(context);
                    if (widget.pagerType != gReaderType) {
                      _reloadReader();
                    }
                  },
                  icon: Icon(Icons.view_day_outlined),
                ),
              ],
            ),
      body: ContentBuilder(
        future: _future,
        onRefresh: () async {
          setState(() {
            _future = _load();
          });
        },
        successBuilder:
            (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          return ImageReader(
            ImageReaderStruct(
              images: pictures
                  .map((e) => ReaderImageInfo(e.fileServer, e.path, e.localPath,
                      e.width, e.height, e.format, e.fileSize))
                  .toList(),
              fullScreen: _fullScreen,
              onFullScreenChange: _onFullScreenChange,
              onNextText: _nextText,
              onNextAction: _nextAction,
              onPositionChange: _onPositionChange,
              initPosition: widget.initPictureRank == null
                  ? null
                  : widget.initPictureRank! - 1,
              pagerType: widget.pagerType,
              pagerDirection: widget.pagerDirection,
            ),
          );
        },
      ),
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
          initPictureRank: _lastChangeRank ?? widget.initPictureRank,
          // maybe null
          autoFullScreen: _fullScreen,
        ),
      ),
    );
  }
}
