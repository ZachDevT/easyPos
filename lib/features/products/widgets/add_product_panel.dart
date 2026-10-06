import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart' as drift;
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
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.product?.name ?? '');
  late final _skuController = TextEditingController(text: widget.product?.sku ?? '');
  late final _barcodeController = TextEditingController(text: widget.product?.barcode ?? '');
  late final _purchaseController = TextEditingController(text: (widget.product?.purchasePrice ?? '').toString());
  late final _sellingController = TextEditingController(text: (widget.product?.sellingPrice ?? '').toString());
  late final _stockController = TextEditingController(text: (widget.product?.stockQuantity ?? '').toString());
  late final _minStockController = TextEditingController(text: (widget.product?.minimumStock ?? '').toString());

  String _unit = 'pièce';
  String? _imagePath;
  int? _categoryId;
  int? _brandId;
  List<Brand> _brands = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _unit = widget.product!.unit;
      _imagePath = widget.product!.imagePath;
      _categoryId = widget.product!.categoryId;
      _brandId = widget.product!.brandId;
      if (_categoryId != null) _loadBrands(_categoryId!);
    }
  }

  @override
  void dispose() {
    for (final c in [_nameController, _skuController, _barcodeController, _purchaseController, _sellingController, _stockController, _minStockController]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadBrands(int catId) async {
    final db = ref.read(databaseProvider);
    final brands = await (db.select(db.brands)..where((b) => b.categoryId.equals(catId))).get();
    if (mounted) setState(() { _brands = brands; if (!brands.any((b) => b.id == _brandId)) _brandId = null; });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final dir = await getApplicationDocumentsDirectory();
      final saved = await File(picked.path).copy(p.join(dir.path, p.basename(picked.path)));
      if (mounted) setState(() => _imagePath = saved.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final db = ref.read(databaseProvider);
      final name = _nameController.text.trim();
      final purchase = double.tryParse(_purchaseController.text) ?? 0;
      final selling = double.tryParse(_sellingController.text) ?? 0;
      final stock = double.tryParse(_stockController.text) ?? 0;
      final minStock = double.tryParse(_minStockController.text) ?? 0;

      if (widget.product == null) {
        await db.into(db.products).insert(ProductsCompanion.insert(
          name: name,
          categoryId: drift.Value(_categoryId),
          brandId: drift.Value(_brandId),
          sku: drift.Value(_skuController.text.isEmpty ? null : _skuController.text),
          barcode: drift.Value(_barcodeController.text.isEmpty ? null : _barcodeController.text),
          purchasePrice: drift.Value(purchase),
          sellingPrice: drift.Value(selling),
          stockQuantity: drift.Value(stock),
          minimumStock: drift.Value(minStock),
          unit: drift.Value(_unit),
          imagePath: drift.Value(_imagePath),
        ));
      } else {
        await (db.update(db.products)..where((t) => t.id.equals(widget.product!.id))).write(ProductsCompanion(
          name: drift.Value(name),
          categoryId: drift.Value(_categoryId),
          brandId: drift.Value(_brandId),
          sku: drift.Value(_skuController.text.isEmpty ? null : _skuController.text),
          barcode: drift.Value(_barcodeController.text.isEmpty ? null : _barcodeController.text),
          purchasePrice: drift.Value(purchase),
          sellingPrice: drift.Value(selling),
          stockQuantity: drift.Value(stock),
          minimumStock: drift.Value(minStock),
          unit: drift.Value(_unit),
          imagePath: drift.Value(_imagePath),
        ));
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(settingsProvider).currency;
    final isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEdit ? 'Modifier le produit' : 'Nouveau produit',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111111),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: _isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Enregistrer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: const Color(0xFFE5E7EB), height: 1)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + Name row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF9C3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE047), width: 1.5),
                      ),
                      child: _imagePath != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(11), child: Image.file(File(_imagePath!), fit: BoxFit.cover))
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, size: 24, color: Color(0xFFCA8A04)),
                                SizedBox(height: 4),
                                Text('Photo', style: TextStyle(fontSize: 10, color: Color(0xFFCA8A04), fontWeight: FontWeight.w600)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _field('Nom du produit *', 'Ex: Coca-Cola 50cl', controller: _nameController, required: true),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _section('Catégorie & Marque'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _categoryDropdown()),
                const SizedBox(width: 12),
                Expanded(child: _brandDropdown()),
              ]),

              const SizedBox(height: 16),
              _section('Identification'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _field('SKU', 'Ex: COKE001', controller: _skuController)),
                const SizedBox(width: 12),
                Expanded(child: _field('Code-barres', 'Scannez…', controller: _barcodeController, icon: Icons.qr_code_scanner_outlined)),
              ]),

              const SizedBox(height: 16),
              _section('Prix ($currency)'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _field('Prix d\'achat', '0', controller: _purchaseController, isNumber: true)),
                const SizedBox(width: 12),
                Expanded(child: _field('Prix de vente', '0', controller: _sellingController, isNumber: true)),
              ]),

              const SizedBox(height: 16),
              _section('Stock'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _field('Quantité', '0', controller: _stockController, isNumber: true, required: true)),
                const SizedBox(width: 12),
                Expanded(child: _field('Stock minimum', '5', controller: _minStockController, isNumber: true)),
                const SizedBox(width: 12),
                Expanded(child: _unitDropdown()),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) => Text(
    title,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF), letterSpacing: 0.5),
  );

  Widget _field(String label, String hint, {
    TextEditingController? controller, bool isNumber = false, bool required = false, IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
            suffixIcon: icon != null ? Icon(icon, size: 16, color: const Color(0xFF9CA3AF)) : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFACC15), width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEF4444))),
          ),
          validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null : null,
        ),
      ],
    );
  }

  Widget _unitDropdown() {
    const units = ['pièce', 'boîte', 'kg', 'litre', 'paquet', 'carton'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Unité', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _unit,
          style: const TextStyle(fontSize: 13, color: Color(0xFF111111)),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFACC15), width: 2)),
          ),
          items: units.map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (v) { if (v != null) setState(() => _unit = v); },
        ),
      ],
    );
  }

  Widget _categoryDropdown() {
    final catsAsync = ref.watch(categoriesStreamProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Catégorie', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 4),
        catsAsync.when(
          loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          error: (e, _) => Text('Erreur', style: const TextStyle(color: Colors.red, fontSize: 12)),
          data: (cats) {
            if (cats.isEmpty) return const Text('Aucune catégorie', style: TextStyle(fontSize: 12, color: Colors.grey));
            return DropdownButtonFormField<int>(
              value: _categoryId,
              style: const TextStyle(fontSize: 13, color: Color(0xFF111111)),
              decoration: InputDecoration(
                hintText: 'Choisir…',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFD1D5DB)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFACC15), width: 2)),
              ),
              items: cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _categoryId = v);
                  _loadBrands(v);
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _brandDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Marque (optionnel)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 4),
        DropdownButtonFormField<int>(
          value: _brandId,
          style: const TextStyle(fontSize: 13, color: Color(0xFF111111)),
          decoration: InputDecoration(
            hintText: 'Aucune',
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFD1D5DB)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFACC15), width: 2)),
          ),
          items: [
            const DropdownMenuItem<int>(value: null, child: Text('— Aucune —', style: TextStyle(fontSize: 13, color: Colors.grey))),
            ..._brands.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name, style: const TextStyle(fontSize: 13)))),
          ],
          onChanged: (v) => setState(() => _brandId = v),
        ),
      ],
    );
  }
}
