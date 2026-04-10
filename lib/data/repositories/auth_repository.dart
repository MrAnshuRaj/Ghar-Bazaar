import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ghar_bazaar/data/models/auth_session.dart';

class AuthRepository {
  AuthRepository({required bool firebaseEnabled})
    : _firebaseEnabled = firebaseEnabled {
    if (_firebaseEnabled) {
      unawaited(GoogleSignIn.instance.initialize());
    }
  }

  final bool _firebaseEnabled;

  AuthSession? get currentSession {
    if (!_firebaseEnabled) {
      return null;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    return AuthSession(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  Stream<AuthSession?> authStateChanges() {
    if (!_firebaseEnabled) {
      return Stream<AuthSession?>.value(null);
    }
    return FirebaseAuth.instance.authStateChanges().map((user) {
      if (user == null) {
        return null;
      }
      return AuthSession(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
    });
  }

  Future<AuthSession> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    _ensureFirebaseConfigured();
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
    await credential.user?.updateDisplayName(name.trim());
    final user = credential.user!;
    return AuthSession(
      uid: user.uid,
      email: user.email ?? email.trim(),
      displayName: name.trim(),
      photoUrl: user.photoURL,
    );
  }

  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _ensureFirebaseConfigured();
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final user = credential.user!;
    return AuthSession(
      uid: user.uid,
      email: user.email ?? email.trim(),
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  Future<AuthSession> signInWithGoogle() async {
    _ensureFirebaseConfigured();
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );
    final user = userCredential.user!;
    return AuthSession(
      uid: user.uid,
      email: user.email ?? account.email,
      displayName: user.displayName ?? account.displayName,
      photoUrl: user.photoURL ?? account.photoUrl,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _ensureFirebaseConfigured();
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    if (!_firebaseEnabled) {
      return;
    }
    await FirebaseAuth.instance.signOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }

  void _ensureFirebaseConfigured() {
    if (_firebaseEnabled) {
      return;
    }
    throw FirebaseAuthException(
      code: 'firebase-not-initialized',
      message:
          'Firebase is not initialized. Please verify your Firebase setup and try again.',
    );
  }

  void dispose() {}
}
