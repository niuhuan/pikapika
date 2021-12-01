import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/Cross.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/SearchScreen.dart';
import 'package:pikapika/basic/Navigatior.dart';
import '../ComicsScreen.dart';
import 'Images.dart';

// 漫画卡片
class ComicInfoCard extends StatefulWidget {
  final bool linkItem;
  final ComicSimple info;

  const ComicInfoCard(this.info, {Key? key, this.linkItem = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicInfoCard();
}

class _ComicInfoCard extends State<ComicInfoCard> {
  bool _favouriteLoading = false;
  bool _likeLoading = false;

  @override
  Widget build(BuildContext context) {
    var info = widget.info;
    var theme = Theme.of(context);
    var view = info is ComicInfo ? info.viewsCount : 0;
    bool? like = info is ComicInfo ? info.isLiked : null;
    bool? favourite = info is ComicInfo ? (info).isFavourite : null;
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.only(right: 10),
            child: RemoteImage(
              fileServer: info.thumb.fileServer,
              path: info.thumb.path,
              width: imageWidth,
              height: imageHeight,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.linkItem
                          ? GestureDetector(
                              onLongPress: () {
                                confirmCopy(context, info.title);
                              },
                              child: Text(info.title, style: titleStyle),
                            )
                          : Text(info.title, style: titleStyle),
                      Container(height: 5),
                      widget.linkItem
                          ? InkWell(
                              onTap: () {
                                navPushOrReplace(
                                    context,
                                    (context) =>
                                        SearchScreen(keyword: info.author));
                              },
                              onLongPress: () {
                                confirmCopy(context, info.author);
                              },
                              child: Text(info.author, style: authorStyle),
                            )
                          : Text(info.author, style: authorStyle),
                      Container(height: 5),
                      Text.rich(
                        widget.linkItem
                            ? TextSpan(
                                children: [
                                  TextSpan(text: '分类 :'),
                                  ...info.categories.map(
                                    (e) => TextSpan(
                                      children: [
                                        TextSpan(text: ' '),
                                        TextSpan(
                                          text: e,
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => navPushOrReplace(
                                                  context,
                                                  (context) => ComicsScreen(
                                                    category: e,
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : TextSpan(
                                text: "分类 : ${info.categories.join(' ')}"),
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .color!
                              .withAlpha(0xCC),
                        ),
                      ),
                      Container(height: 5),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 5,
                        children: [
                          ...info.likesCount > 0
                              ? [
                                  iconFavorite,
                                  iconSpacing,
                                  Text(
                                    '${info.likesCount}',
                                    style: iconLabelStyle,
                                    strutStyle: iconLabelStrutStyle,
                                  ),
                                  iconMargin,
                                ]
                              : [],
                          ...(view > 0
                              ? [
                                  iconVisibility,
                                  iconSpacing,
                                  Text(
                                    '$view',
                                    style: iconLabelStyle,
                                    strutStyle: iconLabelStrutStyle,
                                  ),
                                  iconMargin,
                                ]
                              : []),
                          ...(info.epsCount > 0
                              ? [
                                  Text.rich(TextSpan(children: [
                                    WidgetSpan(child: iconPage),
                                    WidgetSpan(child: iconSpacing),
                                    WidgetSpan(child: Text(
                                      "${info.epsCount}E / ${info.pagesCount}P",
                                      style: countLabelStyle,
                                      strutStyle: iconLabelStrutStyle,
                                      softWrap: false,
                                    )),
                                    WidgetSpan(child: iconMargin),
                                  ])),
                                ]
                              : []),
                          iconMargin,
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: imageHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildFinished(info.finished),
                      Expanded(child: Container()),
                      ...(like == null
                          ? []
                          : [
                              _likeLoading
                                  ? IconButton(
                                      color: Colors.pink[400],
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.sync,
                                        size: 26,
                                      ),
                                    )
                                  : IconButton(
                                      color: Colors.pink[400],
                                      onPressed: _changeLike,
                                      icon: Icon(
                                        like
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 26,
                                      ),
                                    ),
                            ]),
                      ...(favourite == null
                          ? []
                          : [
                              _favouriteLoading
                                  ? IconButton(
                                      color: Colors.pink[400],
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.sync,
                                        size: 26,
                                      ),
                                    )
                                  : IconButton(
                                      color: Colors.pink[400],
                                      onPressed: _changeFavourite,
                                      icon: Icon(
                                        favourite
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        size: 26,
                                      ),
                                    ),
                            ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future _changeFavourite() async {
    setState(() {
      _favouriteLoading = true;
    });
    try {
      var rst = await method.switchFavourite(widget.info.id);
      setState(() {
        (widget.info as ComicInfo).isFavourite = !rst.startsWith("un");
      });
    } finally {
      setState(() {
        _favouriteLoading = false;
      });
    }
  }

  Future _changeLike() async {
    setState(() {
      _likeLoading = true;
    });
    try {
      var rst = await method.switchLike(widget.info.id);
      setState(() {
        (widget.info as ComicInfo).isLiked = !rst.startsWith("un");
      });
    } finally {
      setState(() {
        _likeLoading = false;
      });
    }
  }
}

double imageWidth = 210 / 3.15;
double imageHeight = 315 / 3.15;

Widget buildFinished(bool comicFinished) {
  if (comicFinished) {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade800,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        "完结",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.2,
        ),
        strutStyle: StrutStyle(
          height: 1.2,
        ),
      ),
    );
  }
  return Container();
}

const double _iconSize = 15;

final iconFavorite =
    Icon(Icons.favorite, size: _iconSize, color: Colors.pink[400]);
final iconDownload =
    Icon(Icons.download_rounded, size: _iconSize, color: Colors.pink[400]);
final iconVisibility =
    Icon(Icons.visibility, size: _iconSize, color: Colors.pink[400]);

final iconLabelStyle = TextStyle(
  fontSize: 13,
  color: Colors.pink.shade400,
  height: 1.2,
);
final iconLabelStrutStyle = StrutStyle(
  height: 1.2,
);

final iconPage =
    Icon(Icons.ballot_outlined, size: _iconSize, color: Colors.grey);
final countLabelStyle = TextStyle(
  fontSize: 13,
  color: Colors.grey,
  height: 1.2,
);

final iconMargin = Container(width: 20);
final iconSpacing = Container(width: 5);

final titleStyle = TextStyle(fontWeight: FontWeight.bold);
final authorStyle = TextStyle(
  fontSize: 13,
  color: Colors.pink.shade300,
);
