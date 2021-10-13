import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pikapi/basic/Method.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';
import 'dart:ui' as ui show Codec;

// 从本地加载图片
class PicaFileImageProvider extends ImageProvider<PicaFileImageProvider> {
  final String path;
  final double scale;

  PicaFileImageProvider(this.path, {this.scale = 1.0});

  @override
  ImageStreamCompleter load(PicaFileImageProvider key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: key.scale,
    );
  }

  @override
  Future<PicaFileImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<PicaFileImageProvider>(this);
  }

  Future<ui.Codec> _loadAsync(PicaFileImageProvider key) async {
    assert(key == this);
    return PaintingBinding.instance!
        .instantiateImageCodec(await File(path).readAsBytes());
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final PicaFileImageProvider typedOther = other;
    return path == typedOther.path && scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(path, scale);

  @override
  String toString() => '$runtimeType('
      'path: ${describeIdentity(path)},'
      ' scale: $scale'
      ')';
}

// 从本地加载图片
class PicaDownloadFileImageProvider
    extends ImageProvider<PicaDownloadFileImageProvider> {
  final String path;
  final double scale;

  PicaDownloadFileImageProvider(this.path, {this.scale = 1.0});

  @override
  ImageStreamCompleter load(
      PicaDownloadFileImageProvider key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: key.scale,
    );
  }

  @override
  Future<PicaDownloadFileImageProvider> obtainKey(
      ImageConfiguration configuration) {
    return SynchronousFuture<PicaDownloadFileImageProvider>(this);
  }

  Future<ui.Codec> _loadAsync(PicaDownloadFileImageProvider key) async {
    assert(key == this);
    return PaintingBinding.instance!.instantiateImageCodec(
        await File(await method.downloadImagePath(path)).readAsBytes());
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final PicaDownloadFileImageProvider typedOther = other;
    return path == typedOther.path && scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(path, scale);

  @override
  String toString() => '$runtimeType('
      'path: ${describeIdentity(path)},'
      ' scale: $scale'
      ')';
}

// 从远端加载图片 暂时未使用 (现在都是先获取路径然后再通过file显示)
class PicaRemoteImageProvider extends ImageProvider<PicaRemoteImageProvider> {
  final String fileServer;
  final String path;
  final double scale;

  PicaRemoteImageProvider(this.fileServer, this.path, {this.scale = 1.0});

  @override
  ImageStreamCompleter load(
      PicaRemoteImageProvider key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: key.scale,
    );
  }

  @override
  Future<PicaRemoteImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<PicaRemoteImageProvider>(this);
  }

  Future<ui.Codec> _loadAsync(PicaRemoteImageProvider key) async {
    assert(key == this);
    var downloadTo = await method.remoteImageData(fileServer, path);
    return PaintingBinding.instance!
        .instantiateImageCodec(await File(downloadTo.finalPath).readAsBytes());
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final PicaRemoteImageProvider typedOther = other;
    return fileServer == typedOther.fileServer &&
        path == typedOther.path &&
        scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(fileServer, path, scale);

  @override
  String toString() => '$runtimeType('
      'fileServer: ${describeIdentity(fileServer)},'
      ' path: ${describeIdentity(path)},'
      ' scale: $scale'
      ')';
}

// 下载的图片
class DownloadImage extends StatefulWidget {
  final String path;
  final double? width;
  final double? height;

  const DownloadImage({
    Key? key,
    required this.path,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DownloadImageState();
}

class _DownloadImageState extends State<DownloadImage> {
  late Future<String> _future = method.downloadImagePath(widget.path);

  @override
  Widget build(BuildContext context) {
    return pathFutureImage(_future, widget.width, widget.height);
  }
}

// 远端图片
class RemoteImage extends StatefulWidget {
  final String fileServer;
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const RemoteImage({
    Key? key,
    required this.fileServer,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RemoteImageState();
}

class _RemoteImageState extends State<RemoteImage> {
  late bool _mock;
  late Future<String> _future;

  @override
  void initState() {
    _mock = widget.fileServer == "" || widget.fileServer.contains(".xyz/");
    if (!_mock) {
      _future = method
          .remoteImageData(widget.fileServer, widget.path)
          .then((value) => value.finalPath);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_mock) {
      return buildMock(widget.width, widget.height);
    }
    return pathFutureImage(_future, widget.width, widget.height,
        fit: widget.fit);
  }
}

// 通用方法

Widget buildSvg(String source, double? width, double? height,
    {Color? color, double? margin}) {
  return Container(
    width: width,
    height: height,
    padding: margin != null ? EdgeInsets.all(10) : null,
    child: Center(
      child: SvgPicture.asset(
        source,
        width: width,
        height: height,
        color: color,
      ),
    ),
  );
}

Widget buildMock(double? width, double? height) {
  return Container(
    width: width,
    height: height,
    padding: EdgeInsets.all(10),
    child: Center(
      child: SvgPicture.asset(
        'lib/assets/unknown.svg',
        width: width,
        height: height,
        color: Colors.grey.shade600,
      ),
    ),
  );
}

Widget buildError(double? width, double? height) {
  return Image(
    image: AssetImage('lib/assets/error.png'),
    width: width,
    height: height,
  );
}

Widget buildLoading(double? width, double? height) {
  double? size;
  if (width != null && height != null) {
    size = width < height ? width : height;
  }
  return Container(
    width: width,
    height: height,
    child: Center(
      child: Icon(
        Icons.downloading,
        size: size,
        color: Colors.black12,
      ),
    ),
  );
}

Widget buildFile(String file, double? width, double? height,
    {BoxFit fit = BoxFit.cover}) {
  return Image(
    image: PicaFileImageProvider(file),
    width: width,
    height: height,
    errorBuilder: (a, b, c) {
      print("$b");
      print("$c");
      return buildError(width, height);
    },
    fit: fit,
  );
}

Widget pathFutureImage(Future<String> future, double? width, double? height,
    {BoxFit fit = BoxFit.cover}) {
  return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasError) {
          print("${snapshot.error}");
          print("${snapshot.stackTrace}");
          return buildError(width, height);
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return buildLoading(width, height);
        }
        return buildFile(snapshot.data!, width, height, fit: fit);
      });
}
