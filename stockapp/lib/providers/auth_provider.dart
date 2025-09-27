import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authSvc = FirebaseAuthService();
  final FirestoreService _fs = FirestoreService();

  AppUser? user;
  bool loading = true;

  FirestoreService get fs => _fs;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    // Lấy user từ Firebase Auth
    _authSvc.authStateChanges().listen((fbUser) async {
      if (fbUser == null) {
        // Nếu không có session => clear user + SharedPreferences
        user = null;
        loading = false;
        await clearUserFromPrefs();
        notifyListeners();
      } else {
        // Đảm bảo user doc tồn tại
        await _fs.createUserDoc(
          uid: fbUser.uid,
          email: fbUser.email ?? '',
          name: fbUser.displayName,
          photoUrl: fbUser.photoURL,
        );

        // Lắng nghe thay đổi user doc
        _fs.userDocStream(fbUser.uid).listen((snap) async  {
          if (snap.exists && snap.data() != null) {
            user = AppUser.fromMap(snap.data()!);
            await saveUserToPrefs(user!);
          }
          loading = false;
          notifyListeners();
        });
      }
    });

    if (user == null) {
      await loadUserFromPrefs();
    }
  }

  Future<void> registerWithEmail(String email, String password) async {
    final cred = await _authSvc.registerWithEmail(email, password);
    await cred.user?.sendEmailVerification();
  }

  Future<void> signInWithEmail(String email, String password) async {
    final cred = await _authSvc.signInWithEmail(email, password);
    if (cred.user != null) {
      final fbUser = cred.user!;

      // Đảm bảo tạo user doc trên Firestore
      await _fs.createUserDoc(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
        name: fbUser.displayName,
        photoUrl: fbUser.photoURL,
      );

      // Lắng nghe user doc từ Firestore
      _fs.userDocStream(fbUser.uid).listen((snap) async {
        if (snap.exists && snap.data() != null) {
          user = AppUser.fromMap(snap.data()!);

          await saveUserToPrefs(user!);

          loading = false;
          notifyListeners();
        }
      });
    }
  }

  Future<void> refreshUser() async {
    if (user == null) return;

    try {
      final snap = await _fs.getUserDoc(user!.uid);
      if (snap.exists && snap.data() != null) {
        user = AppUser.fromMap(snap.data()!);

        await saveUserToPrefs(user!);

        notifyListeners();
      }
    } catch (e) {
      debugPrint("refreshUser error: $e");
    }
  }


  Future<void> signInWithGoogle() async {
    final userCred = await _authSvc.signInWithGoogle();
    if (userCred != null) {
      await _fs.createUserDoc(
        uid: userCred.user!.uid,
        email: userCred.user!.email ?? '',
        name: userCred.user!.displayName,
        photoUrl: userCred.user!.photoURL,
      );
      // Lưu uid vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', userCred.user!.uid);
    }
  }

  Future<void> updateName(String newName) async {
    if (user == null) return;

    user = user!.copyWith(name: newName); // cập nhật local
    notifyListeners();

    // Cập nhật Firestore
    await _authSvc.updateUserDoc(user!.uid, {'name': newName});

    // Cập nhật SharedPreferences
    await saveUserToPrefs(user!);
  }

  /// Cập nhật avatar (photoUrl)
  Future<void> updatePhotoUrl(String newUrl) async {
    if (user == null) return;

    user = user!.copyWith(photoUrl: newUrl); // cập nhật local
    notifyListeners();

    // Cập nhật Firestore
    await _authSvc.updateUserDoc(user!.uid, {'photoUrl': newUrl});

    // Cập nhật SharedPreferences
    await saveUserToPrefs(user!);
  }

  Future<void> signOut() async {
    await _authSvc.signOut();
    await clearUserFromPrefs();
    user = null;
    loading = false;
    notifyListeners();
  }
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    if (uid != null) {
      // lấy thêm thông tin khác từ prefs nếu bạn có lưu
      user = AppUser(
        uid: uid,
        email: prefs.getString('email') ?? '',
        name: prefs.getString('name'),
        photoUrl: prefs.getString('photoUrl'),
        balance: prefs.getDouble('balance') ?? 0,
      );
      loading = false;
      notifyListeners();
    } else {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> saveUserToPrefs(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', user.uid);
    await prefs.setString('email', user.email ?? '');
    await prefs.setString('name', user.name ?? '');
    await prefs.setString('photoUrl', user.photoUrl ?? '');
    await prefs.setDouble('balance', user.balance);
  }

  Future<void> clearUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }


}
