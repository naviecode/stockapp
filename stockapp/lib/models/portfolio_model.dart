import 'package:cloud_firestore/cloud_firestore.dart';

class PortfolioStock {
  final String stockId;
  final int quantity;
  final double avgPrice;
  final String? logoUrl;

  PortfolioStock({
    required this.stockId,
    required this.quantity,
    required this.avgPrice,
    this.logoUrl,
  });

  factory PortfolioStock.fromMap(Map<String, dynamic> data) {
    return PortfolioStock(
      stockId: data['stockId'],
      quantity: data['quantity'],
      avgPrice: (data['avgPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stockId': stockId,
      'quantity': quantity,
      'avgPrice': avgPrice,
    };
  }
  String get localLogoPath => "assets/logos/${stockId.toLowerCase()}.png";
}

class PortfolioModel {
  final String userId;
  final List<PortfolioStock> stocks;
  final double totalValue;
  final DateTime updatedAt;

  PortfolioModel({
    required this.userId,
    required this.stocks,
    required this.totalValue,
    required this.updatedAt,
  });

  factory PortfolioModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PortfolioModel(
      userId: id,
      stocks: (data['stocks'] as List<dynamic>)
          .map((e) => PortfolioStock.fromMap(e))
          .toList(),
      totalValue: (data['totalValue'] ?? 0).toDouble(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stocks': stocks.map((e) => e.toMap()).toList(),
      'totalValue': totalValue,
      'updatedAt': updatedAt,
    };
  }
  /// Bổ sung: Map tra cứu nhanh stockId -> PortfolioStock
  Map<String, PortfolioStock> get stockMap {
    return {for (var s in stocks) s.stockId: s};
  }

  /// Bổ sung: Lấy số lượng stock theo stockId, default = 0
  int quantityOf(String stockId) {
    return stockMap[stockId]?.quantity ?? 0;
  }
}
