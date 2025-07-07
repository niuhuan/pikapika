import 'package:easy_localization/easy_localization.dart';
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
        title: Text(tr("screen.modify_password.title")),
      ),
      body: _loading
          ? Stack(
              children: [
                ContentLoading(label: tr("screen.modify_password.please_wait")),
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
          title: Text(tr("screen.modify_password.old_password")),
          subtitle: Text(_oldPassword == "" ? tr("screen.modify_password.not_filled") : '\u2022' * 10),
          onTap: () async {
            String? input = await displayTextInputDialog(
              context,
              src: _oldPassword,
              title: tr('screen.modify_password.old_password'),
              hint: tr('screen.modify_password.please_enter_old_password'),
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
          title: Text(tr("screen.modify_password.new_password")),
          subtitle: Text(_newPassword == "" ? tr("screen.modify_password.not_filled") : '\u2022' * 10),
          onTap: () async {
            String? input = await displayTextInputDialog(
              context,
              src: _newPassword,
              title: tr('screen.modify_password.new_password'),
              hint: tr('screen.modify_password.please_enter_new_password'),
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
          title: Text(tr("screen.modify_password.repeat_new_password")),
          subtitle: Text(_newPasswordRep == "" ? tr("screen.modify_password.not_filled") : '\u2022' * 10),
          onTap: () async {
            String? input = await displayTextInputDialog(
              context,
              src: _newPasswordRep,
              title: tr('screen.modify_password.repeat_new_password'),
              hint: tr('screen.modify_password.please_repeat_new_password'),
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
                defaultToast(context, tr("screen.modify_password.new_password_mismatch"));
                return;
              }
              setState(() {
                _loading = true;
              });
              try {
                await method.updatePassword(_oldPassword, _newPassword);
                defaultToast(context, tr("screen.modify_password.modify_success"));
                Navigator.of(context).pop();
              } catch (e) {
                defaultToast(context, "${tr('screen.modify_password.failed')} : $e");
                setState(() {
                  _loading = false;
                });
              }
            },
            child: Text(tr("screen.modify_password.confirm")),
          ),
        ),
      ],
    );
  }
}
