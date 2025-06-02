import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/database_service.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stok Barang")),
      body: StreamBuilder<List<ItemModel>>(
        stream: DatabaseService.getItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Terjadi kesalahan"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text("Belum ada barang"));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text("Stok: ${item.stock}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => DatabaseService.deleteItem(item.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-item'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
