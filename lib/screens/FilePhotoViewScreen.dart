import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Cross.dart';
import 'package:pikapika/screens/components/Images.dart';

import 'components/RightClickPop.dart';

// 预览图片
class FilePhotoViewScreen extends StatelessWidget {
  final String filePath;

  const FilePhotoViewScreen(this.filePath, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return rightClickPop(
      child: buildScreen(context),
      context: context,
      canPop: true,
    );
  }

  Widget buildScreen(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            GestureDetector(
              onLongPress: () async {
                String? choose = await chooseListDialog(
                    context, tr('app.please_select'), [tr('app.save_image')]);
                if (choose == null) {
                  return;
                }
                if (choose == tr('app.save_image')) {
                  saveImage(filePath, context);
                }
              },
              child: PhotoView(
                imageProvider: ResourceFileImageProvider(filePath),
              ),
            ),
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.only(top: 30),
                padding: const EdgeInsets.only(left: 4, right: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.75),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child:
                    const Icon(Icons.keyboard_backspace, color: Colors.white),
              ),
            ),
          ],
        ),
      );
}
