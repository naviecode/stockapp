import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String? photoUrl;
  final double balance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppUser({
    required this.uid,
    this.name,
    this.email,
    this.photoUrl,
    required this.balance,
    this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String,
      name: map['name'] as String?,
      email: map['email'] as String?,
      photoUrl: map['photoUrl'] as String?,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
  
  AppUser copyWith({
    String? name,
    String? photoUrl,
    double? balance,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      balance: balance ?? this.balance,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'balance': balance,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
