import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<TransactionModel> _transactions = [];

  bool _loading = false;
  bool get loading => _loading;
  List<TransactionModel> get transactions => _transactions;

  StreamSubscription<QuerySnapshot>? _subscription;


  /// Lắng nghe toàn bộ giao dịch của user
  void listenTransactions(String? userId) {
    _loading = true;
    notifyListeners();

     _subscription?.cancel();

    _subscription = _db
      .collection('transactions')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .listen(
        (snapshot) {
          _transactions = snapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc.data(), doc.id))
              .toList();
          _loading = false;
          notifyListeners();
        },
        onError: (e) {
          print("Firestore error: $e");
          _loading = false;
          notifyListeners();
        },
      );
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

  void cancelListen() {
    _subscription?.cancel();
    _subscription = null;
  }

  Stream<List<TransactionModel>> transactionsStream(String userId) {
    return _db
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Nạp tiền vào ví
  Future<void> deposit(String userId, double amount) async {
    if (amount <= 0) return;

    final userRef = _db.collection('users').doc(userId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) throw Exception("User not found");

      final currentBalance = (snapshot.get('balance') ?? 0).toDouble();
      final newBalance = currentBalance + amount;

      // Cập nhật balance
      transaction.update(userRef, {'balance': newBalance});

      // Thêm transaction nạp tiền
      final txRef = _db.collection('transactions').doc();
      transaction.set(txRef, {
        'userId': userId,
        'stockId': null,
        'type': 'DEPOSIT',
        'quantity': 0,
        'price': amount,
        'total': amount,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Rút tiền từ ví
  Future<void> withdraw(String userId, double amount) async {
    if (amount <= 0) return;

    final userRef = _db.collection('users').doc(userId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) throw Exception("User not found");

      final currentBalance = (snapshot.get('balance') ?? 0).toDouble();
      if (currentBalance < amount) throw Exception("Không đủ số dư");

      final newBalance = currentBalance - amount;

      // Cập nhật balance
      transaction.update(userRef, {'balance': newBalance});

      // Thêm transaction rút tiền
      final txRef = _db.collection('transactions').doc();
      transaction.set(txRef, {
        'userId': userId,
        'stockId': null,
        'type': 'WITHDRAW',
        'quantity': 0,
        'price': amount,
        'total': amount,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
