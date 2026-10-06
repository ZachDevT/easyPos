import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_provider.dart';

final activeSessionProvider = FutureProvider<CashSession?>((ref) async {
  final db = ref.watch(databaseProvider);
  
  // Find the most recent session that is 'OPEN'
  final query = db.select(db.cashSessions)
    ..where((t) => t.status.equals('OPEN'))
    ..orderBy([(t) => OrderingTerm.desc(t.openedAt)])
    ..limit(1);
    
  return await query.getSingleOrNull();
});
