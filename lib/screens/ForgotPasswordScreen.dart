import 'package:pikapika/i18.dart';
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
  String _answer1 = "";
  String _answer2 = "";
  String _answer3 = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("screen.forgot_password.title")),
      ),
      body: _stateScreen(),
    );
  }

  Widget _stateScreen() {
    if (_loading) {
      return ContentLoading(label: tr('app.loading'));
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
        title: Text(tr("screen.forgot_password.username")),
        subtitle: Text(_email == "" ? tr("screen.forgot_password.not_set") : _email),
        onTap: () async {
          String? input = await displayTextInputDialog(
            context,
            src: _email,
            title: tr('screen.forgot_password.username'),
            hint: tr('screen.forgot_password.please_enter_username'),
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
          child: Text(tr("screen.forgot_password.confirm")),
        ),
      ),
    ]);
  }

  void _confirmEmail() async {
    if (_email.isEmpty) {
      defaultToast(context, tr("screen.forgot_password.please_enter_username"));
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
        title: Text(tr("screen.forgot_password.username")),
        subtitle: Text(_email.isEmpty ? tr("screen.forgot_password.not_set") : _email),
      ),
      Container(height: 10),
      const Divider(),
      Container(height: 10),
      ListTile(
        title: Text(tr("screen.forgot_password.question_1")),
        subtitle: Text(_question1),
      ),
      ListTile(
        title: Text(tr("screen.forgot_password.answer_1")),
        subtitle: Text(_answer1.isEmpty ? tr("screen.forgot_password.not_set") : _answer1),
        onTap: () async {
          String? input = await displayTextInputDialog(
            context,
            src: _answer1,
            title: tr('screen.forgot_password.answer_1'),
            hint: tr('screen.forgot_password.please_enter_answer_1'),
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
          child: Text(tr("screen.forgot_password.use_answer_1_recover")),
        ),
      ),
      Container(height: 10),
      const Divider(),
      Container(height: 10),
      ListTile(
        title: Text(tr("screen.forgot_password.question_2")),
        subtitle: Text(_question2),
      ),
      ListTile(
        title: Text(tr("screen.forgot_password.answer_2")),
        subtitle: Text(_answer2.isEmpty ? tr("screen.forgot_password.not_set") : _answer2),
        onTap: () async {
          String? input = await displayTextInputDialog(
            context,
            src: _answer2,
            title: tr('screen.forgot_password.answer_2'),
            hint: tr('screen.forgot_password.please_enter_answer_2'),
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
          child: Text(tr("screen.forgot_password.use_answer_2_recover")),
        ),
      ),
      Container(height: 10),
      const Divider(),
      Container(height: 10),
      ListTile(
        title: Text(tr("screen.forgot_password.question_3")),
        subtitle: Text(_question3),
      ),
      ListTile(
        title: Text(tr("screen.forgot_password.answer_3")),
        subtitle: Text(_answer3.isEmpty ? tr("screen.forgot_password.not_set") : _answer3),
        onTap: () async {
          String? input = await displayTextInputDialog(
            context,
            src: _answer3,
            title: tr('screen.forgot_password.answer_3'),
            hint: tr('screen.forgot_password.please_enter_answer_3'),
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
          child: Text(tr("screen.forgot_password.use_answer_3_recover")),
        ),
      ),
      /////////
      Container(height: 20),
    ]);
  }

  _confirmAnswer(int answerNo, String answer) async {
    if (answer.isEmpty) {
      defaultToast(context, tr("screen.forgot_password.please_enter_answer"));
      return;
    }
    try {
      setState(() {
        _loading = true;
      });
      var result = await method.resetPassword(_email, answerNo, answer);
      _password = result.password;
      _state = 2;
      defaultToast(context, tr("screen.forgot_password.new_password_copied"));
      copyToClipBoard(context, _password);
    } catch (e, s) {
      print("$e\n$s");
      if ("$e".contains("invalid request")) {
        defaultToast(context, tr('screen.forgot_password.answer_incorrect'));
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
        title: Text(tr("screen.forgot_password.username")),
        subtitle: Text(_email.isEmpty ? tr("screen.forgot_password.not_set") : _email),
      ),
      ListTile(
        title: Text(tr("screen.forgot_password.password")),
        subtitle: Text(_password.isEmpty ? tr("screen.forgot_password.not_set") : _password),
        onTap: () {
          defaultToast(context, tr("screen.forgot_password.new_password_copied"));
          copyToClipBoard(context, _password);
        },
      ),
    ]);
  }
}
