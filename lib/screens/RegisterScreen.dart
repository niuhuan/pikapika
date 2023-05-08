import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
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
          throw '请检查表单, 不允许留空';
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
        message = "账号已存在";
      } else if (message.contains("name is already exist")) {
        message = "昵称已存在";
      }
      alertDialog(context, "注册失败", message);
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
          title: const Text('注册成功'),
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(child: Container()),
              const Text('您已经注册成功, 请返回登录'),
              Text('账号 : $_email'),
              Text('昵称 : $_name'),
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
        body: const ContentLoading(label: '注册中'),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('注册'),
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
            title: const Text("账号"),
            subtitle: Text(_email == "" ? "未设置" : _email),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _email,
                title: '账号',
                hint: '请输入账号',
                desc: '(小写字母+数字/登录使用)',
              );
              if (input != null) {
                setState(() {
                  _email = input;
                });
              }
            },
          ),
          ListTile(
            title: const Text("密码"),
            subtitle: Text(_password == "" ? "未设置" : '\u2022' * 10),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _password,
                title: '密码',
                hint: '请输入密码',
                desc: '(大小写字母+数字/8位或以上)',
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
            title: const Text("昵称"),
            subtitle: Text(_name == "" ? "未设置" : _name),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _name,
                title: '昵称',
                hint: '请输入昵称',
                desc: '(可使用中文/2-50字)',
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
            title: const Text("性别"),
            subtitle: Text(_genderText(_gender)),
            onTap: () async {
              String? result = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: const Text('选择您的性别'),
                    children: [
                      SimpleDialogOption(
                        child: const Text('扶她'),
                        onPressed: () {
                          Navigator.pop(context, 'bot');
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text('公'),
                        onPressed: () {
                          Navigator.pop(context, 'm');
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text('母'),
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
            title: const Text("生日"),
            subtitle: Text(_birthday),
            onTap: () async {
              DatePicker.showDatePicker(context,
                  locale: LocaleType.zh,
                  currentTime: DateTime.parse(_birthday), onConfirm: (date) {
                setState(() {
                  _birthday = formatTimeToDate(date.toString());
                });
              });
            },
          ),
          const Divider(),
          ListTile(
            title: const Text("问题1"),
            subtitle: Text(_question1 == "" ? "未设置" : _question1),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _question1,
                title: '问题1',
                hint: '请输入问题1',
              );
              if (input != null) {
                setState(() {
                  _question1 = input;
                });
              }
            },
          ),
          ListTile(
            title: const Text("回答1"),
            subtitle: Text(_answer1 == "" ? "未设置" : _answer1),
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
          ListTile(
            title: const Text("问题2"),
            subtitle: Text(_question2 == "" ? "未设置" : _question2),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _question2,
                title: '问题2',
                hint: '请输入问题2',
              );
              if (input != null) {
                setState(() {
                  _question2 = input;
                });
              }
            },
          ),
          ListTile(
            title: const Text("回答2"),
            subtitle: Text(_answer2 == "" ? "未设置" : _answer2),
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
          ListTile(
            title: const Text("问题3"),
            subtitle: Text(_question3 == "" ? "未设置" : _question3),
            onTap: () async {
              String? input = await displayTextInputDialog(
                context,
                src: _question3,
                title: '问题3',
                hint: '请输入问题3',
              );
              if (input != null) {
                setState(() {
                  _question3 = input;
                });
              }
            },
          ),
          ListTile(
            title: const Text("回答3"),
            subtitle: Text(_answer3 == "" ? "未设置" : _answer3),
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
        return "扶她";
      case "m":
        return "公";
      case "f":
        return "母";
      default:
        return "";
    }
  }
}
