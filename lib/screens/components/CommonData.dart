import 'package:event/event.dart';

import '../../basic/Entities.dart';
import '../../basic/Method.dart';

final subscribedEvent = Event();

final Map<String, ComicSubscribe> allSubscribed = {};

Future updateSubscribed() async {
  await method.updateSubscribed();
  await _update();
}

Future updateSubscribedForce() async {
  await method.updateSubscribedForce();
  await _update();
}

Future _update() async {
  final _allSubscribed = await method.allSubscribed();
  allSubscribed.clear();
  for (var subscribed in _allSubscribed) {
    allSubscribed[subscribed.id] = subscribed;
  }
  subscribedEvent.broadcast();
}

Future removeAllSubscribed() async {
  await method.removeAllSubscribed();
  allSubscribed.clear();
  subscribedEvent.broadcast();
}

Future subscribedViewed(String id) async {
  if (allSubscribed.containsKey(id)) {
    allSubscribed.remove(id);
    subscribedEvent.broadcast();
  }
}
