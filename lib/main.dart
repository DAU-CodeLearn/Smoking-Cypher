import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smoking_cypher/providers/auth_provider.dart' as local_auth; // ✅ 별칭 추가
import 'package:smoking_cypher/ui/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => local_auth.AuthProvider()), // ✅ 별칭 사용
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
      home: MainScreen(), // ✅ 메인 화면 실행
    );
  }
}
