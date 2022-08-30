import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// Current user
class CurrentUser {
  static int maxRecents = 10;
  static int maxQuestions = 20;
  static int maxForms = 5;

  // Get the users avatar
  static String? getAvatar() => FirebaseAuth.instance.currentUser!.photoURL;
  static String? getEmail() => FirebaseAuth.instance.currentUser!.email!;

  // Get the users display name
  static String? getDisplayName() =>
      FirebaseAuth.instance.currentUser!.displayName;

  // Get the current user
  static String? get() => sha1
      .convert(utf8.encode(FirebaseAuth.instance.currentUser!.email!))
      .toString();
}
