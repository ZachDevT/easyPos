import os
import re

with open('lib/features/pos/widgets/payment_panel.dart', 'r') as f:
    content = f.read()

# Add _selectedCustomerId
if "int? _selectedCustomerId;" not in content:
    content = content.replace("final _tenderedController = TextEditingController();", "final _tenderedController = TextEditingController();\n  int? _selectedCustomerId;")

# Add import for customer provider
if "customer_provider.dart" not in content:
    content = content.replace("import '../providers/session_provider.dart';", "import '../providers/session_provider.dart';\nimport '../../customers/providers/customer_provider.dart';")

# Validation logic
validation = '''
    if (_selectedMethod == 'CRÉDIT' && _selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner un client pour le crédit.')));
      return;
    }
'''
content = content.replace("final db = ref.read(databaseProvider);", validation + "\n    final db = ref.read(databaseProvider);")

# Update customer credit logic inside the transaction
update_credit = '''
      // 3. Update customer credit if needed
      if (_selectedMethod == 'CRÉDIT' && _selectedCustomerId != null) {
        final customer = await (db.select(db.customers)..where((c) => c.id.equals(_selectedCustomerId!))).getSingle();
        await (db.update(db.customers)..where((c) => c.id.equals(_selectedCustomerId!))).write(
          CustomersCompanion(
            totalCredit: drift.Value(customer.totalCredit + widget.totalAmount),
          ),
        );
      }
'''
content = content.replace("    });\n\n    // 3. Clear cart", update_credit + "    });\n\n    // 4. Clear cart")

# UI for credit
ui_credit = '''
            if (_selectedMethod == 'CRÉDIT') ...[
              const Text('Client', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ref.watch(customersStreamProvider).when(
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => Text('Erreur: $e'),
                data: (customers) {
                  return DropdownButtonFormField<int>(
                    value: _selectedCustomerId,
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    hint: const Text('Sélectionner un client'),
                    items: customers.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) => setState(() => _selectedCustomerId = val),
                  );
                },
              ),
            ],
'''
content = content.replace("            if (_selectedMethod == 'ESPÈCES') ...[", ui_credit + "\n            if (_selectedMethod == 'ESPÈCES') ...[")

with open('lib/features/pos/widgets/payment_panel.dart', 'w') as f:
    f.write(content)

print("Credit sales patched!")
