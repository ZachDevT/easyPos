import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Categories, Brands, Products, CashSessions, Sales, SaleItems, Customers])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Seed initial categories and brands
        final boissonsId = await into(categories).insert(CategoriesCompanion.insert(name: 'Boissons'));
        final alimId = await into(categories).insert(CategoriesCompanion.insert(name: 'Alimentation'));
        final elecId = await into(categories).insert(CategoriesCompanion.insert(name: 'Électronique'));
        final cosmeId = await into(categories).insert(CategoriesCompanion.insert(name: 'Cosmétiques'));

        // Seed Brands
        await into(brands).insert(BrandsCompanion.insert(name: 'Coca-Cola', categoryId: boissonsId));
        await into(brands).insert(BrandsCompanion.insert(name: 'Pepsi', categoryId: boissonsId));
        await into(brands).insert(BrandsCompanion.insert(name: 'Fanta', categoryId: boissonsId));
        await into(brands).insert(BrandsCompanion.insert(name: 'Nestlé', categoryId: alimId));
        await into(brands).insert(BrandsCompanion.insert(name: 'Samsung', categoryId: elecId));
        await into(brands).insert(BrandsCompanion.insert(name: 'Apple', categoryId: elecId));
        await into(brands).insert(BrandsCompanion.insert(name: 'Nivea', categoryId: cosmeId));
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          await m.createTable(brands);
          await m.addColumn(products, products.brandId);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'easypos.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
