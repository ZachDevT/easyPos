import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class AdminNotifier extends StateNotifier<String?> {
  final SharedPreferences _prefs;

  AdminNotifier(this._prefs) : super(_prefs.getString('admin_pin'));

  Future<void> setPin(String pin) async {
    await _prefs.setString('admin_pin', pin);
    state = pin;
  }

  bool verifyPin(String pin) {
    return state == pin;
  }
  
  bool get hasPin => state != null;
}

final adminProvider = StateNotifierProvider<AdminNotifier, String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AdminNotifier(prefs);
});
