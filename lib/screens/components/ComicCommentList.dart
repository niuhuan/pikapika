import 'package:flutter/material.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/screens/CommentScreen.dart';
import 'package:pikapi/screens/components/ItemBuilder.dart';
import 'package:pikapi/basic/Method.dart';
import 'ComicCommentItem.dart';

// 漫画的评论列表
class ComicCommentList extends StatefulWidget {
  final String comicId;

  ComicCommentList(this.comicId);

  @override
  State<StatefulWidget> createState() => _ComicCommentListState();
}

class _ComicCommentListState extends State<ComicCommentList> {
  late int _currentPage = 1;
  late Future<CommentPage> _future = _loadPage();

  Future<CommentPage> _loadPage() {
    return method.comments(widget.comicId, _currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return ItemBuilder(
      future: _future,
      successBuilder:
          (BuildContext context, AsyncSnapshot<CommentPage> snapshot) {
        var page = snapshot.data!;
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPrePage(page),
            ...page.docs.map((e) => _buildComment(e)),
            _buildPostComment(),
            _buildNextPage(page),
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

  Widget _buildComment(Comment comment) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CommentScreen(widget.comicId, comment),
          ),
        );
      },
      child: ComicCommentItem(comment),
    );
  }

  Widget _buildPostComment() {
    return InkWell(
      onTap: () async {
        String? text = await inputString(context, '请输入评论内容');
        if (text != null && text.isNotEmpty) {
          try {
            await method.postComment(widget.comicId, text);
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
        padding: EdgeInsets.all(30),
        child: Center(
          child: Text('我有话要讲'),
        ),
      ),
    );
  }

  Widget _buildPrePage(CommentPage page) {
    if (page.page > 1) {
      return InkWell(
        onTap: () {
          setState(() {
            _currentPage = page.page - 1;
            _future = _loadPage();
          });
        },
        child: Container(
          padding: EdgeInsets.all(30),
          child: Center(
            child: Text('上一页'),
          ),
        ),
      );
    }
    return Container();
  }

  Widget _buildNextPage(CommentPage page) {
    if (page.page < page.pages) {
      return InkWell(
        onTap: () {
          setState(() {
            _currentPage = page.page + 1;
            _future = _loadPage();
          });
        },
        child: Container(
          padding: EdgeInsets.all(30),
          child: Center(
            child: Text('下一页'),
          ),
        ),
      );
    }
    return Container();
  }
}
