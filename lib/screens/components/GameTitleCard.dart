import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pikapi/basic/Entities.dart';

import 'Images.dart';

// 游戏信息卡
class GameTitleCard extends StatelessWidget {
  final GameInfo info;

  const GameTitleCard(this.info);

  @override
  Widget build(BuildContext context) {
    double iconMargin = 20;
    double iconSize = 60;
    BorderRadius iconRadius = BorderRadius.all(Radius.circular(6));
    TextStyle titleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    TextStyle publisherStyle = TextStyle(
      color: Theme.of(context).colorScheme.secondary,
      fontSize: 12.5,
    );
    TextStyle versionStyle = TextStyle(
      fontSize: 12.5,
    );
    double platformMargin = 10;
    double platformSize = 25;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(iconMargin),
          child: ClipRRect(
            borderRadius: iconRadius,
            child: RemoteImage(
              width: iconSize,
              height: iconSize,
              fileServer: info.icon.fileServer,
              path: info.icon.path,
            ),
          ),
        ),
        Container(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(info.title, style: titleStyle),
              Text(info.publisher, style: publisherStyle),
              Text(info.version, style: versionStyle),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: iconMargin),
          // padding: EdgeInsets.only(
          //   left: platformMargin,
          //   right: platformMargin,
          // ),
          child: Column(
            children: [
              ...info.android
                  ? [
                      SvgPicture.asset(
                        'lib/assets/android.svg',
                        fit: BoxFit.contain,
                        width: platformSize,
                        height: platformSize,
                        color: Colors.green.shade500,
                      ),
                    ]
                  : [],
              Container(
                height: platformMargin,
              ),
              ...info.ios
                  ? [
                      SvgPicture.asset(
                        'lib/assets/apple.svg',
                        fit: BoxFit.contain,
                        width: platformSize,
                        height: platformSize,
                        color: Colors.grey.shade500,
                      ),
                    ]
                  : [],
            ],
          ),
        ),
      ],
    );
  }
}
