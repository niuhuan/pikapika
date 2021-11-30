import 'dart:async';
import 'dart:io';

import 'package:another_xlider/another_xlider.dart';
import 'package:event/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Cross.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/basic/config/FullScreenAction.dart';
import 'package:pikapika/basic/config/KeyboardController.dart';
import 'package:pikapika/basic/config/NoAnimation.dart';
import 'package:pikapika/basic/config/ReaderDirection.dart';
import 'package:pikapika/basic/config/ReaderType.dart';
import 'package:pikapika/basic/const.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../FilePhotoViewScreen.dart';
import 'gesture_zoom_box.dart';

import 'Images.dart';

///////////////

Event<_ReaderControllerEventArgs> _readerControllerEvent =
    Event<_ReaderControllerEventArgs>();

class _ReaderControllerEventArgs extends EventArgs {
  final String key;

  _ReaderControllerEventArgs(this.key);
}

Widget readerKeyboardHolder(Widget widget) {
  if (keyboardController &&
      (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    widget = RawKeyboardListener(
      focusNode: FocusNode(),
      child: widget,
      autofocus: true,
      onKey: (event) {
        if (event is RawKeyDownEvent) {
          if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
            _readerControllerEvent.broadcast(_ReaderControllerEventArgs("UP"));
          }
          if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
            _readerControllerEvent
                .broadcast(_ReaderControllerEventArgs("DOWN"));
          }
        }
      },
    );
  }
  return widget;
}

void _onVolumeEvent(dynamic args) {
  _readerControllerEvent.broadcast(_ReaderControllerEventArgs("$args"));
}

var _volumeListenCount = 0;

// 仅支持安卓
// 监听后会拦截安卓手机音量键
// 仅最后一次监听生效
// event可能为DOWN/UP
EventChannel volumeButtonChannel = EventChannel("volume_button");
StreamSubscription? volumeS;

void addVolumeListen() {
  _volumeListenCount++;
  if (_volumeListenCount == 1) {
    volumeS =
        volumeButtonChannel.receiveBroadcastStream().listen(_onVolumeEvent);
  }
}

void delVolumeListen() {
  _volumeListenCount--;
  if (_volumeListenCount == 0) {
    volumeS?.cancel();
  }
}

///////////////////////////////////////////////////////////////////////////////

// 对Reader的传参以及封装

class ReaderImageInfo {
  final String fileServer;
  final String path;
  final String? downloadLocalPath;
  final int? width;
  final int? height;
  final String? format;
  final int? fileSize;

  ReaderImageInfo(this.fileServer, this.path, this.downloadLocalPath,
      this.width, this.height, this.format, this.fileSize);
}

class ImageReaderStruct {
  final List<ReaderImageInfo> images;
  final bool fullScreen;
  final FutureOr<dynamic> Function(bool fullScreen) onFullScreenChange;
  final String onNextText;
  final FutureOr<dynamic> Function() onPreviousAction;
  final FutureOr<dynamic> Function() onNextAction;
  final FutureOr<dynamic> Function(int) onPositionChange;
  final int? initPosition;
  final ReaderType pagerType;
  final ReaderDirection pagerDirection;

  const ImageReaderStruct({
    required this.images,
    required this.fullScreen,
    required this.onFullScreenChange,
    required this.onNextText,
    required this.onPreviousAction,
    required this.onNextAction,
    required this.onPositionChange,
    this.initPosition,
    required this.pagerType,
    required this.pagerDirection,
  });
}

//

class ImageReader extends StatefulWidget {
  final ImageReaderStruct struct;

  const ImageReader(this.struct);

  @override
  State<StatefulWidget> createState() {
    switch (struct.pagerType) {
      case ReaderType.WEB_TOON:
        return _WebToonReaderState();
      case ReaderType.WEB_TOON_ZOOM:
        return _WebToonZoomReaderState();
      case ReaderType.GALLERY:
        return _GalleryReaderState();
      default:
        throw Exception("ERROR READER TYPE");
    }
  }
}

