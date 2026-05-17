import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }
  Stream<User?> getAuthStateChanges() {
    return _auth.authStateChanges();
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          username: username,
          isGuest: false,
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        return null;
      }
      return 'Failed to create user';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Password is too weak';
      } else if (e.code == 'email-already-in-use') {
        return 'Email already exists';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address';
      }
      return e.message ?? 'Signup failed';
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address';
      }
      return e.message ?? 'Login failed';
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  Future<String?> guestLogin() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;

      if (user != null) {
        UserModel guestUser = UserModel.createGuestUser(user.uid);
        await _firestore.collection('users').doc(user.uid).set(guestUser.toMap());
        return null;
      }
      return 'Failed to sign in as guest';
    } catch (e) {
      return 'Guest login failed: $e';
    }
  }

  Future<String?> forgotPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found with this email';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address';
      }
      return e.message ?? 'Failed to send reset email';
    } catch (e) {
      return 'An error occurred: $e';
    }
  }
  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
