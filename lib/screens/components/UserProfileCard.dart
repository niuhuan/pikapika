import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/components/Avatar.dart';
import 'package:pikapika/screens/components/Images.dart';
import 'package:pikapika/screens/components/ItemBuilder.dart';

const double _cardHeight = 180;

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
    var nameStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
    var nameStrutStyle = StrutStyle(
      fontSize: 14,
      forceStrutHeight: true,
      fontWeight: FontWeight.bold,
    );
    var levelStyle = TextStyle(
      fontSize: 12,
      color: theme.colorScheme.secondary.withOpacity(.9),
      fontWeight: FontWeight.bold,
    );
    var levelStrutStyle = StrutStyle(
      fontSize: 12,
      forceStrutHeight: true,
      fontWeight: FontWeight.bold,
    );
    var sloganStyle = TextStyle(
      fontSize: 10,
      color: theme.textTheme.bodyText1?.color?.withOpacity(.5),
    );
    var sloganStrutStyle = StrutStyle(
      fontSize: 10,
      forceStrutHeight: true,
    );
    return ItemBuilder(
      future: _future,
      onRefresh: () async {
        setState(() => _future = method.userProfile());
      },
      height: _cardHeight,
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
                          height: _cardHeight,
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
              height: _cardHeight,
              child: Column(
                children: [
                  Expanded(child: Container()),
                  Avatar(profile.avatar, size: 65),
                  Container(height: 5),
                  Text(
                    profile.name,
                    style: nameStyle,
                    strutStyle: nameStrutStyle,
                  ),
                  Text(
                    "Lv. ${profile.level} (${profile.title})",
                    style: levelStyle,
                    strutStyle: levelStrutStyle,
                  ),
                  Container(height: 8),
                  GestureDetector(
                    onTap: () async {
                      var input = await inputString(
                        context,
                        "更新签名",
                        defaultValue: profile.slogan ?? "",
                      );
                      if (input != null) {
                        await method.updateSlogan(input);
                        setState(() {
                          _future = _load();
                        });
                      }
                    },
                    child: Text(
                      profile.slogan == null || profile.slogan!.isEmpty
                          ? "这个人很懒, 什么也没留下"
                          : profile.slogan!,
                      style: sloganStyle,
                      strutStyle: sloganStrutStyle,
                    ),
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
