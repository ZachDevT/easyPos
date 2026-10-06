import re

with open('lib/features/products/products_screen.dart', 'r') as f:
    c = f.read()

c = c.replace(
'''// Show edit panel (we can reuse AddProductPanel or similar in the future)
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Édition autorisée (Mode édition à venir)')));''',
'''showRightSidePanel(
                                  context: context,
                                  builder: (context) => AddProductPanel(product: product),
                                );'''
)

c = c.replace(
'''            DataTable(''', 
'''            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable('''
)

c = re.sub(r'rows: products\.map\(\(product\) \{[\s\S]*?\}\)\.toList\(\),\n\s*\),',
'''rows: products.map((product) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: product.imagePath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(product.imagePath!), // Note: Use dart:io File, handled via import.
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.image, size: 20, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      DataCell(Text(product.sku ?? '-')),
                      DataCell(Text(product.barcode ?? '-')),
                      DataCell(Text('Catégorie ${product.categoryId}')),
                      DataCell(Text('${product.purchasePrice} $currency')),
                      DataCell(Text('${product.sellingPrice} $currency', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: product.stockQuantity <= product.minimumStock 
                                ? AppTheme.dangerColor.withOpacity(0.1)
                                : AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${product.stockQuantity} ${product.unit}',
                            style: TextStyle(
                              color: product.stockQuantity <= product.minimumStock 
                                  ? AppTheme.dangerColor
                                  : AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                              onPressed: () {
                                showRightSidePanel(
                                  context: context,
                                  builder: (context) => AddProductPanel(product: product),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () async {
                                final db = ref.read(databaseProvider);
                                await (db.delete(db.products)..where((tbl) => tbl.id.equals(product.id))).go();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),''', c
)

with open('lib/features/products/products_screen.dart', 'w') as f:
    f.write(c)