abstract class _ImageReaderState extends State<ImageReader> {
  // 阅读器
  Widget _buildViewer();

  // 键盘, 音量键 等事件
  void _needJumpTo(int index, bool animation);

  @override
  void initState() {
    _initCurrent();
    _readerControllerEvent.subscribe(_onPageControl);
    super.initState();
  }

  @override
  void dispose() {
    _readerControllerEvent.unsubscribe(_onPageControl);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildViewer(),
        _buildControllerAndBar(),
      ],
    );
  }

  void _onPageControl(_ReaderControllerEventArgs? args) {
    if (args != null) {
      var event = args.key;
      switch ("$event") {
        case "UP":
          if (_current > 0) {
            _needJumpTo(_current - 1, true);
          }
          break;
        case "DOWN":
          if (_current < widget.struct.images.length - 1) {
            _needJumpTo(_current + 1, true);
          }
          break;
      }
    }
  }

  late int _startIndex;
  late int _current;
  late int _slider;

  void _initCurrent() {
    if (widget.struct.initPosition != null &&
        widget.struct.images.length > widget.struct.initPosition!) {
      _startIndex = widget.struct.initPosition!;
    } else {
      _startIndex = 0;
    }
    _current = _startIndex;
    _slider = _startIndex;
  }

  void _onCurrentChange(int index) {
    if (index != _current) {
      setState(() {
        _current = index;
        _slider = index;
        widget.struct.onPositionChange(index);
      });
    }
  }

  Widget _buildControllerAndBar() {
    if (widget.struct.fullScreen) {
      return _buildController();
    }
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: _buildController(hiddenFullScreen: true),
          ),
          Container(
            color: readerAppbarColor2,
            child: Row(
              children: [
                Container(width: 15),
                IconButton(
                  icon: Icon(Icons.fullscreen),
                  color: Colors.white,
                  onPressed: () {
                    widget.struct.onFullScreenChange(!widget.struct.fullScreen);
                  },
                ),
                Container(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      Container(height: 3),
                      Container(
                        height: 25,
                        child: FlutterSlider(
                          axis: Axis.horizontal,
                          values: [_slider.toDouble()],
                          min: 0,
                          max: widget.struct.images.length.toDouble(),
                          onDragging: (handlerIndex, lowerValue, upperValue) {
                            _slider = (lowerValue.toInt());
                          },
                          onDragCompleted:
                              (handlerIndex, lowerValue, upperValue) {
                            _slider = (lowerValue.toInt());
                            if (_slider != _current) {
                              _needJumpTo(_slider, false);
                            }
                          },
                          trackBar: FlutterSliderTrackBar(
                            inactiveTrackBar: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey.shade300,
                            ),
                            activeTrackBar: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          step: FlutterSliderStep(
                            step: 1,
                            isPercentRange: false,
                          ),
                          tooltip: FlutterSliderTooltip(custom: (value) {
                            double a = value + 1;
                            return Container(
                              padding: EdgeInsets.all(8),
                              decoration: ShapeDecoration(
                                color: Colors.black.withAlpha(0xCC),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadiusDirectional.circular(3)),
                              ),
                              child: Text(
                                '${a.toInt()}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Container(height: 3),
                    ],
                  ),
                ),
                Container(width: 10),
                IconButton(
                  icon: Icon(Icons.skip_next_outlined),
                  color: Colors.white,
                  onPressed: () {
                    widget.struct.onNextAction();
                  },
                ),
                Container(width: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildController({bool hiddenFullScreen = false}) {
    switch (currentFullScreenAction()) {
      case FullScreenAction.CONTROLLER:
        if (hiddenFullScreen) {
          return Container();
        }
        return _buildFullScreenController();
      case FullScreenAction.TOUCH_ONCE:
        return _buildTouchOnceController();
      case FullScreenAction.THREE_AREA:
        return _buildThreeAreaController();
      default:
        return Container();
    }
  }

  Widget _buildFullScreenController() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Material(
        color: Color(0x0),
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            color: Color(0x88000000),
          ),
          child: GestureDetector(
            onTap: () {
              widget.struct.onFullScreenChange(!widget.struct.fullScreen);
            },
            child: Icon(
              widget.struct.fullScreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen_outlined,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTouchOnceController() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        widget.struct.onFullScreenChange(!widget.struct.fullScreen);
      },
      child: Container(),
    );
  }

  Widget _buildThreeAreaController() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var up = Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _readerControllerEvent
                  .broadcast(_ReaderControllerEventArgs("UP"));
            },
            child: Container(),
          ),
        );
        var down = Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _readerControllerEvent
                  .broadcast(_ReaderControllerEventArgs("DOWN"));
            },
            child: Container(),
          ),
        );
        var fullScreen = Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () =>
                widget.struct.onFullScreenChange(!widget.struct.fullScreen),
            child: Container(),
          ),
        );
        late Widget child;
        switch (widget.struct.pagerDirection) {
          case ReaderDirection.TOP_TO_BOTTOM:
            child = Column(children: [
              up,
              fullScreen,
              down,
            ]);
            break;
          case ReaderDirection.LEFT_TO_RIGHT:
            child = Row(children: [
              up,
              fullScreen,
              down,
            ]);
            break;
          case ReaderDirection.RIGHT_TO_LEFT:
            child = Row(children: [
              down,
              fullScreen,
              up,
            ]);
            break;
        }
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: child,
        );
      },
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class _WebToonReaderState extends _ImageReaderState {
  var _controllerTime = DateTime.now().millisecondsSinceEpoch + 400;
  late final List<Size?> _trueSizes = [];
  late final ItemScrollController _itemScrollController;
  late final ItemPositionsListener _itemPositionsListener;

  @override
  void initState() {
    widget.struct.images.forEach((e) {
      if (e.downloadLocalPath != null) {
        _trueSizes.add(Size(e.width!.toDouble(), e.height!.toDouble()));
      } else {
        _trueSizes.add(null);
      }
    });
    _itemScrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _itemPositionsListener.itemPositions.addListener(_onListCurrentChange);
    super.initState();
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onListCurrentChange);
    super.dispose();
  }

  void _onListCurrentChange() {
    var to = _itemPositionsListener.itemPositions.value.first.index;
    // 包含一个下一章, 假设5张图片 0,1,2,3,4 length=5, 下一章=5
    if (to >= 0 && to < widget.struct.images.length) {
      super._onCurrentChange(to);
    }
  }

  @override
  void _needJumpTo(int index, bool animation) {
    if (noAnimation() || animation == false) {
      _itemScrollController.jumpTo(
        index: index,
      );
    } else {
      if (DateTime.now().millisecondsSinceEpoch < _controllerTime) {
        return;
      }
      _controllerTime = DateTime.now().millisecondsSinceEpoch + 400;
      _itemScrollController.scrollTo(
        index: index, // 减1 当前position 再减少1 前一个
        duration: Duration(milliseconds: 400),
      );
    }
  }

  @override
  Widget _buildViewer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      child: _buildList(),
    );
  }

  Widget _buildList() {
    var scaffold = Scaffold.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // reload _images size
        List<Widget> _images = [];
        for (var index = 0; index < widget.struct.images.length; index++) {
          late Size renderSize;
          if (_trueSizes[index] != null) {
            if (widget.struct.pagerDirection == ReaderDirection.TOP_TO_BOTTOM) {
              renderSize = Size(
                constraints.maxWidth,
                constraints.maxWidth *
                    _trueSizes[index]!.height /
                    _trueSizes[index]!.width,
              );
            } else {
              renderSize = Size(
                constraints.maxHeight *
                    _trueSizes[index]!.width /
                    _trueSizes[index]!.height,
                constraints.maxHeight,
              );
            }
          } else {
            if (widget.struct.pagerDirection == ReaderDirection.TOP_TO_BOTTOM) {
              renderSize = Size(constraints.maxWidth, constraints.maxWidth / 2);
            } else {
              // ReaderDirection.LEFT_TO_RIGHT
              // ReaderDirection.RIGHT_TO_LEFT
              renderSize =
                  Size(constraints.maxWidth / 2, constraints.maxHeight);
            }
          }
          var currentIndex = index;
          var onTrueSize = (Size size) {
            setState(() {
              _trueSizes[currentIndex] = size;
            });
          };
          var e = widget.struct.images[index];
          if (e.downloadLocalPath != null) {
            _images.add(_WebToonDownloadImage(
              fileServer: e.fileServer,
              path: e.path,
              localPath: e.downloadLocalPath!,
              fileSize: e.fileSize!,
              width: e.width!,
              height: e.height!,
              format: e.format!,
              size: renderSize,
              onTrueSize: onTrueSize,
            ));
          } else {
            _images.add(_WebToonRemoteImage(
              e.fileServer,
              e.path,
              renderSize,
              onTrueSize,
            ));
          }
        }
        return ScrollablePositionedList.builder(
          initialScrollIndex: super._startIndex,
          scrollDirection:
              widget.struct.pagerDirection == ReaderDirection.TOP_TO_BOTTOM
                  ? Axis.vertical
                  : Axis.horizontal,
          reverse:
              widget.struct.pagerDirection == ReaderDirection.RIGHT_TO_LEFT,
          padding: EdgeInsets.only(
            top: widget.struct.fullScreen ? (scaffold.appBarMaxHeight ?? 0) : 0,
            bottom:
                widget.struct.pagerDirection == ReaderDirection.TOP_TO_BOTTOM
                    ? 130
                    : (widget.struct.fullScreen
                        ? (scaffold.appBarMaxHeight ?? 0)
                        : 0),
          ),
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          itemCount: widget.struct.images.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (widget.struct.images.length == index) {
              return _buildNextEp();
            }
            return _images[index];
          },
        );
      },
    );
  }

  Widget _buildNextEp() {
    return Container(
      padding: EdgeInsets.all(20),
      child: MaterialButton(
        onPressed: widget.struct.onNextAction,
        textColor: Colors.white,
        child: Container(
          padding: EdgeInsets.only(top: 40, bottom: 40),
          child: Text(widget.struct.onNextText),
        ),
      ),
    );
  }
}

