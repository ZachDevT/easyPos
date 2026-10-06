import re

def insert_currency(file, methods):
    with open(file, 'r') as f:
        content = f.read()
    
    for m in methods:
        pattern = m.replace('(', r'\(').replace(')', r'\)') + r'\s*\{'
        replacement = m + ' {\n    final currency = ref.watch(settingsProvider).currency;'
        content = re.sub(pattern, replacement, content)
        
    with open(file, 'w') as f:
        f.write(content)

# pos_screen.dart
insert_currency('lib/features/pos/pos_screen.dart', [
    'Widget _buildProductGrid(BuildContext context, WidgetRef ref)',
    'Widget _buildCartItems(BuildContext context, WidgetRef ref)',
    'Widget _buildCartSummary(BuildContext context, WidgetRef ref)'
])
with open('lib/features/pos/pos_screen.dart', 'r') as f:
    content = f.read()
content = content.replace("const Row(\n            mainAxisAlignment: MainAxisAlignment.spaceBetween,\n            children: [\n              Text('Réduction:', style: TextStyle(color: Colors.grey)),\n              Text('0 $currency', style: TextStyle(fontWeight: FontWeight.bold)),", "Row(\n            mainAxisAlignment: MainAxisAlignment.spaceBetween,\n            children: [\n              Text('Réduction:', style: TextStyle(color: Colors.grey)),\n              Text('0 $currency', style: TextStyle(fontWeight: FontWeight.bold)),")
with open('lib/features/pos/pos_screen.dart', 'w') as f: f.write(content)

# payment_panel.dart
with open('lib/features/pos/widgets/payment_panel.dart', 'r') as f:
    content = f.read()
content = content.replace("final currency = ref.watch(settingsProvider).currency;\n", "")
content = content.replace("Widget build(BuildContext context) {", "Widget build(BuildContext context) {\n    final currency = ref.watch(settingsProvider).currency;")
content = content.replace("Widget _buildChangeDue() {", "Widget _buildChangeDue() {\n    final currency = ref.watch(settingsProvider).currency;")
content = content.replace("const Text('Montant reçu ($currency)'", "Text('Montant reçu ($currency)'")
with open('lib/features/pos/widgets/payment_panel.dart', 'w') as f: f.write(content)

