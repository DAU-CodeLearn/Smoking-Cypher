import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  // ✅ 생성자에서 자동 로그인 상태 확인
  AuthProvider() {
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  // ✅ Google 로그인
  Future<void> signInWithGoogle() async {
    _user = await _authService.signInWithGoogle();
    notifyListeners();
  }

  // ✅ 로그아웃
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
