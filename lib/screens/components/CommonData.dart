import 'package:event/event.dart';

import '../../basic/Entities.dart';
import '../../basic/Method.dart';

final subscribedEvent = Event();

final Map<String, ComicSubscribe> allSubscribed = {};

Future updateSubscribed() async {
  await method.updateSubscribed();
  final _allSubscribed = await method.allSubscribed();
  allSubscribed.clear();
  for (var subscribed in _allSubscribed) {
    allSubscribed[subscribed.id] = subscribed;
  }
  subscribedEvent.broadcast();
}
