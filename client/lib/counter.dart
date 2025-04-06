import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';

int useCounter({int initialValue = 0}) {
  final counter = useState(initialValue);

  useEffect(() {
    final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      counter.value++;
    });
    return () {
      timer.cancel();
      print("Timer disposed"); // tmp
    };
  }, []);

  return counter.value;
}
