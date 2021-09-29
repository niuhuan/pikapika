import 'package:flutter/material.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Entities.dart';

import 'PicaAvatar.dart';

class ComicCommentItem extends StatelessWidget {
  final Comment comment;

  const ComicCommentItem(this.comment);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var nameStyle = TextStyle(fontWeight: FontWeight.bold);
    var levelStyle = TextStyle(
        fontSize: 12, color: theme.colorScheme.secondary.withOpacity(.8));
    var connectStyle =
        TextStyle(color: theme.textTheme.bodyText1?.color?.withOpacity(.8));
    var datetimeStyle = TextStyle(
        color: theme.textTheme.bodyText1?.color?.withOpacity(.6), fontSize: 12);
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: .25,
            style: BorderStyle.solid,
            color: Colors.grey.shade500.withOpacity(.5),
          ),
          bottom: BorderSide(
            width: .25,
            style: BorderStyle.solid,
            color: Colors.grey.shade500.withOpacity(.5),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PicaAvatar(comment.user.avatar),
          Container(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Container(
                      width: constraints.maxWidth,
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Text(comment.user.name, style: nameStyle),
                          Text(
                            formatTimeToDateTime(comment.createdAt),
                            style: datetimeStyle,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Container(height: 3),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Container(
                      width: constraints.maxWidth,
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Text(
                              "Lv. ${comment.user.level} (${comment.user.title})",
                              style: levelStyle),
                          comment.commentsCount > 0
                              ? Text.rich(TextSpan(children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(Icons.message,
                                        size: 13,
                                        color: theme.colorScheme.secondary
                                            .withOpacity(.7)),
                                  ),
                                  WidgetSpan(child: Container(width: 5)),
                                  TextSpan(
                                      text: '${comment.commentsCount}',
                                      style: levelStyle),
                                ]))
                              : Container(),
                        ],
                      ),
                    );
                  },
                ),
                Container(height: 5),
                Text(comment.content, style: connectStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
