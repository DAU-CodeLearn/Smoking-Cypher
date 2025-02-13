import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoking_cypher/providers/auth_provider.dart';
import 'package:smoking_cypher/ui/screens/login_screen.dart';
import 'package:smoking_cypher/ui/screens/chat_screen.dart';
import 'package:smoking_cypher/ui/screens/profile_screen.dart';
import 'package:smoking_cypher/ui/widgets/bottom_bar.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 기본 선택: Home

  final List<Widget> _pages = [
    Center(child: Text('Home Screen')), // 홈 화면
    ChatScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // ✅ 로그인 여부 체크하여 채팅 및 프로필 제한
    if (!authProvider.isLoggedIn && (index == 1 || index == 2)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // 로그인 화면으로 이동
      );
      return; // 로그인하지 않았으면 선택된 탭을 변경하지 않음
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smoking Cypher'),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex], // 선택된 페이지 표시
      bottomNavigationBar: BottomNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
