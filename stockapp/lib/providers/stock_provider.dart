import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stock_model.dart';

enum StockListFilter { all, topGainers, topLosers, topVolume }
class StockProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<StockModel> _stocks = [];
  StockListFilter currentFilter = StockListFilter.all;

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

    List<StockModel> get filteredStockList {
    switch (currentFilter) {
      case StockListFilter.topGainers:
        return getTopGainers();
      case StockListFilter.topLosers:
        return getTopLosers();
      case StockListFilter.topVolume:
        return getTopVolume();
      case StockListFilter.all:
      default:
        return stocks;
    }
  }

    void searchStock(String keyword) {
      if (keyword.isEmpty) {
        _stocks = [];
      } else {
        _stocks = _stocks
            .where((s) =>
                s.symbol.toLowerCase().contains(keyword.toLowerCase()) ||
                s.name.toLowerCase().contains(keyword.toLowerCase()))
            .toList();
      }
      notifyListeners();
  }

  void setFilter(StockListFilter filter) {
    currentFilter = filter;
    notifyListeners();
  }

  /// ⭐ Top Gainers: cổ phiếu tăng mạnh nhất theo %
  List<StockModel> getTopGainers({int limit = 5}) {
    final gainers = _stocks.where((s) => s.changePercent > 0).toList();
    gainers.sort((a, b) => b.changePercent.compareTo(a.changePercent));
    return gainers.take(limit).toList();
  }

  /// ⭐ Top Losers: cổ phiếu giảm mạnh nhất theo %
  List<StockModel> getTopLosers({int limit = 5}) {
    final losers = _stocks.where((s) => s.changePercent < 0).toList();
    losers.sort((a, b) => a.changePercent.compareTo(b.changePercent));
    return losers.take(limit).toList();
  }

  /// ⭐ Top Volume: cổ phiếu có khối lượng giao dịch cao nhất
  List<StockModel> getTopVolume({int limit = 5}) {
    final volumes = List<StockModel>.from(_stocks);
    volumes.sort((a, b) => b.volume.compareTo(a.volume));
    return volumes.take(limit).toList();
  }
}
