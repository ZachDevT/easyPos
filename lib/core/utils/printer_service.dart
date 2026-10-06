import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../database/database.dart';

class PrinterService {
  static Future<void> printReceipt(Sale sale, List<SaleItem> items, List<Product> products, String currency, String storeName, String footer) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(storeName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(footer),
              ),
              pw.Divider(),
              pw.Text('Facture: ${sale.saleNumber}'),
              pw.Text('Date: ${sale.date.day}/${sale.date.month}/${sale.date.year} ${sale.date.hour}:${sale.date.minute}'),
              pw.Text('Paiement: ${sale.paymentMethod}'),
              pw.Divider(),
              ...items.map((item) {
                final product = products.firstWhere((p) => p.id == item.productId);
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text('${item.quantity}x ${product.name}')),
                    pw.Text('${item.total} $currency'),
                  ],
                );
              }),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  pw.Text('${sale.total} $currency', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                ],
              ),
              pw.Divider(),
              pw.Center(
                child: pw.Text('Logiciel EasyPOS'),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Facture_${sale.saleNumber}',
    );
  }
}
