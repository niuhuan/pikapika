import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/AccessKeyReplaceScreen.dart';

import '../basic/config/IconLoading.dart';
import '../basic/config/IsPro.dart';

class ProScreen extends StatefulWidget {
  const ProScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  String _username = "";

  @override
  void initState() {
    method.getUsername().then((value) {
      setState(() {
        _username = value;
      });
    });
    proEvent.subscribe(_setState);
    super.initState();
  }

  @override
  void dispose() {
    proEvent.unsubscribe(_setState);
    super.dispose();
  }

  _setState(_) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var min = size.width < size.height ? size.width : size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("发电中心"),
      ),
      body: ListView(
        children: [
          SizedBox(
            width: min / 2,
            height: min / 2,
            child: Center(
              child: Icon(
                isPro ? Icons.offline_bolt : Icons.offline_bolt_outlined,
                size: min / 3,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Center(child: Text(_username)),
          Container(height: 20),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "去\"关于\"界面找到维护地址可获得发电指引\n\n"
              "1. \"签到/游戏/兑换\" \n"
              "  (1). \"我曾经发过电\"可同步相应发电状态\n"
              "  (2). \"我刚才发了电\"兑换作者给您的礼物卡\n"
              "\n"
              "2. \"PAT入会\"\n"
              "  🔗将社区账号链接到软件, 同步成员状态, 订阅式发电"
              "",
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text("签到/游戏/兑换"),
            subtitle: Text(
              proInfoAf.isPro
                  ? "发电中 (${DateTime.fromMillisecondsSinceEpoch(1000 * proInfoAf.expire).toString()})"
                  : "未发电",
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text("我曾经发过电"),
            onTap: () async {
              try {
                await method.reloadPro();
                defaultToast(context, "SUCCESS");
              } catch (e, s) {
                defaultToast(context, "FAIL");
              }
              await reloadIsPro();
              setState(() {});
            },
          ),
          const Divider(),
          ListTile(
            title: const Text("我刚才发了电"),
            onTap: () async {
              final code = await inputString(context, "输入代码");
              if (code != null && code.isNotEmpty) {
                try {
                  await method.inputCdKey(code);
                  defaultToast(context, "SUCCESS");
                } catch (e, s) {
                  defaultToast(context, "FAIL");
                }
              }
              await reloadIsPro();
              setState(() {});
            },
          ),
          const Divider(),
          ...patPro(),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "发电小功能 \n"
                  "  多线程下载\n"
                  "  批量导入导出\n"
                  "  跳页",
            ),
          ),
          const Divider(),
          const Divider(),
        ],
      ),
    );
  }

  List<Widget> patPro() {
    List<Widget> widgets = [];
    if (proInfoPat.accessKey.isNotEmpty) {
      var text = "密钥 : 已录入";
      if (proInfoPat.patId.isNotEmpty) {
        text += "\nPAT账号 : ${proInfoPat.patId}";
      }
      if (proInfoPat.bindUid.isNotEmpty) {
        text += "\n绑定PIKA账号 : ${proInfoPat.bindUid}";
      }
      if (proInfoPat.requestDelete > 0) {
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
          proInfoPat.requestDelete * 1000,
          isUtc: true,
        );
        String formattedDate =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime.toLocal());
        text += "\n绑定账号时间 : $formattedDate";
      }
      if (proInfoPat.reBind > 0) {
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
          proInfoPat.reBind * 1000,
          isUtc: true,
        );
        String formattedDate =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime.toLocal());
        text += "\n可以换绑时间 : $formattedDate";
      }
      List<TextSpan> append = [];
      if (proInfoPat.bindUid == "") {
        append.add(const TextSpan(
          text: "\n(请点击这里绑定到当前账号发电)",
          style: TextStyle(color: Colors.blue),
        ));
      } else if (proInfoPat.bindUid != _username) {
        append.add(const TextSpan(
          text: "\n(请点换绑到当前账号发电)",
          style: TextStyle(color: Colors.red),
        ));
      } else if (proInfoPat.isPro == false) {
        append.add(const TextSpan(
          text: "\n(未检测到入会, 请到下载页入会)",
          style: TextStyle(color: Colors.orange),
        ));
      } else {
        append.add(const TextSpan(
          text: "\n(PAT正常)",
          style: TextStyle(color: Colors.green),
        ));
      }
      widgets.add(ListTile(
        onTap: () async {
          print(jsonEncode(proInfoPat));
          var choose = await chooseMapDialog<int>(
            context,
            {
              "更新PAT发电状态": 2,
              "绑定到此账号": 3,
              "更换PAT密钥": 1,
              "清除PAT信息": 4,
            },
            "请选择",
          );
          switch (choose) {
            case 1:
              addPatAccount();
              break;
            case 2:
              reloadPatAccount();
              break;
            case 3:
              bindThisAccount();
              break;
            case 4:
              clearPat();
              break;
          }
        },
        title: const Text("PAT入会"),
        subtitle: Text.rich(TextSpan(children: [
          TextSpan(text: text),
          ...append,
        ])),
      ));
    } else {
      widgets.add(ListTile(
        onTap: () {
          addPatAccount();
        },
        title: const Text("PAT入会"),
        subtitle: const Text("点击绑定"),
      ));
    }
    return widgets;
  }

  void addPatAccount() async {
    print(jsonEncode(proInfoPat));
    String? key = await inputString(context, "请输入授权代码");
    if (key != null) {
      await Navigator.of(context)
          .push(mixRoute(builder: (BuildContext context) {
        return AccessKeyReplaceScreen(accessKey: key);
      }));
    }
  }

  reloadPatAccount() async {
    defaultToast(context, "请稍后");
    try {
      await method.reloadPatAccount();
      await reloadIsPro();
      defaultToast(context, "SUCCESS");
    } catch (e) {
      defaultToast(context, "FAIL : $e");
    } finally {}
  }

  bindThisAccount() async {
    defaultToast(context, "请稍后");
    try {
      await method.bindThisAccount();
      await reloadIsPro();
      defaultToast(context, "SUCCESS");
    } catch (e) {
      defaultToast(context, "FAIL : $e");
    } finally {}
  }

  clearPat() async {
    await method.clearPat();
    await reloadIsPro();
    defaultToast(context, "Success");
  }
}
