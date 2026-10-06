import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';

class TopProduct {
  final String name;
  final int totalSold;
  TopProduct(this.name, this.totalSold);
}

class DailyRevenue {
  final String date;
  final double revenue;
  DailyRevenue(this.date, this.revenue);
}

class PaymentStat {
  final String method;
  final double total;
  PaymentStat(this.method, this.total);
}

class ReportsData {
  final List<TopProduct> topProducts;
  final List<DailyRevenue> dailyRevenue;
  final List<PaymentStat> paymentStats;

  ReportsData(this.topProducts, this.dailyRevenue, this.paymentStats);
}

final reportsProvider = FutureProvider<ReportsData>((ref) async {
  final db = ref.watch(databaseProvider);

  // 1. Top 5 Products
  final topProductsResult = await db.customSelect(
    '''
    SELECT p.name, SUM(si.quantity) as total_sold
    FROM sale_items si
    JOIN products p ON p.id = si.product_id
    GROUP BY p.id, p.name
    ORDER BY total_sold DESC
    LIMIT 5;
    ''',
    readsFrom: {db.saleItems, db.products},
  ).get();

  final topProducts = topProductsResult.map((row) {
    return TopProduct(
      row.read<String>('name'),
      row.read<double>('total_sold').toInt(),
    );
  }).toList();

  // 2. Revenue over last 30 days
  final dailyResult = await db.customSelect(
    '''
    SELECT DATE(date, 'unixepoch') as day, SUM(total) as revenue
    FROM sales
    WHERE date >= unixepoch('now', '-30 days')
    GROUP BY day
    ORDER BY day ASC;
    ''',
    readsFrom: {db.sales},
  ).get();

  final dailyRevenue = dailyResult.map((row) {
    return DailyRevenue(
      row.read<String>('day'),
      row.read<double>('revenue'),
    );
  }).toList();

  // 3. Payment Methods
  final paymentResult = await db.customSelect(
    '''
    SELECT payment_method, SUM(total) as total
    FROM sales
    GROUP BY payment_method;
    ''',
    readsFrom: {db.sales},
  ).get();

  final paymentStats = paymentResult.map((row) {
    return PaymentStat(
      row.read<String>('payment_method'),
      row.read<double>('total'),
    );
  }).toList();

  return ReportsData(topProducts, dailyRevenue, paymentStats);
});
