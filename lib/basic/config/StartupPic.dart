import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Method.dart';

Widget setStartupPicTile(BuildContext context) {
  return ListTile(
    title: Text(tr("settings.startup_pic.title")),
    subtitle: Text(tr("settings.startup_pic.subtitle")),
    onTap: () {
      if (Platform.isAndroid || Platform.isIOS) {
        _updateStartupPicPhone(context);
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        _updateStartupPicDesktop(context);
      }
    },
  );
}

Widget clearStartupPicTile(BuildContext context) {
  return ListTile(
    title: Text(tr("settings.startup_pic.clear_title")),
    subtitle: Text(tr("settings.startup_pic.clear_subtitle")),
    onTap: () async {
      await clearStartupPic(context);
      defaultToast(context, tr("settings.startup_pic.clear_success"));
    },
  );
}

Future<void> _updateStartupPicPhone(BuildContext context) async {
  final ImagePicker _picker = ImagePicker();
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    await image.saveTo(p.join(await method.dataLocal(), "startup_pic"));
    defaultToast(context, tr("settings.startup_pic.update_success"));
  }
}

Future<void> _updateStartupPicDesktop(BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
  );
  if (result != null) {
    final file = result.files.single;
    final startupPicPath = p.join(await method.dataLocal(), "startup_pic");
    final destination = File(startupPicPath);
    await destination.create(recursive: true);
    await File(file.path!).copy(destination.path);
    defaultToast(context, tr("settings.startup_pic.update_success"));
  }
}

Future<void> clearStartupPic(BuildContext context) async {
  final startupPicPath = p.join(await method.dataLocal(), "startup_pic");
  final file = File(startupPicPath);
  if (await file.exists()) {
    await file.delete();
  }
  defaultToast(context, tr("settings.startup_pic.clear_success"));
}
