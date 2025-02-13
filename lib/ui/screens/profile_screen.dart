import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart'; // 🔹 Firebase의 AuthProvider
import 'package:smoking_cypher/providers/auth_provider.dart' as local_auth; // ✅ 내 AuthProvider에 별칭 추가
import 'package:smoking_cypher/ui/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final local_auth.AuthProvider authProvider = Provider.of<local_auth.AuthProvider>(context, listen: false);
    final User? user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            user != null
                ? Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                SizedBox(height: 10),
                Text(
                  'Hello, ${user.displayName ?? "User"}!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await authProvider.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text("로그아웃", style: TextStyle(color: Colors.white)),
                ),
              ],
            )
                : Text(
              'You are not logged in!',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
