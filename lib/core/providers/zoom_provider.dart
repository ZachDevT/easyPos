import 'package:flutter_riverpod/flutter_riverpod.dart';

final zoomProvider = StateNotifierProvider<ZoomNotifier, double>((ref) {
  return ZoomNotifier();
});

class ZoomNotifier extends StateNotifier<double> {
  ZoomNotifier() : super(1.0);

  void zoomIn() {
    if (state < 1.5) state += 0.05;
  }

  void zoomOut() {
    if (state > 0.8) state -= 0.05;
  }

  void reset() => state = 1.0;
}
