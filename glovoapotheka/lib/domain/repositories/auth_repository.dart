import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


// NOTE: Set up Firebase in your project

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? firebaseAuth,
                  FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;
        


  // Stream to listen to authentication changes
  Stream<User?> get user => _firebaseAuth.authStateChanges();


  Future<bool> checkEmailExists({required String email}) async {
    try {
      // ignore: deprecated_member_use
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      //final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      print(_firebaseAuth.app.options.projectId);
      print(methods);
      return methods.isNotEmpty;
    } catch (e) {
      // Handle exceptions
      print(e);
      rethrow;
    }
  }

  // Sign in with Email and Password
  Future<void> signInWithEmail({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      // Handle exceptions (e.g., user-not-found, wrong-password)
      print(e);
      rethrow;
    }
  }

  // Sign up with Email and Password
  Future<void> signUpWithEmail({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      // You can add user data to Firestore here
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // TODO: Implement Google, Apple Sign-In methods
  // Future<void> signInWithGoogle() async { ... }
}