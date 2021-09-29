import 'package:flutter/material.dart';
import 'package:pikapi/basic/Navigatior.dart';

import '../ComicInfoScreen.dart';

class LinkToComicInfo extends StatelessWidget {
  final String comicId;
  final Widget child;

  const LinkToComicInfo({
    required this.comicId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {
          navPushOrReplace(
            context,
            (context) => ComicInfoScreen(comicId: comicId),
          );
        },
        child: child,
      );
}
