import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_provider.dart';

final customersStreamProvider = StreamProvider<List<Customer>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.customers).watch();
});
