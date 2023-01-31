import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Entities.dart' as e;
import 'package:pikapika/screens/CommentScreen.dart';
import 'package:pikapika/screens/components/ItemBuilder.dart';
import 'package:pikapika/basic/Method.dart';
import '../../basic/config/IconLoading.dart';
import 'CommentItem.dart';
import 'CommentMainType.dart';

class _CommentBasePage extends e.Page {
  late List<CommentBase> docs;

  _CommentBasePage.ofComic(CommentPage commentPage)
      : super.of(commentPage.total, commentPage.limit, commentPage.page,
            commentPage.pages) {
    this.docs = commentPage.docs;
  }

  _CommentBasePage.ofGame(GameCommentPage commentPage)
      : super.of(commentPage.total, commentPage.limit, commentPage.page,
            commentPage.pages) {
    this.docs = commentPage.docs;
  }
}

// 漫画的评论列表
class CommentList extends StatefulWidget {
  final CommentMainType mainType;
  final String mainId;

  const CommentList(this.mainType, this.mainId, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  late int _currentPage = 1;
  late Future<_CommentBasePage> _future = _loadPage();

  Future<_CommentBasePage> _loadPage() async {
    switch (widget.mainType) {
      case CommentMainType.COMIC:
        return _CommentBasePage.ofComic(
          await method.comments(widget.mainId, _currentPage),
        );
      case CommentMainType.GAME:
        return _CommentBasePage.ofGame(
          await method.gameComments(widget.mainId, _currentPage),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ItemBuilder(
      future: _future,
      successBuilder:
          (BuildContext context, AsyncSnapshot<_CommentBasePage> snapshot) {
        var page = snapshot.data!;
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPrePage(page),
            ...page.docs.map((e) => _buildComment(e)),
            _buildNextPage(page),
            _buildPostComment(),
          ],
        );
      },
      onRefresh: () async => {
        setState(() {
          _future = _loadPage();
        })
      },
    );
  }

  Widget _buildComment(CommentBase comment) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          mixRoute(
            builder: (context) =>
                CommentScreen(widget.mainType, widget.mainId, comment),
          ),
        );
      },
      child: ComicCommentItem(widget.mainType, widget.mainId, comment),
    );
  }

  Widget _buildPostComment() {
    return InkWell(
      onTap: () async {
        String? text = await inputString(context, '请输入评论内容');
        if (text != null && text.isNotEmpty) {
          try {
            switch (widget.mainType) {
              case CommentMainType.COMIC:
                await method.postComment(widget.mainId, text);
                break;
              case CommentMainType.GAME:
                await method.postGameComment(widget.mainId, text);
                break;
            }
            setState(() {
              _future = _loadPage();
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

  Widget _buildPrePage(_CommentBasePage page) {
    if (page.page > 1) {
      return InkWell(
        onTap: () {
          setState(() {
            _currentPage = page.page - 1;
            _future = _loadPage();
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

  Widget _buildNextPage(_CommentBasePage page) {
    if (page.page < page.pages) {
      return InkWell(
        onTap: () {
          setState(() {
            _currentPage = page.page + 1;
            _future = _loadPage();
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