// 来自下载
class _WebToonDownloadImage extends _WebToonReaderImage {
  final String fileServer;
  final String path;
  final String localPath;
  final int fileSize;
  final int width;
  final int height;
  final String format;

  _WebToonDownloadImage({
    required this.fileServer,
    required this.path,
    required this.localPath,
    required this.fileSize,
    required this.width,
    required this.height,
    required this.format,
    required Size size,
    Function(Size)? onTrueSize,
  }) : super(size, onTrueSize);

  @override
  Future<RemoteImageData> imageData() async {
    if (localPath == "") {
      return method.remoteImageData(fileServer, path);
    }
    var finalPath = await method.downloadImagePath(localPath);
    return RemoteImageData.forData(
      fileSize,
      format,
      width,
      height,
      finalPath,
    );
  }
}

// 来自远端
class _WebToonRemoteImage extends _WebToonReaderImage {
  final String fileServer;
  final String path;

  _WebToonRemoteImage(
    this.fileServer,
    this.path,
    Size size,
    Function(Size)? onTrueSize,
  ) : super(size, onTrueSize);

  @override
  Future<RemoteImageData> imageData() async {
    return method.remoteImageData(fileServer, path);
  }
}

// 通用
abstract class _WebToonReaderImage extends StatefulWidget {
  final Size size;
  final Function(Size)? onTrueSize;

