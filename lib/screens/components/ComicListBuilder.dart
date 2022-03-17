import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/config/ShadowCategoriesEvent.dart';
import 'package:pikapika/screens/components/ComicList.dart';
import 'package:pikapika/screens/components/FitButton.dart';
import 'ContentBuilder.dart';

class ComicListBuilder extends StatefulWidget {
  final Future<List<ComicSimple>> future;
  final Future Function() reload;

  const ComicListBuilder(this.future, this.reload, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicListBuilderState();
}

class _ComicListBuilderState extends State<ComicListBuilder> {
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

  @override
  Widget build(BuildContext context) {
    return ContentBuilder(
      future: widget.future,
      onRefresh: widget.reload,
      successBuilder:
          (BuildContext context, AsyncSnapshot<List<ComicSimple>> snapshot) {
        return RefreshIndicator(
          onRefresh: widget.reload,
          child: ComicList(
            snapshot.data!,
            appendWidget: FitButton(
              onPressed: widget.reload,
              text: '刷新',
            ),
          ),
        );
      },
    );
  }
}
