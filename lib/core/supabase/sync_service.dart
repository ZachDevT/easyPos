import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database.dart';

class SyncService {
  final AppDatabase db;
  final SupabaseClient supabase = Supabase.instance.client;
  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncService(this.db) {
    _initConnectivityListener();
    _startPeriodicSync();
  }

  void _initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        syncData();
      }
    });
  }

  void _startPeriodicSync() {
    // Run sync every 5 minutes as a fallback
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      syncData();
    });
  }

  void dispose() {
    _syncTimer?.cancel();
  }

  Future<void> syncData() async {
    if (_isSyncing) return;
    
    final prefs = await SharedPreferences.getInstance();
    final boutiqueId = prefs.getString('boutique_id');
    if (boutiqueId == null) return; // Not logged in

    final connectivityResults = await (Connectivity().checkConnectivity());
    if (connectivityResults.isEmpty || connectivityResults.first == ConnectivityResult.none) {
      return; // Offline
    }

    try {
      _isSyncing = true;
      print("Starting Supabase Sync...");

      // 1. Sync Products (Local to Cloud)
      final products = await db.select(db.products).get();
      for (var product in products) {
        await supabase.from('products').upsert({
          'id': product.id,
          'boutique_id': boutiqueId,
          'name': product.name,
          'barcode': product.barcode,
          'sku': product.sku,
          'category_id': product.categoryId,
          'brand_id': product.brandId,
          'purchase_price': product.purchasePrice,
          'selling_price': product.sellingPrice,
          'stock_quantity': product.stockQuantity,
          'minimum_stock': product.minimumStock,
          'unit': product.unit,
        });
      }

      // 2. Sync Sales (Local to Cloud)
      final sales = await db.select(db.sales).get();
      for (var sale in sales) {
        await supabase.from('sales').upsert({
          'id': sale.id,
          'boutique_id': boutiqueId,
          'sale_number': sale.saleNumber,
          'date': sale.date.toIso8601String(),
          'subtotal': sale.subtotal,
          'discount': sale.discount,
          'total': sale.total,
          'payment_method': sale.paymentMethod,
          'customer_id': sale.customerId,
        });
      }

      print("Sync Complete!");
    } catch (e) {
      print("Sync Error: $e");
    } finally {
      _isSyncing = false;
    }
  }
}
