import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/database.dart';

class AddCustomerPanel extends ConsumerStatefulWidget {
  const AddCustomerPanel({super.key});

  @override
  ConsumerState<AddCustomerPanel> createState() => _AddCustomerPanelState();
}

class _AddCustomerPanelState extends ConsumerState<AddCustomerPanel> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveCustomer() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final db = ref.read(databaseProvider);
    await db.into(db.customers).insert(
      CustomersCompanion.insert(
        name: name,
        phone: drift.Value(_phoneController.text),
        email: drift.Value(_emailController.text),
        address: drift.Value(_addressController.text),
      ),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Client'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PrimaryButton(
              text: 'Enregistrer',
              icon: Icons.save,
              onPressed: _saveCustomer,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Informations principales'),
            _buildTextField('Nom Complet', 'Ex: Jean Dupont', controller: _nameController),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Téléphone', 'Ex: 099000000', controller: _phoneController)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Email', 'Ex: jean@example.com', controller: _emailController)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField('Adresse', 'Ex: 15 Avenue de la Paix', maxLines: 2, controller: _addressController),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {int maxLines = 1, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
