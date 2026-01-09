import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign in failed');
    }
  }

  
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      
      final user = credential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': email.split('@')[0], 
          'userId': user.uid,
          'email': email,
          'rank': 'Unranked',
          'ukbiLevel': 'Pemula',
          'accuracy': 0.0,
          'totalScore': 0,
          'quizzesCompleted': 0,
          'correctAnswers': 0,
          'wrongAnswers': 0,
          'aboutMe': '',
          'hobbies': [],
          'avatarUrl': null,
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign up failed');
    }
  }

  
  Future<User?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: '482188310443-9b2preleajpl9pm1p8v5s3kg3mpt225b.apps.googleusercontent.com',
    );

   
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
    
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
    await _auth.signInWithCredential(credential);

    return userCredential.user;
  }


  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  
  String handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password terlalu lemah. Minimal 6 karakter.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan login.';
      case 'user-not-found':
        return 'Email tidak ditemukan.';
      case 'wrong-password':
        return 'Password salah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      default:
        return 'Terjadi kesalahan: ${e.message ?? 'tidak diketahui'}';
    }
  }
}
