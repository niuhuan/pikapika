import 'package:pikapika/i18.dart';
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
      PopupMenuItem<int>(
        value: 0,
        child: ListTile(
          leading: const Icon(Icons.view_quilt),
          title: Text(tr("components.common.display_mode")),
        ),
      ),
      PopupMenuItem<int>(
        value: 1,
        child: ListTile(
          leading: const Icon(Icons.do_not_disturb_on_outlined),
          title: Text(tr("components.common.shadow_mode")),
        ),
      ),
      PopupMenuItem<int>(
        value: 2,
        child: ListTile(
          leading: const Icon(Icons.hide_source),
          title: Text(tr("components.common.shadow_list")),
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
                    tr("components.common.batch_download") +
                        (isPro ? "" : "(${tr('app.pro')})"),
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
            defaultToast(context, tr("app.pro_required"));
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
