class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String? stockId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.stockId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      userId: data['userId'],
      title: data['title'],
      message: data['message'],
      stockId: data['stockId'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as DateTime),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'stockId': stockId,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }
}
