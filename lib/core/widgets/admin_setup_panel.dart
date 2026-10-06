import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/admin_provider.dart';
import 'buttons.dart';

class AdminSetupPanel extends ConsumerStatefulWidget {
  const AdminSetupPanel({super.key});

  @override
  ConsumerState<AdminSetupPanel> createState() => _AdminSetupPanelState();
}

class _AdminSetupPanelState extends ConsumerState<AdminSetupPanel> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _hasError = false;

  void _savePin() async {
    final pin = _pinController.text;
    final confirm = _confirmController.text;

    if (pin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le PIN doit contenir au moins 4 chiffres')),
      );
      return;
    }

    if (pin != confirm) {
      setState(() => _hasError = true);
      return;
    }

    await ref.read(adminProvider.notifier).setPin(pin);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code PIN administrateur configuré avec succès', style: TextStyle(color: Colors.white)), backgroundColor: AppTheme.successColor),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration Initiale'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.admin_panel_settings, size: 80, color: AppTheme.primaryColor),
            const SizedBox(height: 24),
            Text(
              'Créer le Code PIN Admin',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ce code PIN sera requis pour ajouter/modifier/supprimer des produits et pour modifier les paramètres.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Nouveau Code PIN (4-6 chiffres)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Confirmer le Code PIN',
                errorText: _hasError ? 'Les codes ne correspondent pas' : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: 'Enregistrer le PIN',
                icon: Icons.save,
                onPressed: _savePin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
