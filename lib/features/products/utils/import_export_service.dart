import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/database.dart';

class ImportExportService {
  final AppDatabase db;

  ImportExportService(this.db);

  Future<String?> downloadTemplate() async {
    try {
      final directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/modele_produits.csv';
      final File file = File(path);

      final List<List<dynamic>> rows = [
        ["Nom", "CodeBarre", "SKU", "PrixAchat", "PrixVente", "Stock", "StockMinimum", "Unite"],
        ["Coca-Cola 50cl", "123456789", "CC50", 0.5, 1.0, 100, 10, "pièce"],
        ["Pain", "987654321", "PAIN01", 0.2, 0.5, 50, 5, "pièce"],
      ];

      final String csvContent = CsvEncoder().convert(rows);
      await file.writeAsString(csvContent);
      return path;
    } catch (e) {
      print("Erreur création modèle: $e");
      return null;
    }
  }

  Future<String?> exportProducts() async {
    try {
      final directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/export_produits_${DateTime.now().millisecondsSinceEpoch}.csv';
      final File file = File(path);

      final products = await db.select(db.products).get();

      final List<List<dynamic>> rows = [
        ["Nom", "CodeBarre", "SKU", "PrixAchat", "PrixVente", "Stock", "StockMinimum", "Unite"],
        ...products.map((p) => [
          p.name,
          p.barcode ?? "",
          p.sku ?? "",
          p.purchasePrice,
          p.sellingPrice,
          p.stockQuantity,
          p.minimumStock,
          p.unit,
        ]),
      ];

      final String csvContent = CsvEncoder().convert(rows);
      await file.writeAsString(csvContent);
      return path;
    } catch (e) {
      print("Erreur export: $e");
      return null;
    }
  }

  Future<int> importProducts() async {
    int importedCount = 0;
    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (files.isNotEmpty && files.first.path != null) {
        final File file = File(files.first.path!);
        final String input = await file.readAsString();

        final List<List<dynamic>> rows = CsvDecoder().convert(input);

        if (rows.length > 1) {
          await db.transaction(() async {
            for (int i = 1; i < rows.length; i++) {
              final row = rows[i];
              if (row.isEmpty || row[0].toString().isEmpty) continue;

              final name = row[0].toString();
              final barcode = row.length > 1 && row[1].toString().isNotEmpty ? row[1].toString() : null;
              final sku = row.length > 2 && row[2].toString().isNotEmpty ? row[2].toString() : null;
              final purchasePrice = row.length > 3 ? double.tryParse(row[3].toString()) ?? 0.0 : 0.0;
              final sellingPrice = row.length > 4 ? double.tryParse(row[4].toString()) ?? 0.0 : 0.0;
              final stock = row.length > 5 ? double.tryParse(row[5].toString()) ?? 0.0 : 0.0;
              final minStock = row.length > 6 ? double.tryParse(row[6].toString()) ?? 0.0 : 0.0;
              final unit = row.length > 7 && row[7].toString().isNotEmpty ? row[7].toString() : 'pièce';

              await db.into(db.products).insert(
                ProductsCompanion.insert(
                  name: name,
                  barcode: drift.Value(barcode),
                  sku: drift.Value(sku),
                  purchasePrice: drift.Value(purchasePrice),
                  sellingPrice: drift.Value(sellingPrice),
                  stockQuantity: drift.Value(stock),
                  minimumStock: drift.Value(minStock),
                  unit: drift.Value(unit),
                ),
              );
              importedCount++;
            }
          });
        }
      }
    } catch (e) {
      print("Erreur import: $e");
      throw Exception("Format de fichier invalide: $e");
    }
    return importedCount;
  }
}
