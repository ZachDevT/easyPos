import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_provider.dart';

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.categories).watch();
});
