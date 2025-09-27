import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockapp/models/stock_model.dart';
import '../models/portfolio_model.dart';

class PortfolioProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  PortfolioModel? _portfolio;

  // Bổ sung trạng thái loading
  bool _loading = false;
  bool get loading => _loading;

  PortfolioModel? get portfolio => _portfolio;

  /// Lắng nghe portfolio của user
  void listenPortfolio(String? userId) {
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      _db.collection('portfolios').doc(userId).snapshots().listen((doc) {
        if (doc.exists) {
          _portfolio = PortfolioModel.fromFirestore(doc.data()!, doc.id);
        } else {
          _portfolio = null;
        }
        _loading = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      });
  }

   /// Fetch thẳng từ Firestore 1 lần (dùng khi mở popup lần đầu)
  Future<PortfolioModel?> fetchPortfolioOnce(String? userId) async {
    _loading = true;
    notifyListeners();

    try {
      final doc = await _db.collection('portfolios').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        _portfolio = PortfolioModel.fromFirestore(doc.data()!, doc.id);
        notifyListeners();
        return _portfolio;
      } else {
        _portfolio = null;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _portfolio = null;
      notifyListeners();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Cập nhật portfolio khi có giao dịch Mua/Bán
  Future<void> tradeStock({
  required String? userId,
  required String stockId,
  required String type, // BUY | SELL
  required int quantity,
  required double price,
}) async {
  final userRef = _db.collection('users').doc(userId);
  final portfolioRef = _db.collection('portfolios').doc(userId);
  final txRef = _db.collection('transactions');

  final userSnap = await userRef.get();
  if (!userSnap.exists) {
    throw Exception("User không tồn tại");
  }

  double balance = (userSnap.data()?['balance'] ?? 0).toDouble();

  // Lấy portfolio
  final portfolioSnap = await portfolioRef.get();
  List<Map<String, dynamic>> stocks = [];
  if (portfolioSnap.exists) {
    stocks = List<Map<String, dynamic>>.from(portfolioSnap.data()?['stocks'] ?? []);
  }

  final index = stocks.indexWhere((s) => s['stockId'] == stockId);

  if (type == "BUY") {
    final cost = price * quantity;
    if (balance < cost) {
      throw Exception("Không đủ tiền để mua cổ phiếu");
    }

    // Cập nhật stocks
    if (index == -1) {
      stocks.add({
        'stockId': stockId,
        'quantity': quantity,
        'avgPrice': price,
      });
    } else {
      final current = stocks[index];
      final oldQty = current['quantity'];
      final oldAvgPrice = current['avgPrice'];

      final newQty = oldQty + quantity;
      final newAvg = ((oldQty * oldAvgPrice) + (quantity * price)) / newQty;

      stocks[index] = {
        'stockId': stockId,
        'quantity': newQty,
        'avgPrice': newAvg,
      };
    }

    // Trừ tiền trong users
    balance -= cost;
  } else if (type == "SELL") {
    if (index == -1) {
      throw Exception("Không đủ cổ phiếu để bán");
    }

    final current = stocks[index];
    final oldQty = current['quantity'];
    final oldAvgPrice = current['avgPrice'];

    if (oldQty < quantity) {
      throw Exception("Không đủ cổ phiếu để bán");
    }

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

    // Cộng tiền vào users
    balance += price * quantity;
  }

  // Cập nhật users balance
  await userRef.update({'balance': balance, 'updatedAt': FieldValue.serverTimestamp()});

  // Cập nhật portfolio
  final portfolioData = {
    'stocks': stocks,
    'totalValue': stocks.fold<double>(
      0,
      (sum, s) => sum + (s['quantity'] * s['avgPrice']),
    ),
    'updatedAt': FieldValue.serverTimestamp(),
  };
  await portfolioRef.set(portfolioData, SetOptions(merge: true));

   await txRef.add({
    'userId': userId,
    'stockId': stockId,
    'type': type,
    'quantity': quantity,
    'price': price,
    'total': quantity * price,
    'createdAt': FieldValue.serverTimestamp(),
  });


  notifyListeners();
}


  double calculateTotalValueRealtime(List<StockModel> stockList) {
    if (_portfolio == null || _portfolio!.stocks.isEmpty) return 0;

    double total = 0;
    for (var p in _portfolio!.stocks) {
      final stock = stockList.firstWhere(
        (s) => s.id == p.stockId,
        orElse: () => StockModel(
            id: p.stockId,
            symbol: '',
            name: '',
            price: 0,
            changePercent: 0,
            volume: 0,
            updatedAt: Timestamp.now(),
            logoUrl: '',
            history: []),
      );
      total += p.quantity * stock.price;
    }
    return total;
  }
}