  _WebToonReaderImage(this.size, this.onTrueSize);

  @override
  State<StatefulWidget> createState() => _WebToonReaderImageState();

  Future<RemoteImageData> imageData();
}

class _WebToonReaderImageState extends State<_WebToonReaderImage> {
  late Future<RemoteImageData> _future = _load();

  Future<RemoteImageData> _load() {
    return widget.imageData().then((value) {
      widget.onTrueSize?.call(
        Size(value.width.toDouble(), value.height.toDouble()),
      );
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return FutureBuilder(
          future: _future,
          builder: (
            BuildContext context,
            AsyncSnapshot<RemoteImageData> snapshot,
          ) {
            if (snapshot.hasError) {
              return GestureDetector(
                onLongPress: () async {
                  String? choose =
                      await chooseListDialog(context, '请选择', ['重新加载图片']);
                  switch (choose) {
                    case '重新加载图片':
                      setState(() {
                        _future = _load();
                      });
                      break;
                  }
                },
                child: buildError(widget.size.width, widget.size.height),
              );
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return buildLoading(widget.size.width, widget.size.height);
            }
            var data = snapshot.data!;
            return buildFile(
              data.finalPath,
              widget.size.width,
              widget.size.height,
              context: context,
            );
          },
        );
      },
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class _WebToonZoomReaderState extends _WebToonReaderState {
  @override
  Widget _buildList() {
    return GestureZoomBox(child: super._buildList());
  }
}

///////////////////////////////////////////////////////////////////////////////

class _GalleryReaderState extends _ImageReaderState {
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: super._startIndex);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void _needJumpTo(int index, bool animation) {
    if (noAnimation() || animation == false) {
      _pageController.jumpToPage(
        index,
      );
    } else {
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 400),
        curve: Curves.ease,
      );
    }
  }

