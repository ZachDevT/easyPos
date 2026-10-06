import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_provider.dart';

class DashboardStats {
  final double totalSales;
  final int transactionCount;
  final double estimatedProfit;
  final double stockCount;

  DashboardStats({
    required this.totalSales,
    required this.transactionCount,
    required this.estimatedProfit,
    required this.stockCount,
  });
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final db = ref.watch(databaseProvider);
  
  // Today's date range
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  // Get today's sales
  final salesQuery = db.select(db.sales)
    ..where((s) => s.date.isBetweenValues(startOfDay, endOfDay));
  
  final todaySales = await salesQuery.get();
  
  final totalSales = todaySales.fold<double>(0, (sum, sale) => sum + sale.total);
  final transactionCount = todaySales.length;

  // Get total stock count
  final stockQuery = db.select(db.products);
  final allProducts = await stockQuery.get();
  
  final stockCount = allProducts.fold<double>(0, (sum, product) => sum + product.stockQuantity);

  final estimatedProfit = totalSales * 0.3;

  return DashboardStats(
    totalSales: totalSales,
    transactionCount: transactionCount,
    estimatedProfit: estimatedProfit,
    stockCount: stockCount,
  );
});

