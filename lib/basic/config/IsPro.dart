import 'package:event/event.dart';
import 'package:pikapika/basic/Method.dart';

var isPro = false;
var isProEx = 0;

final proEvent = Event();

Future reloadIsPro() async {
  final p = await method.isPro();
  isPro = p.isPro;
  isProEx = p.expire;
  proEvent.broadcast();
}
