import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String itemId;
  final String itemName;
  final int quantity;
  final String type; // 'in' atau 'out'
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.type,
    required this.date,
  });

  factory TransactionModel.fromMap(String id, Map<String, dynamic> data) {
    return TransactionModel(
      id: id,
      itemId: data['itemId'],
      itemName: data['itemName'],
      quantity: data['quantity'],
      type: data['type'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'type': type,
      'date': date,
    };
  }
}
