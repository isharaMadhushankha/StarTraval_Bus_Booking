import 'dart:async';

class SeatTimeoutHandler {
  Timer? _timer;
  final Duration timeout = const Duration(minutes: 5);

  void startTimeout(Function onTimeout) {
    _timer?.cancel();
    _timer = Timer(timeout, () {
      onTimeout();
    });
  }

  void cancel() {
    _timer?.cancel();
  }
}
