import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waku/models/transaction_model.dart';
import '../models/item_model.dart';

class DatabaseService {
  static final _itemRef = FirebaseFirestore.instance.collection('items');

  static Future<void> addItem(ItemModel item) async {
    try {
      print("DatabaseService: Starting addItem...");
      print("DatabaseService: Item data - Name: ${item.name}, Category: ${item.category}");

      // Manual mapping untuk memastikan data benar
      Map<String, dynamic> itemData = {
        'name': item.name,
        'category': item.category,
        'price': item.price,
        'stock': item.stock,
        'minStock': item.minStock,
        'imageUrl': item.imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };

      print("DatabaseService: Mapped data: $itemData");

      // Gunakan manual mapping dulu untuk testing
      DocumentReference docRef = await _itemRef.add(itemData);

      print("DatabaseService: Item added successfully with ID: ${docRef.id}");

    } catch (e) {
      print("DatabaseService Error in addItem: $e");
      print("DatabaseService Error type: ${e.runtimeType}");

      // Handle specific Firebase errors
      if (e.toString().contains('PERMISSION_DENIED')) {
        throw Exception('⚠️ Firestore belum diaktifkan! Silakan aktifkan Firestore di Firebase Console.');
      } else if (e.toString().contains('FAILED_PRECONDITION')) {
        throw Exception('⚠️ Firestore Rules tidak mengizinkan operasi ini.');
      } else if (e.toString().contains('UNAVAILABLE')) {
        throw Exception('⚠️ Tidak ada koneksi internet atau server Firebase down.');
      }

      // Re-throw dengan pesan yang lebih jelas
      throw Exception('Gagal menambah item: ${e.toString()}');
    }
  }

  static Future<void> updateItem(ItemModel item) async {
    try {
      Map<String, dynamic> itemData = {
        'name': item.name,
        'category': item.category,
        'price': item.price,
        'stock': item.stock,
        'minStock': item.minStock,
        'imageUrl': item.imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _itemRef.doc(item.id).update(itemData);
    } catch (e) {
      print("DatabaseService Error in updateItem: $e");
      throw Exception('Gagal update item: ${e.toString()}');
    }
  }

  static Future<void> deleteItem(String id) async {
    try {
      await _itemRef.doc(id).delete();
    } catch (e) {
      print("DatabaseService Error in deleteItem: $e");
      throw Exception('Gagal hapus item: ${e.toString()}');
    }
  }

  static Stream<List<ItemModel>> getItemsStream() {
    return _itemRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return ItemModel.fromMap(doc.id, doc.data());
        } catch (e) {
          print("Error converting document ${doc.id}: $e");
          // Return default item jika ada error
          return ItemModel(
            id: doc.id,
            name: 'Error Item',
            category: 'Unknown',
            price: 0.0,
            stock: 0,
            minStock: 0,
            imageUrl: null,
          );
        }
      }).toList();
    });
  }

  static final _transactionRef = FirebaseFirestore.instance.collection('transactions');

  static Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _transactionRef.add(transaction.toMap());

      // Update stok juga
      final doc = await _itemRef.doc(transaction.itemId).get();
      final data = doc.data();
      if (data != null) {
        int currentStock = data['stock'] ?? 0;
        int newStock = transaction.type == 'in'
            ? currentStock + transaction.quantity
            : currentStock - transaction.quantity;
        await _itemRef.doc(transaction.itemId).update({
          'stock': newStock,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("DatabaseService Error in addTransaction: $e");
      throw Exception('Gagal menambah transaksi: ${e.toString()}');
    }
  }

  // Method untuk testing koneksi Firebase
  static Future<bool> testFirebaseConnection() async {
    try {
      print("Testing Firebase connection...");

      // Test dengan operasi sederhana
      await FirebaseFirestore.instance
          .collection('test')
          .doc('connection_test')
          .set({
        'test': 'connection_check',
        'timestamp': FieldValue.serverTimestamp(),
        'testTime': DateTime.now().toIso8601String(),
      });

      print("✅ Firebase connection test: SUCCESS");
      return true;
    } catch (e) {
      print("❌ Firebase connection test: FAILED");
      print("Error details: $e");
      print("Error type: ${e.runtimeType}");
      return false;
    }
  }
}