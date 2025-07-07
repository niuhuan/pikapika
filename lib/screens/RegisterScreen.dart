import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/components/NetworkSetting.dart';
import 'package:pikapika/screens/components/RightClickPop.dart';

import 'components/ContentLoading.dart';
import 'components/ListView.dart';

/// 注册页面
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late bool _registering = false;
  late bool _registerOver = false;

  late String _email = "";
  late String _name = "";
  late String _password = "";
  late String _gender = "bot";
  late String _birthday = "2000-01-01";
  late String _question1 = "问题1";
  late String _answer1 = "回答1";
  late String _question2 = "问题2";
  late String _answer2 = "回答2";
  late String _question3 = "问题3";
  late String _answer3 = "回答3";

  Future _register() async {
    setState(() {
      _registering = true;
    });
    try {
      var mustList = <String>[
        _email,
        _name,
        _password,
        _gender,
        _birthday,
        _question1,
        _answer1,
        _question2,
        _answer2,
        _question3,
        _answer3,
      ];
      for (var a in mustList) {
        if (a.isEmpty) {
          throw tr('screen.register.check_form');
        }
      }
      await method.register(
        _email,
        _name,
        _password,
        _gender,
        _birthday,
        _question1,
        _answer1,
        _question2,
        _answer2,
        _question3,
        _answer3,
      );
      await method.setUsername(_email);
      await method.setPassword(_password);
      await method.clearToken();
      setState(() {
        _registerOver = true;
      });
    } catch (e) {
      String message = "$e";
      if (message.contains("email is already exist")) {
        message = tr('screen.register.account_exists');
      } else if (message.contains("name is already exist")) {
        message = tr('screen.register.name_exists');
      }
      alertDialog(context, tr('screen.register.register_failed'), message);
    } finally {
      setState(() {
        _registering = false;
      });
    }
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
    if (_registerOver) {
      return Scaffold(
        appBar: AppBar(
          title: Text(tr('screen.register.register_success')),
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(child: Container()),
              Text(tr('screen.register.register_success_desc')),
              Text('${tr('screen.register.account_label')} : $_email'),
              Text('${tr('screen.register.nickname_label')} : $_name'),
              Expanded(child: Container()),
              Expanded(child: Container()),
            ],
          ),
        ),
      );
    }
    if (_registering) {
      return Scaffold(
        appBar: AppBar(),
        body: ContentLoading(label: tr('screen.register.registering')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('screen.register.title')),
        actions: [
          IconButton(
            onPressed: () => _register(),
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: PikaListView(
        children: [
          const Divider(),
          ListTile(
            title: Text(tr('screen.register.account')),
            subtitle: Text(_email == "" ? tr('screen.register.not_set') : _email),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _email,
                title: tr('screen.register.account'),
                hint: tr('screen.register.please_enter_account'),
                desc: tr('screen.register.account_desc'),
              );
              if (input != null) {
                setState(() {
                  _email = input;
                });
              }
            },
          ),
          ListTile(
            title: Text(tr('screen.register.password')),
            subtitle: Text(_password == "" ? tr('screen.register.not_set') : '\u2022' * 10),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _password,
                title: tr('screen.register.password'),
                hint: tr('screen.register.please_enter_password'),
                desc: tr('screen.register.password_desc'),
                isPasswd: true,
              );
              if (input != null) {
                setState(() {
                  _password = input;
                });
              }
            },
          ),
          ListTile(
            title: Text(tr('screen.register.nickname')),
            subtitle: Text(_name == "" ? tr('screen.register.not_set') : _name),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _name,
                title: tr('screen.register.nickname'),
                hint: tr('screen.register.please_enter_nickname'),
                desc: tr('screen.register.nickname_desc'),
              );
              if (input != null) {
                setState(() {
                  _name = input;
                });
              }
            },
          ),
          const Divider(),
          ListTile(
            title: Text(tr('screen.register.gender')),
            subtitle: Text(_genderText(_gender)),
            onTap: () async {
              String? result = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: Text(tr('screen.register.choose_gender')),
                    children: [
                      SimpleDialogOption(
                        child: Text(tr('screen.register.futa')),
                        onPressed: () {
                          Navigator.pop(context, 'bot');
                        },
                      ),
                      SimpleDialogOption(
                        child: Text(tr('screen.register.male')),
                        onPressed: () {
                          Navigator.pop(context, 'm');
                        },
                      ),
                      SimpleDialogOption(
                        child: Text(tr('screen.register.female')),
                        onPressed: () {
                          Navigator.pop(context, 'f');
                        },
                      ),
                    ],
                  );
                },
              );
              if (result != null) {
                setState(() {
                  _gender = result;
                });
              }
            },
          ),
          ListTile(
            title: Text(tr('screen.register.birthday')),
            subtitle: Text(_birthday),
          ),
          const Divider(),
          ListTile(
            title: Text(tr('screen.register.question_1')),
            subtitle: Text(_question1 == "" ? tr('screen.register.not_set') : _question1),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _question1,
                title: tr('screen.register.question_1'),
                hint: tr('screen.register.please_enter_question_1'),
              );
              if (input != null) {
                setState(() {
                  _question1 = input;
                });
              }
            },
          ),
          ListTile(
            title: Text(tr('screen.register.answer_1')),
            subtitle: Text(_answer1 == "" ? tr('screen.register.not_set') : _answer1),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _answer1,
                title: tr('screen.register.answer_1'),
                hint: tr('screen.register.please_enter_answer_1'),
              );
              if (input != null) {
                setState(() {
                  _answer1 = input;
                });
              }
            },
          ),
          ListTile(
            title: Text(tr('screen.register.question_2')),
            subtitle: Text(_question2 == "" ? tr('screen.register.not_set') : _question2),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _question2,
                title: tr('screen.register.question_2'),
                hint: tr('screen.register.please_enter_question_2'),
              );
              if (input != null) {
                setState(() {
                  _question2 = input;
                });
              }
            },
          ),
          ListTile(
            title: Text(tr('screen.register.answer_2')),
            subtitle: Text(_answer2 == "" ? tr('screen.register.not_set') : _answer2),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _answer2,
                title: tr('screen.register.answer_2'),
                hint: tr('screen.register.please_enter_answer_2'),
              );
              if (input != null) {
                setState(() {
                  _answer2 = input;
                });
              }
            },
          ),
          ListTile(
            title: Text(tr('screen.register.question_3')),
            subtitle: Text(_question3 == "" ? tr('screen.register.not_set') : _question3),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _question3,
                title: tr('screen.register.question_3'),
                hint: tr('screen.register.please_enter_question_3'),
              );
              if (input != null) {
                setState(() {
                  _question3 = input;
                });
              }
            },
          ),
          ListTile(
            title: Text(tr('screen.register.answer_3')),
            subtitle: Text(_answer3 == "" ? tr('screen.register.not_set') : _answer3),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _answer3,
                title: tr('screen.register.answer_3'),
                hint: tr('screen.register.please_enter_answer_3'),
              );
              if (input != null) {
                setState(() {
                  _answer3 = input;
                });
              }
            },
          ),
          const Divider(),
          const NetworkSetting(),
          const Divider(),
        ],
      ),
    );
  }

  String _genderText(String gender) {
    switch (gender) {
      case 'bot':
        return tr('screen.register.futa');
      case "m":
        return tr('screen.register.male');
      case "f":
        return tr('screen.register.female');
      default:
        return "";
    }
  }
}
