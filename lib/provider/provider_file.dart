import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class ProviderState with ChangeNotifier {
  String _subject = '';
  late UserCredential _userCredential;
  String get subject => _subject;
  UserCredential get userCredential => _userCredential;
  void setUserCredential (UserCredential userCredential) {
    _userCredential = userCredential;
    notifyListeners();
  }
  void changeSubject (String subject, bool notify) {
    _subject = subject;
    if(notify) {
      notifyListeners();
    }
  }
}