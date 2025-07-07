import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/screens/components/ComicList.dart';

import 'DownloadComicsScreen.dart';

AppBar downAppBar(
  BuildContext context,
  ComicListController _comicListController,
  void Function(VoidCallback fn) setState,
) {
  return AppBar(
    actions: [
      MaterialButton(
        minWidth: 0,
        onPressed: () async {
          setState(() {
            _comicListController.selecting = false;
          });
        },
        child: Column(
          children: [
            Expanded(child: Container()),
            const Icon(
              Icons.cancel_outlined,
              size: 18,
              color: Colors.white,
            ),
            Text(
              tr('app.cancel'),
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
      MaterialButton(
        minWidth: 0,
        onPressed: () async {
          _comicListController.selectAll();
        },
        child: Column(
          children: [
            Expanded(child: Container()),
            const Icon(
              Icons.select_all,
              size: 18,
              color: Colors.white,
            ),
            Text(
              tr('app.select_all'),
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
      MaterialButton(
        minWidth: 0,
        onPressed: () async {
          var list = _comicListController.selected;
          if (list.isEmpty) {
            defaultToast(context, tr("app.please_select_comic"));
            return;
          }
          list = list.toList();
          setState(() {
            _comicListController.selecting = false;
          });
          Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) {
              return DownloadComicsScreen(list);
            },
          ));
        },
        child: Column(
          children: [
            Expanded(child: Container()),
            const Icon(
              Icons.check,
              size: 18,
              color: Colors.white,
            ),
            Text(
              tr('app.confirm'),
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    ],
  );
}
