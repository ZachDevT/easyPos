import 'package:drift/drift.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get color => text().nullable()();
}

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get barcode => text().nullable()();
  TextColumn get sku => text().nullable()();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  RealColumn get purchasePrice => real().withDefault(const Constant(0.0))();
  RealColumn get sellingPrice => real().withDefault(const Constant(0.0))();
  RealColumn get stockQuantity => real().withDefault(const Constant(0.0))();
  RealColumn get minimumStock => real().withDefault(const Constant(0.0))();
  TextColumn get unit => text().withDefault(const Constant('pièce'))();
  TextColumn get imagePath => text().nullable()();
}

class CashSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get openedAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  RealColumn get openingBalance => real()();
  RealColumn get closingBalance => real().nullable()();
  TextColumn get status => text().withDefault(const Constant('OPEN'))(); // OPEN, CLOSED
  TextColumn get notes => text().nullable()();
}

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get totalCredit => real().withDefault(const Constant(0.0))();
}

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get saleNumber => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get subtotal => real()();
  RealColumn get discount => real().withDefault(const Constant(0.0))();
  RealColumn get total => real()();
  TextColumn get paymentMethod => text().withDefault(const Constant('ESPÈCES'))();
  IntColumn get sessionId => integer().nullable().references(CashSessions, #id)();
  IntColumn get customerId => integer().nullable().references(Customers, #id)();
}

class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(Sales, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get total => real()();
}
