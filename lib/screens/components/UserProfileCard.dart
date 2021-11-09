import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/screens/components/ItemBuilder.dart';
import 'package:pikapi/screens/components/Avatar.dart';
import 'package:pikapi/screens/components/Images.dart';
import 'package:pikapi/basic/Method.dart';

// 用户信息卡
class UserProfileCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserProfileCardState();
}

class _UserProfileCardState extends State<UserProfileCard> {
  late Future<UserProfile> _future = _load();

  Future<UserProfile> _load() async {
    var profile = await method.userProfile();
    if (!profile.isPunched) {
      await method.punchIn();
      profile.isPunched = true;
      defaultToast(context, "自动打卡");
    }
    return profile;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var nameStyle = TextStyle(fontWeight: FontWeight.bold);
    var levelStyle = TextStyle(
        fontSize: 12, color: theme.colorScheme.secondary.withOpacity(.8));
    return ItemBuilder(
      future: _future,
      onRefresh: () async {
        setState(() => _future = method.userProfile());
      },
      height: 150,
      successBuilder:
          (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
        UserProfile profile = snapshot.data!;
        return Stack(
          children: [
            Container(
              child: Stack(
                children: [
                  Opacity(
                    opacity: .25, //
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return RemoteImage(
                          path: profile.avatar.path,
                          fileServer: profile.avatar.fileServer,
                          width: constraints.maxWidth,
                          height: 150,
                        );
                      },
                    ),
                  ),
                  Positioned.fromRect(
                    rect: Rect.largest,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Container(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 150,
              child: Column(
                children: [
                  Expanded(child: Container()),
                  Avatar(profile.avatar),
                  Container(width: 18),
                  Text(
                    profile.name,
                    style: nameStyle,
                  ),
                  Text(
                    "Lv. ${profile.level} (${profile.title})",
                    style: levelStyle,
                  ),
                  Expanded(child: Container()),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
