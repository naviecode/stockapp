import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stock_model.dart';

class StockProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<StockModel> _stocks = [];

  List<StockModel> get stocks => _stocks;

  /// Lắng nghe realtime danh sách cổ phiếu
  void listenStocks() {
    _db.collection('stocks').snapshots().listen((snapshot) {
      _stocks = snapshot.docs
          .map((doc) => StockModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }

  /// Fetch một lần (không realtime)
  Future<void> fetchStocksOnce() async {
    final snapshot = await _db.collection('stocks').get();
    _stocks = snapshot.docs
        .map((doc) => StockModel.fromFirestore(doc))
        .toList();
    notifyListeners();
  }

  /// Thêm mới cổ phiếu
  Future<void> addStock(StockModel stock) async {
    await _db.collection('stocks').add(stock.toMap());
  }

  /// Cập nhật cổ phiếu
  Future<void> updateStock(String id, StockModel stock) async {
    await _db.collection('stocks').doc(id).update(stock.toMap());
  }

  /// Xoá cổ phiếu
  Future<void> deleteStock(String id) async {
    await _db.collection('stocks').doc(id).delete();
  }

  /// Lấy chi tiết 1 cổ phiếu
  StockModel? getStockById(String id) {
    try {
      return _stocks.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
