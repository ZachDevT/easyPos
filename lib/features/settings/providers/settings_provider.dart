import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/admin_provider.dart';

class AppSettings {
  final String storeName;
  final String currency;
  final String receiptFooter;

  AppSettings({
    required this.storeName,
    required this.currency,
    required this.receiptFooter,
  });

  AppSettings copyWith({String? storeName, String? currency, String? receiptFooter}) {
    return AppSettings(
      storeName: storeName ?? this.storeName,
      currency: currency ?? this.currency,
      receiptFooter: receiptFooter ?? this.receiptFooter,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs)
      : super(AppSettings(
          storeName: _prefs.getString('store_name') ?? 'EasyPOS',
          currency: _prefs.getString('currency') ?? 'CDF',
          receiptFooter: _prefs.getString('receipt_footer') ?? 'Merci pour votre visite!',
        ));

  Future<void> updateSettings(AppSettings newSettings) async {
    await _prefs.setString('store_name', newSettings.storeName);
    await _prefs.setString('currency', newSettings.currency);
    await _prefs.setString('receipt_footer', newSettings.receiptFooter);
    state = newSettings;
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
