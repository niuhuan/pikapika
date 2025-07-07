import 'package:pikapika/basic/Method.dart';

const _propertyName = "passed";
late bool _passed;

Future<void> initPassed() async {
  _passed = (await method.loadProperty(_propertyName, "false")) == "true";
}

bool currentPassed() {
  return _passed;
}

Future<void> firstPassed() async {
  await method.saveProperty(_propertyName, "true");
}
