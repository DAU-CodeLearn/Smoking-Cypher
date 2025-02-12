import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/auth_service.dart'; // ✅ AuthService 불러오기

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService(); // ✅ AuthService 인스턴스 사용
  User? _user;

  User? get user => _user;

  bool get isLoggedIn => _user != null; // ✅ 로그인 여부 확인

  Future<void> signInWithGoogle() async {
    _user = await _authService.signInWithGoogle(); // ✅ AuthService의 로그인 메서드 호출
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
