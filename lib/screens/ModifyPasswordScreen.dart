import 'package:flutter/material.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/components/ContentLoading.dart';

import '../basic/Common.dart';
import 'components/ListView.dart';
import 'components/RightClickPop.dart';

class ModifyPasswordScreen extends StatefulWidget {
  const ModifyPasswordScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ModifyPasswordScreenState();
}

class _ModifyPasswordScreenState extends State<ModifyPasswordScreen> {
  late bool _loading = false;
  late String _oldPassword = "";
  late String _newPassword = "";
  late String _newPasswordRep = "";

  @override
  Widget build(BuildContext context){
    return rightClickPop(
      child: buildScreen(context),
      context: context,
      canPop: true,
    );
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("修改密码"),
      ),
      body: _loading
          ? Stack(
              children: [
                const ContentLoading(label: "请稍后"),
                WillPopScope(
                  child: Container(),
                  onWillPop: () async {
                    return false;
                  },
                ),
              ],
            )
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return PikaListView(
      children: [
        const Divider(),
        ListTile(
          title: const Text("旧密码"),
          subtitle: Text(_oldPassword == "" ? "未填写" : '\u2022' * 10),
          onTap: () async {
            String? input = await displayTextInputDialog(
              context,
              src: _oldPassword,
              title: '旧密码',
              hint: '请输入旧密码',
              isPasswd: true,
            );
            if (input != null) {
              setState(() {
                _oldPassword = input;
              });
            }
          },
        ),
        const Divider(),
        ListTile(
          title: const Text("新密码"),
          subtitle: Text(_newPassword == "" ? "未填写" : '\u2022' * 10),
          onTap: () async {
            String? input = await displayTextInputDialog(
              context,
              src: _newPassword,
              title: '新密码',
              hint: '请输入新密码',
              isPasswd: true,
            );
            if (input != null) {
              setState(() {
                _newPassword = input;
              });
            }
          },
        ),
        const Divider(),
        ListTile(
          title: const Text("重复输入新密码"),
          subtitle: Text(_newPasswordRep == "" ? "未填写" : '\u2022' * 10),
          onTap: () async {
            String? input = await displayTextInputDialog(
              context,
              src: _newPasswordRep,
              title: '重复输入新密码',
              hint: '请重复输入新密码',
              isPasswd: true,
            );
            if (input != null) {
              setState(() {
                _newPasswordRep = input;
              });
            }
          },
        ),
        const Divider(),
        Container(
          margin: const EdgeInsets.all(10),
          child: MaterialButton(
            textColor: Colors.white,
            color: Theme.of(context).appBarTheme.backgroundColor,
            onPressed: () async {
              if (_newPasswordRep != _newPassword) {
                defaultToast(context, "新密码不匹配");
                return;
              }
              setState(() {
                _loading = true;
              });
              try {
                await method.updatePassword(_oldPassword, _newPassword);
                defaultToast(context, "修改成功");
                Navigator.of(context).pop();
              } catch (e) {
                defaultToast(context, "失败 : $e");
                setState(() {
                  _loading = false;
                });
              }
            },
            child: const Text("确认"),
          ),
        ),
      ],
    );
  }
}
