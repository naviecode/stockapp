import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  /// Lắng nghe toàn bộ giao dịch của user
  void listenTransactions(String userId) {
    _db.collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _transactions = snapshot.docs.map((doc) =>
          TransactionModel.fromFirestore(doc.data(), doc.id)).toList();
      notifyListeners();
    });
  }

  /// Thêm giao dịch
  Future<void> addTransaction({
    required String userId,
    required String stockId,
    required String type, // BUY | SELL
    required int quantity,
    required double price,
  }) async {
    final total = price * quantity;
    final data = {
      'userId': userId,
      'stockId': stockId,
      'type': type,
      'quantity': quantity,
      'price': price,
      'total': total,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _db.collection('transactions').add(data);
  }
}
