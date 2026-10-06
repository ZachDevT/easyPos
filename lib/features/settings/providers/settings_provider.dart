import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/admin_provider.dart';

class AppSettings {
  final String storeName;
  final String currency; // Base Currency (e.g. USD)
  final String receiptFooter;
  final double exchangeRate; // E.g. 2800 (1 USD = 2800 CDF)

  AppSettings({
    required this.storeName,
    required this.currency,
    required this.receiptFooter,
    required this.exchangeRate,
  });

  AppSettings copyWith({
    String? storeName, 
    String? currency, 
    String? receiptFooter,
    double? exchangeRate,
  }) {
    return AppSettings(
      storeName: storeName ?? this.storeName,
      currency: currency ?? this.currency,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      exchangeRate: exchangeRate ?? this.exchangeRate,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs)
      : super(AppSettings(
          storeName: _prefs.getString('store_name') ?? 'Yellow Pos',
          currency: _prefs.getString('currency') ?? 'USD',
          receiptFooter: _prefs.getString('receipt_footer') ?? 'Merci pour votre visite!',
          exchangeRate: _prefs.getDouble('exchange_rate') ?? 2800.0,
        ));

  Future<void> updateSettings(AppSettings newSettings) async {
    await _prefs.setString('store_name', newSettings.storeName);
    await _prefs.setString('currency', newSettings.currency);
    await _prefs.setString('receipt_footer', newSettings.receiptFooter);
    await _prefs.setDouble('exchange_rate', newSettings.exchangeRate);
    state = newSettings;
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
