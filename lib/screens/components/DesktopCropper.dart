import 'dart:io';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:image/image.dart' as image;
import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';

class DesktopCropper extends StatefulWidget {
  final String? title;
  final double? aspectRatio;
  final String file;

  const DesktopCropper({
    Key? key,
    this.title,
    this.aspectRatio,
    required this.file,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DesktopCropperState();
}

class _DesktopCropperState extends State<DesktopCropper> {
  late final _controller = CropController(
    aspectRatio: widget.aspectRatio,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? tr("app.image_crop")),
        actions: [
          IconButton(onPressed: _finish, icon: const Icon(Icons.done)),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: CropImage(
            controller: _controller,
            image: Image.file(File(widget.file)),
          ),
        ),
      ),
    );
  }

  Future _finish() async {
    var cropped = await _controller.croppedBitmap();
    var data = await cropped.toByteData(format: ui.ImageByteFormat.png);
    if (data != null) {
      var u8list = data.buffer.asUint8List();
      image.Image? baseSizeImage = image.decodePng(u8list);
      if (baseSizeImage != null) {
        if (cropped.width > 200) {
          baseSizeImage =
              image.copyResize(baseSizeImage, height: 200, width: 200);
        }
        var f = image.encodeJpg(baseSizeImage);
        Navigator.of(context).pop(f);
      }
    }
  }
}
