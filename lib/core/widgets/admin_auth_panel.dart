import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/admin_provider.dart';
import 'buttons.dart';

class AdminAuthPanel extends ConsumerStatefulWidget {
  final String title;

  const AdminAuthPanel({super.key, this.title = 'Authentification Admin'});

  @override
  ConsumerState<AdminAuthPanel> createState() => _AdminAuthPanelState();
}

class _AdminAuthPanelState extends ConsumerState<AdminAuthPanel> {
  final _pinController = TextEditingController();
  bool _hasError = false;

  void _verify() {
    final notifier = ref.read(adminProvider.notifier);
    
    // If no pin configured yet, it's considered valid or we show an error.
    // In a real flow, if no PIN is set, they should be prompted to create one first.
    if (!notifier.hasPin) {
      Navigator.of(context).pop(true);
      return;
    }

    if (notifier.verifyPin(_pinController.text)) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _hasError = true);
      _pinController.clear();
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
            const Icon(Icons.security, size: 80, color: AppTheme.primaryColor),
            const SizedBox(height: 24),
            Text(
              'Code PIN Requis',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Cette action nécessite des privilèges d\'administrateur. Veuillez entrer votre code PIN.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '••••',
                errorText: _hasError ? 'Code PIN incorrect' : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _verify(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: 'Vérifier',
                icon: Icons.check,
                onPressed: _verify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
