import 'package:easy_localization/easy_localization.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/config/ShadowCategoriesEvent.dart';
import 'package:pikapika/screens/components/ComicList.dart';
import 'package:pikapika/screens/components/FitButton.dart';
import 'ContentBuilder.dart';

class ComicListBuilder extends StatefulWidget {
  final Future<List<ComicSimple>> Function() takeList;

  const ComicListBuilder(this.takeList, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicListBuilderState();
}

class _ComicListBuilderState extends State<ComicListBuilder> {
  late Future<List<ComicSimple>> _future = widget.takeList();
  late Key _key = UniqueKey();

  @override
  void initState() {
    shadowCategoriesEvent.subscribe(_onShadowChange);
    super.initState();
  }

  @override
  void dispose() {
    shadowCategoriesEvent.unsubscribe(_onShadowChange);
    super.dispose();
  }

  void _onShadowChange(EventArgs? args) {
    setState(() {});
  }

  Future _reload() async {
    setState(() {
      _future = widget.takeList();
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ContentBuilder(
      key: _key,
      future: _future,
      onRefresh: _reload,
      successBuilder:
          (BuildContext context, AsyncSnapshot<List<ComicSimple>> snapshot) {
        return RefreshIndicator(
          onRefresh: _reload,
          child: ComicList(
            snapshot.data!,
            appendWidget: FitButton(
              onPressed: _reload,
              text: tr('app.refresh'),
            ),
          ),
        );
      },
    );
  }
}