  void _onGalleryPageChange(int to) {
    // 包含一个下一章, 假设5张图片 0,1,2,3,4 length=5, 下一章=5
    if (to >= 0 && to < widget.struct.images.length) {
      super._onCurrentChange(to);
    }
  }

  Widget _buildViewer() {
    var gallery = PhotoViewGallery.builder(
      scrollDirection:
          widget.struct.pagerDirection == ReaderDirection.TOP_TO_BOTTOM
              ? Axis.vertical
              : Axis.horizontal,
      reverse: widget.struct.pagerDirection == ReaderDirection.RIGHT_TO_LEFT,
      backgroundDecoration: BoxDecoration(color: Colors.black),
      loadingBuilder: (context, event) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return buildLoading(constraints.maxWidth, constraints.maxHeight);
        },
      ),
      pageController: _pageController,
      onPageChanged: _onGalleryPageChange,
      itemCount: widget.struct.images.length,
      builder: (BuildContext context, int index) {
        var item = widget.struct.images[index];
        if (item.downloadLocalPath != null) {
          return PhotoViewGalleryPageOptions(
            imageProvider:
                ResourceDownloadFileImageProvider(item.downloadLocalPath!),
            errorBuilder: (b, e, s) {
              print("$e,$s");
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return buildError(
                      constraints.maxWidth, constraints.maxHeight);
                },
              );
            },
          );
        }
        return PhotoViewGalleryPageOptions(
          imageProvider:
              ResourceRemoteImageProvider(item.fileServer, item.path),
          errorBuilder: (b, e, s) {
            print("$e,$s");
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return buildError(constraints.maxWidth, constraints.maxHeight);
              },
            );
          },
        );
      },
    );
    return GestureDetector(
      child: gallery,
      onLongPress: () async {
        if (_current >= 0 && _current < widget.struct.images.length) {
          Future<String> Function() load = () async {
            var item = widget.struct.images[_current];
            if (item.downloadLocalPath != null) {
              return method.downloadImagePath(item.downloadLocalPath!);
            }
            var data = await method.remoteImageData(item.fileServer, item.path);
            return data.finalPath;
          };
          String? choose =
              await chooseListDialog(context, '请选择', ['预览图片', '保存图片']);
          switch (choose) {
            case '预览图片':
              try {
                var file = await load();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => FilePhotoViewScreen(file),
                ));
              } catch (e) {
                defaultToast(context, "图片加载失败");
              }
              break;
            case '保存图片':
              try {
                var file = await load();
                saveImage(file, context);
              } catch (e) {
                defaultToast(context, "图片加载失败");
              }
              break;
          }
        }
      },
    );
  }

  Widget _buildNextEpButton() {
    return Container();
  }
}

///////////////////////////////////////////////////////////////////////////////
