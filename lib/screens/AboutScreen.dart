import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pikapi/basic/Cross.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var size = MediaQuery.of(context).size;
    var min = size.width < size.height ? size.width : size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('关于'),
      ),
      body: ListView(
        children: [
          Container(
            width: min / 2,
            height: min / 2,
            child: Center(
              child: SvgPicture.asset(
                'lib/assets/github.svg',
                width: min / 3,
                height: min / 3,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Text(
              '请从软件取得渠道获取更新\n本软件开源, 若您想提出改进建议或者获取源码, 请在开源社区搜索 pikapi-flutter',
              style: TextStyle(
                height: 1.3,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: SelectableText(
              "提示 : \n"
              "1. 详情页的作者/上传者/分类/标签都可以点击\n"
              "2. 详情页的作者/上传者/标题长按可以复制\n"
              "3. 使用分页而不是瀑布流点击页码可以快速翻页\n"
              "4. 下载指的是缓存到本地, 需要导出才可以分享\n"
              "5. 下载长按可以删除\n",
              style: TextStyle(
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
