import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/app_theme.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_provider.dart';
import '../providers/category_provider.dart';

class CategoriesPanel extends ConsumerStatefulWidget {
  const CategoriesPanel({super.key});

  @override
  ConsumerState<CategoriesPanel> createState() => _CategoriesPanelState();
}

class _CategoriesPanelState extends ConsumerState<CategoriesPanel> {
  final _nameController = TextEditingController();

  void _addCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final db = ref.read(databaseProvider);
    await db.into(db.categories).insert(
      CategoriesCompanion.insert(name: name),
    );

    _nameController.clear();
  }

  void _deleteCategory(int id) async {
    final db = ref.read(databaseProvider);
    // Note: SQLite foreign keys would normally handle cascading deletes or prevent deletion
    // if products are attached.
    await (db.delete(db.categories)..where((c) => c.id.equals(id))).go();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les Catégories'),
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
              'Ajouter une catégorie',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Ex: Boissons, Électronique...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _addCategory(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _addCategory,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Catégories existantes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Erreur: $e')),
                data: (categories) {
                  if (categories.isEmpty) {
                    return const Center(child: Text('Aucune catégorie.', style: TextStyle(color: Colors.grey)));
                  }
                  
                  return ListView.separated(
                    itemCount: categories.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return ListTile(
                        leading: const Icon(Icons.folder, color: Colors.grey),
                        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCategory(category.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
