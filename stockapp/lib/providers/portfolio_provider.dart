import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/portfolio_model.dart';

class PortfolioProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  PortfolioModel? _portfolio;

  // Bổ sung trạng thái loading
  bool _loading = false;
  bool get loading => _loading;

  PortfolioModel? get portfolio => _portfolio;

  /// Lắng nghe portfolio của user
  void listenPortfolio(String userId) {
    _loading = true; // bắt đầu loading
    notifyListeners();

    _db.collection('portfolios').doc(userId).snapshots().listen((doc) {
      if (doc.exists) {
        _portfolio = PortfolioModel.fromFirestore(doc.data()!, doc.id);
      } else {
        _portfolio = null;
      }
      _loading = false; // kết thúc loading
      notifyListeners();
    });
  }

  /// Cập nhật portfolio khi có giao dịch
  Future<void> updatePortfolio({
    required String userId,
    required String stockId,
    required String type, // BUY | SELL
    required int quantity,
    required double price,
  }) async {
    final docRef = _db.collection('portfolios').doc(userId);
    final snapshot = await docRef.get();

    Map<String, dynamic> data;
    List<Map<String, dynamic>> stocks = [];

    if (snapshot.exists) {
      data = snapshot.data()!;
      stocks = List<Map<String, dynamic>>.from(data['stocks'] ?? []);
    }

    // tìm stock trong portfolio
    final index = stocks.indexWhere((s) => s['stockId'] == stockId);

    if (index == -1 && type == "BUY") {
      // Mua mới
      stocks.add({
        'stockId': stockId,
        'quantity': quantity,
        'avgPrice': price,
      });
    } else if (index != -1) {
      final current = stocks[index];
      final oldQty = current['quantity'];
      final oldAvgPrice = current['avgPrice'];

      if (type == "BUY") {
        final newQty = oldQty + quantity;
        final newAvg = ((oldQty * oldAvgPrice) + (quantity * price)) / newQty;
        stocks[index] = {
          'stockId': stockId,
          'quantity': newQty,
          'avgPrice': newAvg,
        };
      } else if (type == "SELL") {
        final newQty = oldQty - quantity;
        if (newQty > 0) {
          stocks[index] = {
            'stockId': stockId,
            'quantity': newQty,
            'avgPrice': oldAvgPrice,
          };
        } else {
          stocks.removeAt(index);
        }
      }
    }

    final newData = {
      'stocks': stocks,
      'totalValue': stocks.fold<double>(
        0,
        (sum, s) => sum + (s['quantity'] * s['avgPrice']),
      ),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(newData, SetOptions(merge: true));
  }
}
