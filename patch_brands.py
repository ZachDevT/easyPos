import os
import re

with open('lib/features/products/widgets/add_product_panel.dart', 'r') as f:
    content = f.read()

# Add _selectedCategoryId and _selectedBrandId
init_vars = '''  int? _selectedCategoryId;
  int? _selectedBrandId;
  List<Brand> _availableBrands = [];

  @override'''
content = content.replace("  @override", init_vars, 1)

# In initState, set them
init_state = '''    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _skuController.text = widget.product!.sku ?? '';
      _barcodeController.text = widget.product!.barcode ?? '';
      _purchasePriceController.text = widget.product!.purchasePrice.toString();
      _sellingPriceController.text = widget.product!.sellingPrice.toString();
      _stockController.text = widget.product!.stockQuantity.toString();
      _minStockController.text = widget.product!.minimumStock.toString();
      _selectedUnit = widget.product!.unit;
      _imagePath = widget.product!.imagePath;
      _selectedCategoryId = widget.product!.categoryId;
      _selectedBrandId = widget.product!.brandId;
      if (_selectedCategoryId != null) {
        _loadBrands(_selectedCategoryId!);
      }
    }'''
content = content.replace("    if (widget.product != null) {\n      _nameController.text = widget.product!.name;", init_state.replace("    if (widget.product != null) {\n      _nameController.text = widget.product!.name;", "    if (widget.product != null) {\n      _nameController.text = widget.product!.name;"))

content = re.sub(r'_loadBrands[^{]*', '', content) # remove any if previously inserted just in case

# Add _loadBrands method
load_brands_method = '''
  Future<void> _loadBrands(int categoryId) async {
    final db = ref.read(databaseProvider);
    final brands = await (db.select(db.brands)..where((b) => b.categoryId.equals(categoryId))).get();
    setState(() {
      _availableBrands = brands;
      // Reset brand if it doesn't belong to the new category
      if (_selectedBrandId != null && !brands.any((b) => b.id == _selectedBrandId)) {
        _selectedBrandId = null;
      }
    });
  }
'''
content = content.replace("  void _saveProduct() async {", load_brands_method + "\n  void _saveProduct() async {")

# Update save logic to include brandId and categoryId correctly
save_insert = '''
        ProductsCompanion.insert(
          name: name,
          categoryId: drift.Value(_selectedCategoryId ?? 1),
          brandId: drift.Value(_selectedBrandId),
          sku: drift.Value(_skuController.text),
'''
content = re.sub(r'ProductsCompanion\.insert\([\s\S]*?sku: drift\.Value\(_skuController\.text\),', save_insert, content)

save_update = '''
        ProductsCompanion(
          name: drift.Value(name),
          categoryId: drift.Value(_selectedCategoryId),
          brandId: drift.Value(_selectedBrandId),
          sku: drift.Value(_skuController.text),
'''
content = re.sub(r'ProductsCompanion\(\n\s*name: drift\.Value\(name\),\n\s*sku: drift\.Value\(_skuController\.text\),', save_update, content)

# Update dropdown UI
ui_dropdown = '''
            Row(
              children: [
                Expanded(child: _buildCategoryDropdown()),
                const SizedBox(width: 16),
                Expanded(child: _buildBrandDropdown()),
              ],
            ),
'''
content = re.sub(r'Row\(\s*children: \[\s*Expanded\(child: _buildCategoryDropdown\(\)\),\s*const SizedBox\(width: 16\),\s*Expanded\(child: _buildTextField\(\'Marque\', \'Ex: Coca-Cola\'\)\),\s*\],\s*\),', ui_dropdown, content)

category_dropdown = '''
  Widget _buildCategoryDropdown() {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
          child: categoriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('Erreur: $e'),
            data: (categories) {
              if (categories.isEmpty) return const Text('Aucune catégorie');
              if (_selectedCategoryId == null && categories.isNotEmpty) {
                 // Defer setting state to avoid build cycle issues
                 WidgetsBinding.instance.addPostFrameCallback((_) {
                   if (mounted) {
                     setState(() => _selectedCategoryId = categories.first.id);
                     _loadBrands(categories.first.id);
                   }
                 });
              }
              return DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _selectedCategoryId,
                  items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedCategoryId = val);
                      _loadBrands(val);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBrandDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Marque (Optionnelle)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              hint: const Text('Aucune marque'),
              value: _selectedBrandId,
              items: _availableBrands.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
              onChanged: (val) {
                setState(() => _selectedBrandId = val);
              },
            ),
          ),
        ),
      ],
    );
  }
'''
content = re.sub(r'Widget _buildCategoryDropdown\(\) \{[\s\S]*\}\n}', category_dropdown, content)

with open('lib/features/products/widgets/add_product_panel.dart', 'w') as f:
    f.write(content)

print("Add Product panel updated with dynamic brands!")
