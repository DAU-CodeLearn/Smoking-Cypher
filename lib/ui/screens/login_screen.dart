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
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen()),
                );
              });
            }

            return ElevatedButton(
              onPressed: () async {
                await authProvider.signInWithGoogle();
              },
              child: Text("구글 로그인"),
            );
          },
        ),
      ),
    );
  }
}
