import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';

import '../../basic/Cross.dart';
import 'Avatar.dart';
import 'CommentMainType.dart';

class ComicCommentItem extends StatefulWidget {
  final CommentMainType mainType;
  final String mainId;
  final CommentBase comment;

  const ComicCommentItem(this.mainType, this.mainId, this.comment, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicCommentItemState();
}

class _ComicCommentItemState extends State<ComicCommentItem> {
  var likeLoading = false;

  @override
  Widget build(BuildContext context) {
    var comment = widget.comment;
    var theme = Theme.of(context);
    var nameStyle = const TextStyle(fontWeight: FontWeight.bold);
    var levelStyle = TextStyle(
        fontSize: 12, color: theme.colorScheme.secondary.withOpacity(.8));
    var connectStyle =
        TextStyle(color: theme.textTheme.bodyText1?.color?.withOpacity(.8));
    var datetimeStyle = TextStyle(
        color: theme.textTheme.bodyText1?.color?.withOpacity(.6), fontSize: 12);
    return Container(
      padding: const EdgeInsets.all(5),
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
          Avatar(comment.user.avatar),
          Container(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SizedBox(
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
                    return SizedBox(
                      width: constraints.maxWidth,
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Text(
                              "Lv. ${comment.user.level} (${comment.user.title})",
                              style: levelStyle),
                          Text.rich(TextSpan(
                            style: levelStyle,
                            children: [
                              comment.commentsCount > 0
                                  ? TextSpan(children: [
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
                                      ),
                                    ])
                                  : const TextSpan(),
                              WidgetSpan(child: Container(width: 12)),
                              WidgetSpan(
                                  child: GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    likeLoading = true;
                                  });
                                  try {
                                    switch (widget.mainType) {
                                      case CommentMainType.COMIC:
                                        await method.switchLikeComment(
                                          comment.id,
                                          widget.mainId,
                                        );
                                        break;
                                      case CommentMainType.GAME:
                                        await method.switchLikeGameComment(
                                          comment.id,
                                          widget.mainId,
                                        );
                                        break;
                                    }
                                    setState(() {
                                      if (comment.isLiked) {
                                        comment.isLiked = false;
                                        comment.likesCount--;
                                      } else {
                                        comment.isLiked = true;
                                        comment.likesCount++;
                                      }
                                    });
                                  } catch (e, s) {
                                    print("$e\n$s");
                                    defaultToast(context, "点赞失败");
                                  } finally {
                                    setState(() {
                                      likeLoading = false;
                                    });
                                  }
                                },
                                child: Text.rich(
                                  TextSpan(style: levelStyle, children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Icon(
                                          likeLoading
                                              ? Icons.refresh
                                              : comment.isLiked
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                          size: 13,
                                          color: theme.colorScheme.secondary
                                              .withOpacity(.7)),
                                    ),
                                    WidgetSpan(child: Container(width: 5)),
                                    TextSpan(
                                      text: '${comment.likesCount}',
                                    ),
                                  ]),
                                ),
                              )),
                            ],
                          )),
                        ],
                      ),
                    );
                  },
                ),
                Container(height: 5),
                GestureDetector(
                  onLongPress: () {
                    confirmCopy(context, comment.content);
                  },
                  child: Text(comment.content, style: connectStyle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
