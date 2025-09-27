import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  Future<void> createUserDoc({
    required String uid,
    required String email,
    String? name,
    String? photoUrl,
    double initialBalance = 0,
  }) async {
    final docRef = _fs.collection('users').doc(uid);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      await docRef.set({
        'uid': uid,
        'name': name ?? '',
        'email': email,
        'photoUrl': photoUrl ?? '',
        'balance': initialBalance,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc(String uid) {
    return _fs.collection('users').doc(uid).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userDocStream(String uid) {
    return _fs.collection('users').doc(uid).snapshots();
  }

  Future<void> updateBalance(String uid, double newBalance) async {
    await _fs.collection('users').doc(uid).update({
      'balance': newBalance,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> incrementBalance(String uid, double delta) async {
    await _fs.collection('users').doc(uid).update({
      'balance': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addDoc(String collection, Map<String, dynamic> data, {String? docId}) async {
    if (docId != null) {
      await _fs.collection(collection).doc(docId).set(data);
    } else {
      await _fs.collection(collection).add(data);
    }
  }

  Future<void> updateDoc(String collection, String docId, Map<String, dynamic> data) async {
    await _fs.collection(collection).doc(docId).update(data);
  }

  Future<void> deleteDoc(String collection, String docId) async {
    await _fs.collection(collection).doc(docId).delete();
  }

  Stream<QuerySnapshot> listenCollection(String collection) {
    return _fs.collection(collection).snapshots();
  }

  Stream<DocumentSnapshot> listenDoc(String collection, String docId) {
    return _fs.collection(collection).doc(docId).snapshots();
  }

  Future<DocumentSnapshot> getDoc(String collection, String docId) async {
    return await _fs.collection(collection).doc(docId).get();
  }

  Future<QuerySnapshot> getCollection(String collection) async {
    return await _fs.collection(collection).get();
  }
}
