import 'package:flutter/material.dart';

import '../basic/Common.dart';
import '../basic/Cross.dart';
import '../basic/Method.dart';
import 'components/ContentLoading.dart';
import 'components/ListView.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _loading = false;
  int _state = 0; // 0 输入账号，1 回答问题，2 密码已经找回
  String _email = "";
  String _question1 = "";
  String _question2 = "";
  String _question3 = "";
  String _answer1 = "回答1";
  String _answer2 = "回答2";
  String _answer3 = "回答3";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("找回密码"),
      ),
      body: _stateScreen(),
    );
  }

  Widget _stateScreen() {
    if (_loading) {
      return const ContentLoading(label: '加载中');
    }
    switch (_state) {
      case 0:
        return _inputEmailScreen();
      case 1:
        return _inputAnswerScreen();
      case 2:
        return _showNewPasswordScreen();
    }
    throw '';
  }

  Widget _inputEmailScreen() {
    return PikaListView(children: [
      ListTile(
        title: const Text("账号"),
        subtitle: Text(_email == "" ? "未设置" : _email),
        onTap: () async {
          String? input = await displayTextInputDialog(
            context,
            src: _email,
            title: '账号',
            hint: '请输入账号',
          );
          if (input != null) {
            setState(() {
              _email = input;
            });
          }
        },
      ),
      Container(
        margin: const EdgeInsets.all(10),
        color: Colors.grey.shade500.withAlpha(18),
        child: MaterialButton(
          onPressed: _confirmEmail,
          child: const Text("确认"),
        ),
      ),
    ]);
  }

  void _confirmEmail() async {
    if (_email.isEmpty) {
      defaultToast(context, "请输入账号");
      return;
    }
    try {
      setState(() {
        _loading = true;
      });
      var result = await method.forgotPassword(_email);
      _question1 = result.question1;
      _question2 = result.question2;
      _question3 = result.question3;
      _state = 1;
    } catch (e, s) {
      print("$e\n$s");
      defaultToast(context, '$e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _inputAnswerScreen() {
    return ListView(children: [
      Container(height: 10),
      ListTile(
        title: const Text("账号"),
        subtitle: Text(_email.isEmpty ? "未设置" : _email),
      ),
      Container(height: 10),
      const Divider(),
      Container(height: 10),
      ListTile(
        title: const Text("问题1"),
        subtitle: Text(_question1),
      ),
      ListTile(
        title: const Text("回答1"),
        subtitle: Text(_answer1.isEmpty ? "未设置" : _answer1),
        onTap: () async {
          String? input = await displayTextInputDialog(
            context,
            src: _answer1,
            title: '回答1',
            hint: '请输入回答1',
          );
          if (input != null) {
            setState(() {
              _answer1 = input;
            });
          }
        },
      ),
      Container(
        margin: const EdgeInsets.all(10),
        color: Colors.grey.shade500.withAlpha(18),
        child: MaterialButton(
          onPressed: () {
            _confirmAnswer(1, _answer1);
          },
          child: const Text("使用回答1找回密码"),
        ),
      ),
      Container(height: 10),
      const Divider(),
      Container(height: 10),
      ListTile(
        title: const Text("问题2"),
        subtitle: Text(_question2),
      ),
      ListTile(
        title: const Text("回答2"),
        subtitle: Text(_answer2.isEmpty ? "未设置" : _answer2),
        onTap: () async {
          String? input = await displayTextInputDialog(
            context,
            src: _answer2,
            title: '回答2',
            hint: '请输入回答2',
          );
          if (input != null) {
            setState(() {
              _answer2 = input;
            });
          }
        },
      ),
      Container(
        margin: const EdgeInsets.all(10),
        color: Colors.grey.shade500.withAlpha(18),
        child: MaterialButton(
          onPressed: () {
            _confirmAnswer(2, _answer2);
          },
          child: const Text("使用回答2找回密码"),
        ),
      ),
      Container(height: 10),
      const Divider(),
      Container(height: 10),
      ListTile(
        title: const Text("问题3"),
        subtitle: Text(_question3),
      ),
      ListTile(
        title: const Text("回答3"),
        subtitle: Text(_answer3.isEmpty ? "未设置" : _answer3),
        onTap: () async {
          String? input = await displayTextInputDialog(
            context,
            src: _answer3,
            title: '回答3',
            hint: '请输入回答3',
          );
          if (input != null) {
            setState(() {
              _answer3 = input;
            });
          }
        },
      ),
      Container(
        margin: const EdgeInsets.all(10),
        color: Colors.grey.shade500.withAlpha(18),
        child: MaterialButton(
          onPressed: () {
            _confirmAnswer(3, _answer3);
          },
          child: const Text("使用回答3找回密码"),
        ),
      ),
      /////////
      Container(height: 20),
    ]);
  }

  _confirmAnswer(int answerNo, String answer) async {
    if (answer.isEmpty) {
      defaultToast(context, "请输入答案");
      return;
    }
    try {
      setState(() {
        _loading = true;
      });
      var result = await method.resetPassword(_email, answerNo, answer);
      _password = result.password;
      _state = 2;
      defaultToast(context, "新密码正在复制到剪切板");
      copyToClipBoard(context, _password);
    } catch (e, s) {
      print("$e\n$s");
      if ("$e".contains("invalid request")) {
        defaultToast(context, '答案不正确');
      } else {
        defaultToast(context, '$e');
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _showNewPasswordScreen() {
    return ListView(children: [
      ListTile(
        title: const Text("账号"),
        subtitle: Text(_email.isEmpty ? "未设置" : _email),
      ),
      ListTile(
        title: const Text("密码"),
        subtitle: Text(_password.isEmpty ? "未设置" : _password),
        onTap: () {
          defaultToast(context, "新密码正在复制到剪切板");
          copyToClipBoard(context, _password);
        },
      ),
    ]);
  }
}
