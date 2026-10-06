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
  late TextEditingController _footerController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _storeNameController = TextEditingController(text: settings.storeName);
    _currencyController = TextEditingController(text: settings.currency);
    _footerController = TextEditingController(text: settings.receiptFooter);
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _currencyController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    ref.read(settingsProvider.notifier).updateSettings(
      AppSettings(
        storeName: _storeNameController.text,
        currency: _currencyController.text,
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
                      _buildTextField('Devise principale (ex: CDF, USD)', _currencyController),
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
