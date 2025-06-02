import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:waku/models/transaction_model.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedFilter = 'Minggu Ini';

  // Dummy data stok masuk/keluar
  final List<double> stockInData = [10, 12, 8, 15, 9, 11, 7];
  final List<double> stockOutData = [6, 5, 7, 10, 6, 8, 4];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Stok"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur ekspor PDF coming soon!")),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pergerakan Stok", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedFilter,
              items: ['Hari Ini', 'Minggu Ini', 'Bulan Ini']
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedFilter = val!;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                          return Text(days[value.toInt() % 7]);
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(stockInData.length,
                              (i) => FlSpot(i.toDouble(), stockInData[i])),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.2)),
                    ),
                    LineChartBarData(
                      spots: List.generate(stockOutData.length,
                              (i) => FlSpot(i.toDouble(), stockOutData[i])),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: true, color: Colors.red.withOpacity(0.2)),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Stream<List<TransactionModel>> getTransactions() {
    return FirebaseFirestore.instance
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => TransactionModel.fromMap(doc.id, doc.data())).toList());
  }

}
