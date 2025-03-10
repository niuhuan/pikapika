import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';

Future showInputModalBottomSheet({
  required BuildContext context,
  required FutureOr<dynamic> Function(String) onSubmitted,
  required String? hintText,
  String? initialValue,
}) async {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, _, __) {
        return BottomSheetInput(
          onSubmitted: onSubmitted,
          hintText: hintText,
          initialValue: initialValue,
        );
      },
    ),
  );
}

class BottomSheetInput extends StatefulWidget {
  final FutureOr<dynamic> Function(String) onSubmitted;
  final String? hintText;
  final String? initialValue;

  const BottomSheetInput({
    Key? key,
    required this.onSubmitted,
    required this.hintText,
    this.initialValue,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BottomSheetInputState();
}

class _BottomSheetInputState extends State<BottomSheetInput> {
  late TextEditingController _controller;
  bool submitting = false;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.initialValue);
    super.initState();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context);
    var size = mq.size;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Material(
        color: Colors.black.withAlpha(50),
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (!submitting) Navigator.of(context).pop();
                },
                child: Container(),
              ),
            ),
            Material(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 30,
                  bottom: 30,
                ),
                child: Column(
                  children: [
                    if (submitting)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    if (!submitting) _buildTextField(),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (!submitting) Navigator.of(context).pop();
                },
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

/*
Column(
        children: [
          SafeArea(
            child: Container(),
            bottom: false,
          ),
          Material(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 30,
                    bottom: 30,
                  ),
                  child: Column(
                    children: [
                      if (submitting)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                      if (!submitting) _buildTextField(),
                    ],
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (!submitting) Navigator.of(context).pop();
              },
              child: Container(),
            ),
          ),
        ],
      ),
      */

  Widget _buildTextField() {
    return TextField(
      controller: _controller,
      autofocus: true,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
      ),
      onSubmitted: (text) {
        _onSubmitted(text);
      },
    );
  }

  _onSubmitted(String text) async {
    setState(() {
      submitting = true;
    });
    try {
      await widget.onSubmitted(text);
      Navigator.of(context).pop();
    } catch (e, s) {
      defaultToast(context, e.toString());
    } finally {
      setState(() {
        submitting = false;
      });
    }
  }
}
