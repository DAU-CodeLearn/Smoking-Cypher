import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoking_cypher/providers/auth_provider.dart';
import 'chat_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // 로그인 후 자동 이동
            if (authProvider.user != null) {
              Future.microtask(() {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen()),
                );
              });
            }

            return ElevatedButton(
              onPressed: () async {
                _showLoginDialog(context, authProvider);
              },
              child: Text("구글 로그인"),
            );
          },
        ),
      ),
    );
  }

  void _showLoginDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      barrierDismissible: false, // 바깥 클릭으로 닫히지 않도록 설정
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("구글 로그인"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("구글 계정으로 로그인하시겠습니까?"),
              SizedBox(height: 20),
              CircularProgressIndicator(), // 로딩 애니메이션
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await authProvider.signInWithGoogle();

                // 로그인 성공 시 다이얼로그 닫기
                if (authProvider.user != null) {
                  Navigator.pop(context);
                }
              },
              child: Text("로그인"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 취소 버튼
              },
              child: Text("취소"),
            ),
          ],
        );
      },
    );
  }
}
