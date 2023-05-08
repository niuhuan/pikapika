import 'package:flutter/material.dart';
import 'package:pikapika/basic/config/EBookScrolling.dart';

import '../../basic/config/EBookScrollingRange.dart';
import '../../basic/config/EBookScrollingTrigger.dart';

class PikaListView extends StatefulWidget {
  final EdgeInsets? padding;
  final ScrollController? controller;
  final List<Widget> children;
  final ScrollPhysics? physics;

  const PikaListView({
    Key? key,
    required this.children,
    this.controller,
    this.padding,
    this.physics,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PikaListViewState();
}

class _PikaListViewState extends State<PikaListView> {
  late ScrollController _privateController;

  @override
  void initState() {
    if (widget.controller == null) {
      _privateController = ScrollController();
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _privateController.dispose();
    }
    super.dispose();
  }

  ScrollController get _controller => widget.controller ?? _privateController;
  double _y = 0;

  @override
  Widget build(BuildContext context) {
    if (!eBookScrolling) {
      return ListView(
        children: widget.children,
        controller: _controller,
        padding: widget.padding,
        physics: widget.physics,
      );
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return GestureDetector(
          onPanDown: (details) {
            _y = 0;
          },
          onPanUpdate: (details) {
            _y += details.delta.dy;
          },
          onPanEnd: (details) {
            final lmPoints =
                (MediaQuery.of(context).devicePixelRatio * (160 / 2.54));
            final double centimeters = _y / lmPoints;
            late double off;
            if (centimeters < -eBookScrollingTrigger) {
              off = _controller.offset +
                  eBookScrollingRange * constraints.maxHeight;
              off = off.clamp(0, _controller.position.maxScrollExtent);
              _controller.jumpTo(off);
              _controller.notifyListeners();
            } else if (centimeters > eBookScrollingTrigger) {
              off = _controller.offset -
                  eBookScrollingRange * constraints.maxHeight;
              off = off.clamp(0, _controller.position.maxScrollExtent);
              _controller.jumpTo(off);
              _controller.notifyListeners();
            }
          },
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: widget.children,
            controller: _controller,
            padding: widget.padding,
          ),
        );
      },
    );
  }
}
