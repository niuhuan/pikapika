import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Method.dart';
import '../FilePhotoViewScreen.dart';
import 'Images.dart';

const double _avatarMargin = 5;
const double _avatarBorderSize = 1.5;

// 头像
class PicaAvatar extends StatefulWidget {
  final PicaImage avatarImage;
  final double size;

  const PicaAvatar(this.avatarImage, {this.size = 50});

  @override
  State<StatefulWidget> createState() => _PicaAvatarState();
}

class _PicaAvatarState extends State<PicaAvatar> {
  late Future<String> _future = _load();

  Future<String> _load() async {
    if (widget.avatarImage.fileServer == '') {
      return '';
    }
    return method
        .remoteImageData(widget.avatarImage.fileServer, widget.avatarImage.path)
        .then((value) => value.finalPath);
  }

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
        borderRadius: BorderRadius.all(Radius.circular(widget.size)),
        child: _image(),
      ),
    );
  }

  Widget _image() {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasError) {
          return buildError(widget.size, widget.size);
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return buildLoading(widget.size, widget.size);
        }
        if (snapshot.data == '' || snapshot.data == null) {
          return buildMock(widget.size, widget.size);
        }
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => FilePhotoViewScreen(snapshot.data!),
            ));
          },
          child: buildFile(snapshot.data!, widget.size, widget.size),
        );
      },
    );
  }
}
