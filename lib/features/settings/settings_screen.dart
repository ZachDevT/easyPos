import 'package:shared_preferences/shared_preferences.dart' as shared_preferences;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons.dart';
import 'providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _storeNameController;
  late TextEditingController _currencyController;
  late TextEditingController _exchangeRateController;
  late TextEditingController _footerController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _storeNameController = TextEditingController(text: settings.storeName);
    _currencyController = TextEditingController(text: settings.currency);
    _exchangeRateController = TextEditingController(text: settings.exchangeRate.toString());
    _footerController = TextEditingController(text: settings.receiptFooter);
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _currencyController.dispose();
    _exchangeRateController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    ref.read(settingsProvider.notifier).updateSettings(
      AppSettings(
        storeName: _storeNameController.text,
        currency: _currencyController.text,
        exchangeRate: double.tryParse(_exchangeRateController.text) ?? 2800.0,
        receiptFooter: _footerController.text,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paramètres enregistrés avec succès.'), backgroundColor: AppTheme.successColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paramètres du système',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField('Nom de la boutique', _storeNameController),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Devise principale (ex: USD)', _currencyController)),
                          const SizedBox(width: 24),
                          Expanded(child: _buildTextField('Taux de change (ex: 2800 FC)', _exchangeRateController)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildTextField('Message de pied de page (Reçu)', _footerController, maxLines: 2),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          text: 'Enregistrer les modifications',
                          icon: Icons.save,
                          onPressed: _saveSettings,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          label: const Text('Effacer toutes les données locales (Réinitialiser)', style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Confirmation'),
                                content: const Text('Voulez-vous vraiment effacer toutes les données locales ? Cela vous déconnectera et vous devrez vous reconnecter.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Effacer', style: TextStyle(color: Colors.red))),
                                ],
                              )
                            );
                            if (confirm == true) {
                              final prefs = await shared_preferences.SharedPreferences.getInstance();
                              await prefs.clear();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Données locales effacées. Veuillez redémarrer l\'application.')));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
