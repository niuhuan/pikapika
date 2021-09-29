import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

var _eventChannel = EventChannel("flatEvent");
StreamSubscription? _eventChannelListen;

Map<void Function(String args), String> _eventMap = {};

void registerEvent(void Function(String args) eventHandler, String eventName) {
  if (_eventMap.containsKey(eventHandler)) {
    throw 'once register';
  }
  _eventMap[eventHandler] = eventName;
  if (_eventMap.length == 1) {
    _eventChannelListen =
        _eventChannel.receiveBroadcastStream().listen(_onFlatEvent);
  }
}

void unregisterEvent(void Function(String args) eventHandler) {
  if (!_eventMap.containsKey(eventHandler)) {
    throw 'no register';
  }
  _eventMap.remove(eventHandler);
  if (_eventMap.length == 0) {
    _eventChannelListen?.cancel();
  }
}

void _onFlatEvent(dynamic t) {
  _FlatEvent e = _FlatEvent.fromJson(jsonDecode(t));
  _eventMap.forEach((key, value) {
    if (value == e.function) {
      key(e.content);
    }
  });
}

class _FlatEvent {
  late String function;
  late String content;

  _FlatEvent.fromJson(Map<String, dynamic> json) {
    this.function = json["function"];
    this.content = json["content"];
  }
}
