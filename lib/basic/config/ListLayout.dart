/// 列表页的布局

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import '../Common.dart';
import '../Method.dart';

enum ListLayout {
  INFO_CARD,
  ONLY_IMAGE,
  COVER_AND_TITLE,
}

late ListLayout currentLayout;

Future<void> initListLayout() async {
  currentLayout = _listLayoutFromString(await method.loadProperty(
    _propertyName,
    ListLayout.INFO_CARD.toString(),
  ));
}

const _propertyName = "listLayout";

var listLayoutEvent = Event<EventArgs>();

const Map<String, ListLayout> _listLayoutMap = {
  '详情': ListLayout.INFO_CARD,
  '封面': ListLayout.ONLY_IMAGE,
  '封面+标题': ListLayout.COVER_AND_TITLE,
};

ListLayout _listLayoutFromString(String layoutString) {
  for (var value in ListLayout.values) {
    if (layoutString == value.toString()) {
      return value;
    }
  }
  return ListLayout.INFO_CARD;
}

void chooseListLayout(BuildContext context) async {
  ListLayout? layout = await chooseMapDialog(context, _listLayoutMap, '请选择布局');
  if (layout != null) {
    await method.saveProperty(_propertyName, layout.toString());
    currentLayout = layout;
    listLayoutEvent.broadcast();
  }
}

IconButton chooseLayoutAction(BuildContext context) => IconButton(
      onPressed: () {
        chooseListLayout(context);
      },
      icon: Icon(Icons.view_quilt),
    );

