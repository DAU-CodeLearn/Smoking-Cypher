import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // ✅ Firebase 추가
import 'package:provider/provider.dart';
import 'package:smoking_cypher/providers/auth_provider.dart';
import 'package:smoking_cypher/ui/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Flutter 엔진 초기화
  await Firebase.initializeApp(); // ✅ Firebase 초기화
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smoking Cypher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}
