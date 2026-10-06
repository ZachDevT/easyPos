import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_provider.dart';

final salesHistoryProvider = StreamProvider<List<Sale>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.sales)..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();
});
