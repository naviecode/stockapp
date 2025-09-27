import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Email register
  Future<UserCredential> registerWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return cred;
  }

  // Email sign in
  Future<UserCredential> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred;
  }

  // Google Sign-In (native)
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();

    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
  Future<void> updateUserDoc(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> signOut() => _auth.signOut();

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;
}
