import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockapp/models/ai_recommendation_model.dart';
import '../models/ai_recommendation_model.dart';

class AiProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<AiRecommendation> _recommendations = [];

  List<AiRecommendation> get recommendations => _recommendations;

  /// Lắng nghe gợi ý AI theo user
  void listenRecommendations(String userId) {
    _db.collection('ai_recommendations')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _recommendations = snapshot.docs.map((doc) =>
          AiRecommendation.fromFirestore(doc.data(), doc.id)).toList();
      notifyListeners();
    });
  }

  /// Gọi AI (ở đây giả lập bằng random)
  Future<void> generateRecommendation({
    required String userId,
    required String stockId,
  }) async {
    // Giả lập AI: BUY/SELL/HOLD ngẫu nhiên
    final options = ['BUY', 'SELL', 'HOLD'];
    options.shuffle();
    final rec = options.first;

    final data = {
      'userId': userId,
      'stockId': stockId,
      'recommendation': rec,
      'confidence': 0.5 + (0.5 * (DateTime.now().second % 10) / 10),
      'targetPrice': 100 + DateTime.now().second.toDouble(),
      'analysis': "AI dự đoán ${rec == "BUY" ? "xu hướng tăng" : "chưa rõ"}",
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _db.collection('ai_recommendations').add(data);
  }
}
