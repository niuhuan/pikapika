import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pikapi/basic/Cross.dart';
import 'package:pikapi/screens/components/Images.dart';

class FilePhotoViewScreen extends StatelessWidget {
  final String filePath;

  FilePhotoViewScreen(this.filePath);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            PhotoView(
              imageProvider: PicaFileImageProvider(filePath),
            ),
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: EdgeInsets.only(top: 30),
                padding: EdgeInsets.only(left: 4, right: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.75),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Icon(Icons.keyboard_backspace, color: Colors.white),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  saveImage(filePath, context);
                },
                child: Container(
                  margin: EdgeInsets.only(top: 30),
                  padding: EdgeInsets.only(left: 4, right: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.75),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Icon(Icons.save, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
}
