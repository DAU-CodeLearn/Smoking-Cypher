import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smoking_cypher/providers/auth_provider.dart' as local_auth; // ✅ 별칭 추가

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<local_auth.AuthProvider>(context, listen: false); // ✅ 별칭 사용
    final User? user = authProvider.user; // 로그인된 사용자 정보 가져오기

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: user != null
            ? Text(
          'Hello, ${user.displayName ?? "User"}!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        )
            : Text(
          'You are not logged in!',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      ),
    );
  }
}
