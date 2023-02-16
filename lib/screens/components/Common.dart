import 'package:flutter/material.dart';

import '../../basic/config/ListLayout.dart';
import '../../basic/config/ShadowCategories.dart';
import '../../basic/config/ShadowCategoriesMode.dart';

Widget aPopMenu(BuildContext context) {
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
      }
    },
  );
}
