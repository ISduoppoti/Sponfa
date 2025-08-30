import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthFailure implements Exception {
  final String message;
  AuthFailure(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? firebaseAuth,
                  FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  // Stream to listen to authentication changes
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  // Sign in with Email and Password
  Future<void> signInWithEmail({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
        throw AuthFailure('Invalid email or password');
      } else if (e.code == 'user-not-found') {
        throw AuthFailure('No user found with this email');
      } else if (e.code == 'too-many-requests') {
        throw AuthFailure('Too many attempts. Please try again later.');
      } else {
        throw AuthFailure('Something went wrong. (${e.code})');
      }
    }
  }

  // Sign up with Email and Password and add to Firestore
  Future<void> signUpWithEmail({required String email, required String password, required String firstName}) async {
    try {
      // Create the user with Firebase Auth
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the unique user ID (uid) from the created user
      final String? uid = userCredential.user?.uid;

      if (uid != null) {
        // Add user data to Firestore using the uid as the document ID
        await _firestore.collection('users').doc(uid).set({
          'email': email,
          'firstName': firstName,

          'createdAt': FieldValue.serverTimestamp(),
        });
        print('User successfully created and added to Firestore.');
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuth errors (e.g., weak password, email already in use)
      print('Firebase Auth Error: ${e.code}');
      rethrow; // Rethrow to let the UI handle the error
    } catch (e) {
      // Handle any other errors
      print('An unexpected error occurred: $e');
      rethrow;
    }
  }

Future<void> addCityToUser({required String city}) async {
  // Get the current user's UID
  final String? uid = _firebaseAuth.currentUser?.uid;

  if (uid != null) {
    try {
      // Use the document reference and the update() method
      await _firestore.collection('users').doc(uid).update({
        'city': city,
      });
      print('City added successfully!');
    } catch (e) {
      print('Error adding city: $e');
      rethrow;
    }
  } else {
    print('No user is currently signed in.');
  }
}

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // TODO: Implement Google, Apple Sign-In methods
  // Future<void> signInWithGoogle() async { ... }
}