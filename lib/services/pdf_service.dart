import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/transaction_model.dart';

class PDFService {
  static Future<void> generateReport(List<TransactionModel> transactions) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Text('Laporan Stok', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            ...transactions.map((t) => pw.Text(
              "${t.itemName} | ${t.type} | ${t.quantity} | ${t.date}",
              style: pw.TextStyle(fontSize: 12),
            )),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
