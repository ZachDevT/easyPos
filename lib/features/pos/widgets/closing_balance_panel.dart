import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_provider.dart';
import '../providers/session_provider.dart';

class ClosingBalancePanel extends ConsumerStatefulWidget {
  const ClosingBalancePanel({super.key});

  @override
  ConsumerState<ClosingBalancePanel> createState() => _ClosingBalancePanelState();
}

class _ClosingBalancePanelState extends ConsumerState<ClosingBalancePanel> {
  final _actualCashController = TextEditingController();
  double _expectedCash = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateExpectedCash();
  }

  @override
  void dispose() {
    _actualCashController.dispose();
    super.dispose();
  }

  Future<void> _calculateExpectedCash() async {
    final sessionAsync = ref.read(activeSessionProvider);
    final session = sessionAsync.valueOrNull;
    
    if (session == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final db = ref.read(databaseProvider);
    
    // Get all sales for this session that were paid in cash
    final cashSalesResult = await (db.select(db.sales)
      ..where((s) => s.sessionId.equals(session.id))
      ..where((s) => s.paymentMethod.equals('ESPÈCES'))
    ).get();

    final cashSalesTotal = cashSalesResult.fold<double>(0, (sum, sale) => sum + sale.total);
    
    setState(() {
      _expectedCash = session.openingBalance + cashSalesTotal;
      _isLoading = false;
    });
  }

  Future<void> _closeRegister() async {
    final sessionAsync = ref.read(activeSessionProvider);
    final session = sessionAsync.valueOrNull;
    
    if (session == null) return;

    final actualCash = double.tryParse(_actualCashController.text) ?? 0.0;
    final db = ref.read(databaseProvider);

    await (db.update(db.cashSessions)..where((s) => s.id.equals(session.id))).write(
      CashSessionsCompanion(
        closedAt: drift.Value(DateTime.now()),
        closingBalance: drift.Value(actualCash),
        status: const drift.Value('CLOSED'),
      ),
    );

    ref.invalidate(activeSessionProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caisse clôturée avec succès.'), backgroundColor: AppTheme.successColor),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final session = ref.read(activeSessionProvider).valueOrNull;

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Clôturer la caisse')),
        body: const Center(child: Text('Aucune caisse ouverte.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clôturer la caisse'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Récapitulatif de la session',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Fond de caisse initial', '${session.openingBalance} CDF'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(),
                  ),
                  _buildSummaryRow('Total des ventes en espèces', '${_expectedCash - session.openingBalance} CDF'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(),
                  ),
                  _buildSummaryRow(
                    'Espèces attendues en caisse', 
                    '$_expectedCash CDF', 
                    isBold: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            const Text(
              'Montant compté',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Veuillez compter physiquement les billets et pièces dans le tiroir-caisse et saisir le montant total.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _actualCashController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Montant réel en caisse (CDF)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
              ),
              style: const TextStyle(fontSize: 24),
            ),
            
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: 'Clôturer la caisse',
                icon: Icons.lock,
                onPressed: _closeRegister,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label, 
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.black : Colors.grey[700],
          )
        ),
        Text(
          value, 
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? AppTheme.primaryColor : Colors.black,
          )
        ),
      ],
    );
  }
}
