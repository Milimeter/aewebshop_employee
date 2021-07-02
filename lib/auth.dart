import 'package:firebase_auth/firebase_auth.dart';

class Authentication {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static User user;
  static bool isLoggedIn = false;

  Future<String> SignUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
      isLoggedIn = true;
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'User not exists';
      } else if (e.code == 'wrong-password') {
        return 'Password does not match';
      }
    }
  }

  Future<String> Login(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
      isLoggedIn = true;
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'User not exists';
      } else if (e.code == 'wrong-password') {
        return 'Password does not match';
      }
    }
  }

  bool getCurrentUser() {
    if (user.email != "") {
      return true;
    } else {
      return false;
    }
  }

  bool get isLogged {
    return isLoggedIn;
  }

  String get userEmail {
    return user.email;
  }
}
