import os
import re

# 1. products_screen.dart
with open('lib/features/products/products_screen.dart', 'r') as f:
    content = f.read()

content = content.replace(
    '''// Show edit panel (we can reuse AddProductPanel or similar in the future)
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Édition autorisée (Mode édition à venir)')));''',
    '''showRightSidePanel(
                                  context: context,
                                  builder: (context) => AddProductPanel(product: product),
                                );'''
)
with open('lib/features/products/products_screen.dart', 'w') as f:
    f.write(content)

# 2. add_product_panel.dart
with open('lib/features/products/widgets/add_product_panel.dart', 'r') as f:
    content = f.read()

content = content.replace("const AddProductPanel({super.key});", "final Product? product;\n  const AddProductPanel({super.key, this.product});")

init_state_logic = '''
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
'''
if "void initState()" not in content:
    content = content.replace("class _AddProductPanelState extends ConsumerState<AddProductPanel> {\n", "class _AddProductPanelState extends ConsumerState<AddProductPanel> {\n" + init_state_logic)

save_logic = '''
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
'''
content = re.sub(r'await db.into\(db.products\).insert\([^;]+;', save_logic, content)
content = content.replace("title: const Text('Ajouter un produit'),", "title: Text(widget.product == null ? 'Ajouter un produit' : 'Modifier le produit'),")

with open('lib/features/products/widgets/add_product_panel.dart', 'w') as f:
    f.write(content)

# 3. customers_screen.dart
with open('lib/features/customers/customers_screen.dart', 'r') as f:
    content = f.read()
content = content.replace("icon: const Icon(Icons.visibility, size: 20, color: Colors.blue),\n                            onPressed: () {},", "icon: const Icon(Icons.edit, size: 20, color: Colors.blue),\n                            onPressed: () { showRightSidePanel(context: context, builder: (context) => AddCustomerPanel(customer: c)); },")
with open('lib/features/customers/customers_screen.dart', 'w') as f:
    f.write(content)

# 4. add_customer_panel.dart
with open('lib/features/customers/widgets/add_customer_panel.dart', 'r') as f:
    content = f.read()
content = content.replace("const AddCustomerPanel({super.key});", "final Customer? customer;\n  const AddCustomerPanel({super.key, this.customer});")
init_cust_logic = '''
  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.phone ?? '';
      _emailController.text = widget.customer!.email ?? '';
      _addressController.text = widget.customer!.address ?? '';
    }
  }
'''
if "void initState()" not in content:
    content = content.replace("class _AddCustomerPanelState extends ConsumerState<AddCustomerPanel> {\n", "class _AddCustomerPanelState extends ConsumerState<AddCustomerPanel> {\n" + init_cust_logic)
save_cust_logic = '''
    if (widget.customer == null) {
      await db.into(db.customers).insert(
        CustomersCompanion.insert(
          name: name,
          phone: drift.Value(_phoneController.text),
          email: drift.Value(_emailController.text),
          address: drift.Value(_addressController.text),
        ),
      );
    } else {
      await (db.update(db.customers)..where((c) => c.id.equals(widget.customer!.id))).write(
        CustomersCompanion(
          name: drift.Value(name),
          phone: drift.Value(_phoneController.text),
          email: drift.Value(_emailController.text),
          address: drift.Value(_addressController.text),
        ),
      );
    }
'''
content = re.sub(r'await db.into\(db.customers\).insert\([^;]+;', save_cust_logic, content)
content = content.replace("title: const Text('Ajouter un client'),", "title: Text(widget.customer == null ? 'Ajouter un client' : 'Modifier le client'),")
with open('lib/features/customers/widgets/add_customer_panel.dart', 'w') as f:
    f.write(content)

# 5. categories_panel.dart
with open('lib/features/products/widgets/categories_panel.dart', 'r') as f:
    content = f.read()

content = content.replace("final _nameController = TextEditingController();", "final _nameController = TextEditingController();\n  int? _editingId;")
add_cat = '''
    if (_editingId == null) {
      await db.into(db.categories).insert(CategoriesCompanion.insert(name: name));
    } else {
      await (db.update(db.categories)..where((c) => c.id.equals(_editingId!))).write(CategoriesCompanion(name: drift.Value(name)));
      _editingId = null;
    }
'''
content = re.sub(r'await db.into\(db.categories\).insert\([^;]+;', add_cat, content)
content = content.replace("label: const Text('Ajouter')", "label: Text(_editingId == null ? 'Ajouter' : 'Modifier')")
edit_button = '''
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              setState(() {
                                _nameController.text = category.name;
                                _editingId = category.id;
                              });
                            },
                          ),
                          IconButton(
'''
content = content.replace("                          IconButton(", edit_button)
with open('lib/features/products/widgets/categories_panel.dart', 'w') as f:
    f.write(content)

print("CRUDs patched!")
