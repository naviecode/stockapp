class AiRecommendation {
  final String id;
  final String userId;
  final String stockId;
  final String recommendation; // BUY | SELL | HOLD
  final double confidence;
  final double targetPrice;
  final String analysis;
  final DateTime createdAt;

  AiRecommendation({
    required this.id,
    required this.userId,
    required this.stockId,
    required this.recommendation,
    required this.confidence,
    required this.targetPrice,
    required this.analysis,
    required this.createdAt,
  });

  factory AiRecommendation.fromFirestore(Map<String, dynamic> data, String id) {
    return AiRecommendation(
      id: id,
      userId: data['userId'],
      stockId: data['stockId'],
      recommendation: data['recommendation'],
      confidence: (data['confidence'] ?? 0).toDouble(),
      targetPrice: (data['targetPrice'] ?? 0).toDouble(),
      analysis: data['analysis'],
      createdAt: (data['createdAt'] as DateTime),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'stockId': stockId,
      'recommendation': recommendation,
      'confidence': confidence,
      'targetPrice': targetPrice,
      'analysis': analysis,
      'createdAt': createdAt,
    };
  }
}
