import 'package:flutter/material.dart';
import 'package:pikapika/basic/Entities.dart';
import 'Images.dart';

const double _avatarMargin = 5;
const double _avatarBorderSize = 1.5;

// 头像
class Avatar extends StatelessWidget {
  final RemoteImageInfo avatarImage;
  final double size;

  const Avatar(this.avatarImage, {this.size = 50});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.all(_avatarMargin),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.secondary,
            style: BorderStyle.solid,
            width: _avatarBorderSize,
          )),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(this.size)),
        child: RemoteImage(
          fileServer: this.avatarImage.fileServer,
          path: this.avatarImage.path,
          width: this.size,
          height: this.size,
        ),
      ),
    );
  }
}
