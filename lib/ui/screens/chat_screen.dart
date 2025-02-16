import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoking_cypher/providers/auth_provider.dart' as local;
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/firestore_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  ChatScreen({required this.chatRoomId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  void sendMessage() {  // 메시지를 전송하는 함수
    final authProvider = Provider.of<local.AuthProvider>(context, listen: false);
    final User? user = authProvider.user;

    if (user != null && messageController.text.isNotEmpty) {
      final senderName = user.displayName ?? 'Unknown';
      _firestoreService.sendMessage(
        widget.chatRoomId, // 해당 채팅방의 ID를 인자로 전달
        messageController.text, // 입력된 메시지
        senderName, // 전송자 이름
      );
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
              stream: _firestoreService.getMessages(widget.chatRoomId), // 채팅방 별 메시지 스트림
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
                    final data = (doc.data() as Map<String, dynamic>?) ?? {};
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
                    textInputAction: TextInputAction.send, // 키보드에서 '전송' 버튼을 보여줌
                    onSubmitted: (value) { // 엔터키 또는 전송 버튼 클릭 시 호출됨
                      sendMessage();
                    },
                  ),
                ),
                IconButton( // 아이콘 버튼을 눌러서도 전송 가능
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
