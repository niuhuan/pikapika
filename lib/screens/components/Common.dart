import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/screens/components/ComicList.dart';

import '../../basic/config/IsPro.dart';
import '../../basic/config/ListLayout.dart';
import '../../basic/config/ShadowCategories.dart';
import '../../basic/config/ShadowCategoriesMode.dart';

Widget commonPopMenu(
  BuildContext context, {
  ComicListController? comicListController,
  void Function(VoidCallback fn)? setState,
}) {
  return PopupMenuButton<int>(
    itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
      const PopupMenuItem<int>(
        value: 0,
        child: ListTile(
          leading: Icon(Icons.view_quilt),
          title: Text("显示模式"),
        ),
      ),
      const PopupMenuItem<int>(
        value: 1,
        child: ListTile(
          leading: Icon(Icons.do_not_disturb_on_outlined),
          title: Text("封印模式"),
        ),
      ),
      const PopupMenuItem<int>(
        value: 2,
        child: ListTile(
          leading: Icon(Icons.hide_source),
          title: Text("封印列表"),
        ),
      ),
      ...comicListController != null && setState != null
          ? [
              PopupMenuItem<int>(
                value: 3,
                child: ListTile(
                  leading: Icon(
                    Icons.download,
                    color: isPro ? null : Colors.grey,
                  ),
                  title: Text(
                    "批量下载" + (isPro ? "" : "(发电)"),
                    style: TextStyle(
                      color: isPro ? null : Colors.grey,
                    ),
                  ),
                ),
              )
            ]
          : [],
    ],
    onSelected: (int value) {
      switch (value) {
        case 0:
          chooseListLayout(context);
          break;
        case 1:
          chooseShadowCategoriesMode(context);
          break;
        case 2:
          chooseShadowCategories(context);
          break;
        case 3:
          if (!isPro) {
            defaultToast(context, "请先发电呀");
            return;
          }
          if (setState != null) {
            if (comicListController != null) {
              setState(() {
                comicListController.selecting = !comicListController.selecting;
              });
            }
          }
          break;
      }
    },
  );
}
