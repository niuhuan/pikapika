import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';

class ContinueReadButton extends StatefulWidget {
  final Future<ViewLog?> viewFuture;
  final Function(int? epOrder, int? pictureRank) onChoose;

  const ContinueReadButton({
    Key? key,
    required this.viewFuture,
    required this.onChoose,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContinueReadButtonState();
}

class _ContinueReadButtonState extends State<ContinueReadButton> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var width = constraints.maxWidth;
        return FutureBuilder(
          future: widget.viewFuture,
          builder: (BuildContext context, AsyncSnapshot<ViewLog?> snapshot) {
            late void Function() onPressed;
            late String text;
            if (snapshot.connectionState != ConnectionState.done) {
              onPressed = () {};
              text = '加载中';
            }
            if (snapshot.data != null && snapshot.data!.lastViewEpOrder > 0) {
              onPressed = () => widget.onChoose(
                    snapshot.data?.lastViewEpOrder,
                    snapshot.data?.lastViewPictureRank,
                  );
              text =
                  '继续阅读 ${snapshot.data?.lastViewEpTitle} P. ${snapshot.data?.lastViewPictureRank}';
            } else {
              onPressed = () => widget.onChoose(null, null);
              text = '开始阅读';
            }
            return Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              margin: EdgeInsets.only(bottom: 10),
              width: width,
              child: MaterialButton(
                onPressed: onPressed,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .color!
                            .withOpacity(.05),
                        padding: EdgeInsets.all(10),
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
