import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Entities.dart' as e;
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/components/CommentItem.dart';
import 'package:pikapika/screens/components/CommentMainType.dart';
import 'package:pikapika/screens/components/ContentBuilder.dart';

import 'components/ListView.dart';
import 'components/RightClickPop.dart';

class _CommentChildPage extends e.Page {
  late List<ChildOfComment> docs;

  _CommentChildPage.ofComic(CommentChildrenPage commentPage)
      : super.of(commentPage.total, commentPage.limit, commentPage.page,
            commentPage.pages) {
    this.docs = commentPage.docs;
  }

  _CommentChildPage.ofGame(GameCommentChildrenPage commentPage)
      : super.of(commentPage.total, commentPage.limit, commentPage.page,
            commentPage.pages) {
    this.docs = commentPage.docs;
  }
}

class CommentScreen extends StatefulWidget {
  final CommentMainType mainType;
  final String mainId;
  final CommentBase comment;

  const CommentScreen(this.mainType, this.mainId, this.comment, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  late int _currentPage = 1;
  late Future<_CommentChildPage> _future = _loadPage();
  late Key _key = UniqueKey();

  Future<_CommentChildPage> _loadPage() async {
    switch (widget.mainType) {
      case CommentMainType.COMIC:
        return _CommentChildPage.ofComic(await method.commentChildren(
          widget.mainId,
          widget.comment.id,
          _currentPage,
        ));
      case CommentMainType.GAME:
        return _CommentChildPage.ofGame(await method.gameCommentChildren(
          widget.mainId,
          widget.comment.id,
          _currentPage,
        ));
    }
  }

  Widget _buildChildrenPager() {
    return ContentBuilder(
      key: _key,
      future: _future,
      onRefresh: _loadPage,
      successBuilder:
          (BuildContext context, AsyncSnapshot<_CommentChildPage> snapshot) {
        var page = snapshot.data!;
        return PikaListView(
          children: [
            _buildPrePage(page),
            ...page.docs.map((e) => _buildComment(e)),
            _buildNextPage(page),
            _buildPostComment(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(
      child: buildScreen(context),
      context: context,
      canPop: true,
    );
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('评论'),
      ),
      body: Column(
        children: [
          ComicCommentItem(widget.mainType, widget.mainId, widget.comment),
          Container(
            height: 3,
            color:
                (Theme.of(context).textTheme.bodyText1?.color ?? Colors.black)
                    .withOpacity(.05),
          ),
          Expanded(child: _buildChildrenPager())
        ],
      ),
    );
  }

  Widget _buildComment(CommentBase e) {
    return ComicCommentItem(widget.mainType, widget.mainId, e);
  }

  Widget _buildPostComment() {
    return InkWell(
      onTap: () async {
        String? text = await inputString(context, '请输入评论内容');
        if (text != null && text.isNotEmpty) {
          try {
            switch (widget.mainType) {
              case CommentMainType.COMIC:
                await method.postChildComment(widget.comment.id, text);
                break;
              case CommentMainType.GAME:
                await method.postGameChildComment(widget.comment.id, text);
                break;
            }
            setState(() {
              _future = _loadPage();
              _key = UniqueKey();
              widget.comment.commentsCount++;
            });
          } catch (e) {
            defaultToast(context, "评论失败");
          }
        }
      },
      child: Container(
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
        padding: const EdgeInsets.all(30),
        child: const Center(
          child: Text('我有话要讲'),
        ),
      ),
    );
  }

  Widget _buildPrePage(_CommentChildPage page) {
    if (page.page > 1) {
      return InkWell(
        onTap: () {
          setState(() {
            _currentPage = page.page - 1;
            _future = _loadPage();
            _key = UniqueKey();
          });
        },
        child: Container(
          padding: const EdgeInsets.all(30),
          child: const Center(
            child: Text('上一页'),
          ),
        ),
      );
    }
    return Container();
  }

  Widget _buildNextPage(_CommentChildPage page) {
    if (page.page < page.pages) {
      return InkWell(
        onTap: () {
          setState(() {
            _currentPage = page.page + 1;
            _future = _loadPage();
            _key = UniqueKey();
          });
        },
        child: Container(
          padding: const EdgeInsets.all(30),
          child: const Center(
            child: Text('下一页'),
          ),
        ),
      );
    }
    return Container();
  }
}
