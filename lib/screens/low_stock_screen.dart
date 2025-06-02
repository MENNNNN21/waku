import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LowStockScreen extends StatelessWidget {
  const LowStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi Stok Rendah")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('barang')
            .where('stok', isLessThan: 5) // ambang batas stok rendah
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Terjadi kesalahan"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("Tidak ada stok rendah saat ini"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                title: Text(data['nama'] ?? '-'),
                subtitle: Text("Stok: ${data['stok']}"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(data['nama'] ?? 'Detail Barang'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Stok saat ini: ${data['stok']}"),
                          Text("Harga: ${data['harga'] ?? '-'}"),
                          Text("Kategori: ${data['kategori'] ?? '-'}"),
                          Text("Kode Barang: ${data['kode'] ?? '-'}"),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Tutup"),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
