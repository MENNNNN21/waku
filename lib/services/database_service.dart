import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waku/models/transaction_model.dart';
import '../models/item_model.dart';

class DatabaseService {
  static final _itemRef = FirebaseFirestore.instance.collection('items');

  static Future<void> addItem(ItemModel item) async {
    await _itemRef.add(item.toMap());
  }

  static Future<void> updateItem(ItemModel item) async {
    await _itemRef.doc(item.id).update(item.toMap());
  }

  static Future<void> deleteItem(String id) async {
    await _itemRef.doc(id).delete();
  }

  static Stream<List<ItemModel>> getItemsStream() {
    return _itemRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ItemModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }
  static final _transactionRef = FirebaseFirestore.instance.collection('transactions');

  static Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionRef.add(transaction.toMap());

    // Update stok juga
    final doc = await _itemRef.doc(transaction.itemId).get();
    final data = doc.data();
    if (data != null) {
      int currentStock = data['stock'];
      int newStock = transaction.type == 'in' ? currentStock + transaction.quantity : currentStock - transaction.quantity;
      await _itemRef.doc(transaction.itemId).update({'stock': newStock});
    }
  }

}
