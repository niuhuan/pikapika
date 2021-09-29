import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/config/ShadowCategories.dart';
import 'package:pikapi/basic/config/ListLayout.dart';

import 'ComicInfoCard.dart';
import 'Images.dart';
import 'LinkToComicInfo.dart';

// 漫画列表页
class ComicList extends StatefulWidget {
  final Widget? appendWidget;
  final List<ComicSimple> comicList;
  final ScrollController? controller;

  const ComicList(this.comicList, {this.appendWidget, this.controller});

  @override
  State<StatefulWidget> createState() => _ComicListState();
}

class _ComicListState extends State<ComicList> {
  @override
  void initState() {
    listLayoutEvent.subscribe(_onLayoutChange);
    super.initState();
  }

  @override
  void dispose() {
    listLayoutEvent.unsubscribe(_onLayoutChange);
    super.dispose();
  }

  void _onLayoutChange(EventArgs? args) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    switch (currentLayout) {
      case ListLayout.INFO_CARD:
        return _buildInfoCardList();
      case ListLayout.ONLY_IMAGE:
        return _buildGridImageWarp();
      case ListLayout.COVER_AND_TITLE:
        return _buildGridImageTitleWarp();
      default:
        return Container();
    }
  }

  Widget _buildInfoCardList() {
    return ListView(
      controller: widget.controller,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        ...widget.comicList.map((e) {
          var shadow = e.categories
              .map((e) => shadowCategories.contains(e))
              .reduce((value, element) => value || element);
          if (shadow) {
            return InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    '被封印的本子',
                    style: TextStyle(
                      fontSize: 12,
                      color: (Theme.of(context).textTheme.bodyText1?.color ??
                              Colors.black)
                          .withOpacity(.3),
                    ),
                  ),
                ),
              ),
            );
          }
          return LinkToComicInfo(
            comicId: e.id,
            child: ComicInfoCard(e),
          );
        }).toList(),
        ...widget.appendWidget != null
            ? [
                Container(
                  height: 80,
                  child: widget.appendWidget,
                ),
              ]
            : [],
      ],
    );
  }

  Widget _buildGridImageWarp() {
    var gap = 3.0;
    var size = MediaQuery.of(context).size;
    var min = size.width < size.height ? size.width : size.height;
    var widthAndGap = min / 4;
    int rowCap = size.width ~/ widthAndGap;
    var width = widthAndGap - gap * 2;
    var height = width * coverHeight / coverWidth;
    List<Widget> wraps = [];
    List<Widget> tmp = [];
    widget.comicList.forEach((e) {
      var shadow = e.categories
          .map((e) => shadowCategories.contains(e))
          .reduce((value, element) => value || element);
      if (shadow) {
        tmp.add(
          Container(
            padding: EdgeInsets.all(gap),
            child: Container(
              width: width,
              height: height,
              color:
                  (Theme.of(context).textTheme.bodyText1?.color ?? Colors.black)
                      .withOpacity(.05),
              child: Center(
                child: Text(
                  '被封印的本子',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: (Theme.of(context).textTheme.bodyText1?.color ??
                            Colors.black)
                        .withOpacity(.5),
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        tmp.add(LinkToComicInfo(
          comicId: e.id,
          child: Container(
            padding: EdgeInsets.all(gap),
            child: RemoteImage(
              fileServer: e.thumb.fileServer,
              path: e.thumb.path,
              width: width,
              height: height,
            ),
          ),
        ));
      }
      if (tmp.length == rowCap) {
        wraps.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: tmp,
        ));
        tmp = [];
      }
    });
    // 追加特殊按钮
    if (widget.appendWidget != null) {
      tmp.add(Container(
        color: (Theme.of(context).textTheme.bodyText1?.color ?? Color(0))
            .withOpacity(.1),
        margin: EdgeInsets.only(
          left: (rowCap - tmp.length) * gap,
          right: (rowCap - tmp.length) * gap,
          top: gap,
          bottom: gap,
        ),
        width: (rowCap - tmp.length) * width,
        height: height,
        child: widget.appendWidget,
      ));
    }
    // 最后一页没有下一页所有有可能为空
    if (tmp.length > 0) {
      wraps.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tmp,
      ));
      tmp = [];
    }
    // 返回
    return ListView(
      controller: widget.controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: gap, bottom: gap),
      children: wraps,
    );
  }

  Widget _buildGridImageTitleWarp() {
    var gap = 3.0;
    var size = MediaQuery.of(context).size;
    var min = size.width < size.height ? size.width : size.height;
    var widthAndGap = min / 3;
    int rowCap = size.width ~/ widthAndGap;
    var width = widthAndGap - gap * 2;
    var height = width * coverHeight / coverWidth;
    List<Widget> wraps = [];
    List<Widget> tmp = [];
    widget.comicList.forEach((e) {
      var shadow = e.categories
          .map((e) => shadowCategories.contains(e))
          .reduce((value, element) => value || element);
      if (shadow) {
        tmp.add(
          Container(
            padding: EdgeInsets.all(gap),
            child: Container(
              width: width,
              height: height,
              color:
                  (Theme.of(context).textTheme.bodyText1?.color ?? Colors.black)
                      .withOpacity(.05),
              child: Center(
                child: Text(
                  '被封印的本子',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: (Theme.of(context).textTheme.bodyText1?.color ??
                            Colors.black)
                        .withOpacity(.5),
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        tmp.add(LinkToComicInfo(
          comicId: e.id,
          child: Container(
            margin: EdgeInsets.all(gap),
            width: width,
            height: height,
            child: Stack(
              children: [
                RemoteImage(
                  fileServer: e.thumb.fileServer,
                  path: e.thumb.path,
                  width: width,
                  height: height,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.black.withOpacity(.3),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.title + '\n',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              height: 1.2,
                            ),
                            strutStyle: StrutStyle(height: 1.2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
      }
      if (tmp.length == rowCap) {
        wraps.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: tmp,
        ));
        tmp = [];
      }
    });
    // 追加特殊按钮
    if (widget.appendWidget != null) {
      tmp.add(Container(
        color: (Theme.of(context).textTheme.bodyText1?.color ?? Color(0))
            .withOpacity(.1),
        margin: EdgeInsets.only(
          left: (rowCap - tmp.length) * gap,
          right: (rowCap - tmp.length) * gap,
          top: gap,
          bottom: gap,
        ),
        width: (rowCap - tmp.length) * width,
        height: height,
        child: widget.appendWidget,
      ));
    }
    // 最后一页没有下一页所有有可能为空
    if (tmp.length > 0) {
      wraps.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tmp,
      ));
      tmp = [];
    }
    // 返回
    return ListView(
      controller: widget.controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: gap, bottom: gap),
      children: wraps,
    );
  }
}
