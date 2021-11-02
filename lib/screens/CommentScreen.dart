import 'package:flutter/material.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Method.dart';
import 'package:pikapi/screens/components/ComicCommentItem.dart';
import 'package:pikapi/screens/components/ContentBuilder.dart';

class CommentScreen extends StatefulWidget {
  final String comicId;
  final Comment comment;

  const CommentScreen(this.comicId, this.comment);

  @override
  State<StatefulWidget> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  late int _currentPage = 1;
  late Future<CommentChildrenPage> _future = _loadPage();

  Future<CommentChildrenPage> _loadPage() {
    return method.commentChildren(
      widget.comicId,
      widget.comment.id,
      _currentPage,
    );
  }

  Widget _buildChildrenPager() {
    return ContentBuilder(
      future: _future,
      onRefresh: _loadPage,
      successBuilder:
          (BuildContext context, AsyncSnapshot<CommentChildrenPage> snapshot) {
        var page = snapshot.data!;
        return ListView(
          children: [
            _buildPrePage(page),
            ...page.docs.map((e) => _buildComment(e)),
            _buildPostComment(),
            _buildNextPage(page),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('评论'),
      ),
      body: Column(
        children: [
          ComicCommentItem(widget.comment, widget.comicId),
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

  Widget _buildComment(CommentChild e) {
    return ComicCommentItem(e, widget.comicId);
  }

  Widget _buildPostComment() {
    return InkWell(
      onTap: () async {
        String? text = await inputString(context, '请输入评论内容');
        if (text != null && text.isNotEmpty) {
          try {
            await method.postChildComment(widget.comment.id, text);
            setState(() {
              _future = _loadPage();
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
        padding: EdgeInsets.all(30),
        child: Center(
          child: Text('我有话要讲'),
        ),
      ),
    );
  }

  Widget _buildPrePage(CommentChildrenPage page) {
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

  Widget _buildNextPage(CommentChildrenPage page) {
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
