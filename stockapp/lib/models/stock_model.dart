import 'package:cloud_firestore/cloud_firestore.dart';

class StockModel {
  final String id; // Firestore doc id
  final String symbol; // BTCUSDT
  final String name; // Tên (ví dụ "Bitcoin")
  final double price; // Giá mới nhất
  final double changePercent; // % biến động ngày
  final int volume; // Tổng khối lượng
  final String logoUrl;
  final List<PricePoint> history; // Lịch sử giá
  final Timestamp updatedAt;

  StockModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.volume,
    required this.logoUrl,
    required this.history,
    required this.updatedAt,
  });

  factory StockModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StockModel(
      id: doc.id,
      symbol: data['symbol'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      changePercent: (data['changePercent'] ?? 0).toDouble(),
      volume: (data['volume'] ?? 0).toInt(),
      history: data['history'] != null
          ? (data['history'] as List<dynamic>)
              .map((e) => PricePoint.fromMap(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      logoUrl: data['logoUrl'] ?? '',
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }
  
  StockModel copyWith({
    String? id,
    String? symbol,
    String? name,
    double? price,
    double? changePercent,
    int? volume,
    String? logoUrl,
    List<PricePoint>? history,
    Timestamp? updatedAt,
  }) {
    return StockModel(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      price: price ?? this.price,
      changePercent: changePercent ?? this.changePercent,
      volume: volume ?? this.volume,
      logoUrl: logoUrl ?? this.logoUrl,
      history: history ?? this.history,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  factory StockModel.fromMap(Map<String, dynamic> data, {String id = ''}) {
    return StockModel(
      id: id,
      symbol: data['symbol'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] as num).toDouble(),
      changePercent: (data['changePercent'] ?? 0).toDouble(),
      volume: (data['volume'] ?? 0).toInt(),
      history: (data['history'] as List<dynamic>?)
              ?.map((e) =>
                  PricePoint.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      logoUrl: data['logoUrl'] ?? '',
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'name': name,
      'price': price,
      'changePercent': changePercent,
      'volume': volume,
      'history': history.map((e) => e.toMap()).toList(),
      'updatedAt': updatedAt,
    };
  }
}

class PricePoint {
  final DateTime time;
  final double open;
  final double close;
  final double high;
  final double low;

  PricePoint({
    required this.time,
    required this.open,
    required this.close,
    required this.high,
    required this.low,
  });

  factory PricePoint.fromMap(Map<String, dynamic> data) {
    return PricePoint(
      time: DateTime.fromMillisecondsSinceEpoch(
          (data['time'] as int) * 1000,
          isUtc: true),
      open: (data['open'] ?? 0).toDouble(),
      close: (data['close'] ?? 0).toDouble(),
      high: (data['high'] ?? 0).toDouble(),
      low: (data['low'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time.millisecondsSinceEpoch ~/ 1000,
      'open': open,
      'close': close,
      'high': high,
      'low': low,
    };
  }
}
