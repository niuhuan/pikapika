import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

// EventChannel
// 由于Flutter的EventChannel只能订阅一次, 且为了和golang的的通信, 这里实现了多次订阅的分发和平铺
// 根据eventName订阅和取消订阅

var _eventChannel = const EventChannel("flatEvent");
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
  if (_eventMap.isEmpty) {
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
