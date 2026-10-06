import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_provider.dart';

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.products).watch();
});
