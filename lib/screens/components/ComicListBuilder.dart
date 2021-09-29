import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/screens/components/ComicList.dart';
import 'package:pikapi/screens/components/FitButton.dart';
import 'ContentBuilder.dart';

class ComicListBuilder extends StatelessWidget {
  final Future<List<ComicSimple>> future;
  final Future Function() reload;

  ComicListBuilder(this.future, this.reload);

  @override
  Widget build(BuildContext context) {
    return ContentBuilder(
      future: future,
      onRefresh: reload,
      successBuilder:
          (BuildContext context, AsyncSnapshot<List<ComicSimple>> snapshot) {
        return RefreshIndicator(
          onRefresh: reload,
          child: ComicList(
            snapshot.data!,
            appendWidget: FitButton(
              onPressed: reload,
              text: '刷新',
            ),
          ),
        );
      },
    );
  }
}
