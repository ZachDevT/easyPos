import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_provider.dart';
import '../../settings/providers/settings_provider.dart';

class OpeningBalanceDialog extends ConsumerStatefulWidget {
  const OpeningBalanceDialog({super.key});

  @override
  ConsumerState<OpeningBalanceDialog> createState() => _OpeningBalanceDialogState();
}

class _OpeningBalanceDialogState extends ConsumerState<OpeningBalanceDialog> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _openRegister() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    
    final db = ref.read(databaseProvider);
    
    await db.into(db.cashSessions).insert(
      CashSessionsCompanion.insert(
        openedAt: DateTime.now(),
        openingBalance: amount,
        status: const drift.Value('OPEN'),
      ),
    );

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(settingsProvider).currency;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.point_of_sale, size: 32, color: AppTheme.primaryColor),
            const SizedBox(width: 16),
            Text('Ouvrir la caisse'),
          ],
        ),
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
            const Text(
              'Veuillez entrer le fond de caisse initial pour commencer la journée.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Fond de caisse ($currency)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.payments_outlined),
              ),
              style: const TextStyle(fontSize: 24),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Annuler', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 16),
                PrimaryButton(
                  text: 'Ouvrir',
                  icon: Icons.check,
                  onPressed: _openRegister,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
