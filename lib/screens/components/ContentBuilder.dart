import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'ContentError.dart';
import 'ContentLoading.dart';

class ContentBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Future<dynamic> Function() onRefresh;
  final AsyncWidgetBuilder<T> successBuilder;

  const ContentBuilder({
    required Key? key,
    required this.future,
    required this.onRefresh,
    required this.successBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasError) {
          return ContentError(
            error: snapshot.error,
            stackTrace: snapshot.stackTrace,
            onRefresh: onRefresh,
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return ContentLoading(label: tr('app.loading'));
        }
        return successBuilder(context, snapshot);
      },
    );
  }
}
