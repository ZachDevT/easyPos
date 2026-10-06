import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/database.dart';
import '../providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart';

class AddProductPanel extends ConsumerStatefulWidget {
  final Product? product;
  const AddProductPanel({super.key, this.product});

  @override
  ConsumerState<AddProductPanel> createState() => _AddProductPanelState();
}

class _AddProductPanelState extends ConsumerState<AddProductPanel> {

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _skuController.text = widget.product!.sku ?? '';
      _barcodeController.text = widget.product!.barcode ?? '';
      _purchasePriceController.text = widget.product!.purchasePrice.toString();
      _sellingPriceController.text = widget.product!.sellingPrice.toString();
      _stockController.text = widget.product!.stockQuantity.toString();
      _minStockController.text = widget.product!.minimumStock.toString();
      _selectedUnit = widget.product!.unit;
      _imagePath = widget.product!.imagePath;
    }
  }
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  
  String _selectedUnit = 'pièce';
  String? _imagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      // In a real app, you might want to copy this to the app's document directory
      final docDir = await getApplicationDocumentsDirectory();
      final fileName = p.basename(pickedFile.path);
      final savedImage = await File(pickedFile.path).copy(p.join(docDir.path, fileName));
      
      setState(() {
        _imagePath = savedImage.path;
      });
    }
  }

  void _saveProduct() async {
    final name = _nameController.text;
    if (name.isEmpty) return; // Simple validation

    final db = ref.read(databaseProvider);
    
    
    if (widget.product == null) {
      await db.into(db.products).insert(
        ProductsCompanion.insert(
          name: name,
          categoryId: drift.Value(1), // TODO: select
          sku: drift.Value(_skuController.text),
          barcode: drift.Value(_barcodeController.text),
          purchasePrice: drift.Value(double.tryParse(_purchasePriceController.text) ?? 0.0),
          sellingPrice: drift.Value(double.tryParse(_sellingPriceController.text) ?? 0.0),
          stockQuantity: drift.Value(double.tryParse(_stockController.text) ?? 0.0),
          minimumStock: drift.Value(double.tryParse(_minStockController.text) ?? 0.0),
          unit: drift.Value(_selectedUnit),
          imagePath: drift.Value(_imagePath),
        ),
      );
    } else {
      await (db.update(db.products)..where((p) => p.id.equals(widget.product!.id))).write(
        ProductsCompanion(
          name: drift.Value(name),
          sku: drift.Value(_skuController.text),
          barcode: drift.Value(_barcodeController.text),
          purchasePrice: drift.Value(double.tryParse(_purchasePriceController.text) ?? 0.0),
          sellingPrice: drift.Value(double.tryParse(_sellingPriceController.text) ?? 0.0),
          stockQuantity: drift.Value(double.tryParse(_stockController.text) ?? 0.0),
          minimumStock: drift.Value(double.tryParse(_minStockController.text) ?? 0.0),
          unit: drift.Value(_selectedUnit),
          imagePath: drift.Value(_imagePath),
        ),
      );
    }


    if (mounted) {
      Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(settingsProvider).currency;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Ajouter un produit' : 'Modifier le produit'),
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
              onPressed: _saveProduct,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Image du produit (Optionnel)'),
            _buildImagePicker(),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Informations de base'),
            _buildTextField('Nom du produit', 'Ex: Coca-Cola 50cl', controller: _nameController),
            Row(
              children: [
                Expanded(child: _buildCategoryDropdown()),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Marque', 'Ex: Coca-Cola')),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField('Description', 'Description du produit...', maxLines: 3),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Identification'),
            Row(
              children: [
                Expanded(child: _buildTextField('SKU', 'Ex: COKE001', controller: _skuController)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Code-barres', 'Scannez le code-barres', icon: Icons.qr_code_scanner, controller: _barcodeController)),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Prix & Stock'),
            Row(
              children: [
                Expanded(child: _buildTextField('Prix d\'achat ($currency)', '0.00', isNumber: true, controller: _purchasePriceController)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Prix de vente ($currency)', '0.00', isNumber: true, controller: _sellingPriceController)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Stock initial', '0', isNumber: true, controller: _stockController)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Stock minimum', '10', isNumber: true, controller: _minStockController)),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdown('Unité', ['pièce', 'boîte', 'kg', 'litre'], (val) {
                  if (val != null) setState(() => _selectedUnit = val);
                }, initialValue: _selectedUnit)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: _imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(File(_imagePath!), fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text('Ajouter', style: TextStyle(color: Colors.grey[600])),
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

  Widget _buildTextField(String label, String hint, {bool isNumber = false, int maxLines = 1, IconData? icon, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: icon != null ? Icon(icon) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged, {String? initialValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: initialValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          hint: const Text('Sélectionner'),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: categoriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('Erreur: $e'),
            data: (categories) {
              if (categories.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Aucune catégorie (Créer une d\'abord)', style: TextStyle(color: Colors.red)),
                );
              }
              // Ideally we track a _selectedCategoryId state variable, but for prototype we can default to the first
              return DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: categories.first.id,
                  items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (val) {
                    // setState(() => _selectedCategoryId = val);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
