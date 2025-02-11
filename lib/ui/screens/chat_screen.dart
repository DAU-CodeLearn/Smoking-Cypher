import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoking_cypher/providers/auth_provider.dart' as local;
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/firestore_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  void sendMessage() {
    final authProvider = Provider.of<local.AuthProvider>(context, listen: false);
    final User? user = authProvider.user; // ✅ 타입을 User?로 지정

    if (user != null && messageController.text.isNotEmpty) {
      // ✅ user.displayName이 null이면 'Unknown' 사용
      final senderName = user.displayName ?? 'Unknown';

      _firestoreService.sendMessage(messageController.text, senderName);
      messageController.clear();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("채팅방")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestoreService.getMessages(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text("메시지가 없습니다."));
                }

                final messages = snapshot.data.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final doc = messages[index];
                    final data = (doc.data() as Map<String, dynamic>?) ?? {}; // ✅ 안전한 데이터 변환

                    return ListTile(
                      title: Text(data['text'] ?? ''),
                      subtitle: Text(data['sender'] ?? 'Unknown'),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      labelText: "메시지 입력",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
