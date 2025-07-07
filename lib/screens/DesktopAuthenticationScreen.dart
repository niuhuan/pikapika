import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/Method.dart';

const _key = "desktopAuthPassword";

Future<bool> needDesktopAuthentication() async {
  return await method.loadProperty(_key, "") != "";
}

class VerifyPassword extends StatefulWidget {
  const VerifyPassword({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VerifyPasswordState();
}

class _VerifyPasswordState extends State<VerifyPassword> {
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Expanded(child: Container()),
              TextField(
                decoration: InputDecoration(labelText: tr('screen.desktop_authentication.current_password')),
                onChanged: (value) {
                  _password = value;
                },
              ),
              Container(height: 10),
              ElevatedButton(
                onPressed: () async {
                  String savedPassword = await method.loadProperty(_key, "");
                  if (_password == savedPassword) {
                    Navigator.of(context).pop(true);
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(tr('screen.desktop_authentication.password_error'))));
                  }
                },
                child: Text(tr('app.confirm')),
              ),
              Expanded(child: Container()),
            ],
          ),
        ),
      ),
    );
  }
}

class SetPassword extends StatefulWidget {
  const SetPassword({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {
  String _password = "";
  String _password2 = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text(
                tr('screen.desktop_authentication.password_initialization'),
                style: TextStyle(
                  height: 18,
                ),
              ),
              Container(
                height: 10,
              ),
              TextField(
                decoration: InputDecoration(labelText: tr('screen.desktop_authentication.password')),
                onChanged: (value) {
                  _password = value;
                },
              ),
              Container(
                height: 10,
              ),
              TextField(
                decoration: InputDecoration(labelText: tr('screen.desktop_authentication.re_enter_password')),
                onChanged: (value) {
                  _password2 = value;
                },
              ),
              Container(
                height: 10,
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop(false);
                    },
                    child: Text(tr('app.cancel')),
                  ),
                  Container(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_password != _password2) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(tr('screen.desktop_authentication.password_mismatch'))));
                          return;
                        }
                        await method.saveProperty(_key, _password);
                        Navigator.of(context).pop(true);
                      },
                      child: Text(tr('screen.desktop_authentication.set_password')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
