class TransactionModel {
  final String id;
  final String userId;
  final String stockId;
  final String type; // BUY | SELL
  final int quantity;
  final double price;
  final double total;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.stockId,
    required this.type,
    required this.quantity,
    required this.price,
    required this.total,
    required this.createdAt,
  });

  factory TransactionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TransactionModel(
      id: id,
      userId: data['userId'],
      stockId: data['stockId'],
      type: data['type'],
      quantity: data['quantity'],
      price: (data['price'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as DateTime),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'stockId': stockId,
      'type': type,
      'quantity': quantity,
      'price': price,
      'total': total,
      'createdAt': createdAt,
    };
  }
}
