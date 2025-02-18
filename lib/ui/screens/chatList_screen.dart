import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';
import '../../providers/chat_provider.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext outerContext) {
    final chatProvider = Provider.of<ChatProvider>(outerContext, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("채팅방 목록"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("채팅방이 없습니다."));
          }

          final rooms = snapshot.data!.docs;
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              final data = room.data() as Map<String, dynamic>;
              final roomCode = data['code'] ?? '알 수 없는 코드';
              return ListTile(
                title: Text("채팅방 코드: $roomCode"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(chatRoomId: room.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'createChat',
            onPressed: () async {
              String chatRoomCode = await chatProvider.generateChatRoom();
              Navigator.push(
                outerContext,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(chatRoomId: chatRoomCode),
                ),
              );
            },
            child: Icon(Icons.add),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'joinChat',
            onPressed: () => _showJoinChatRoomDialog(outerContext, chatProvider),
            child: Icon(Icons.meeting_room),
          ),
        ],
      ),
    );
  }

  void _showJoinChatRoomDialog(BuildContext outerContext, ChatProvider chatProvider) {
    String chatRoomCode = '';
    showDialog(
      context: outerContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('채팅방 입장'),
          content: TextField(
            decoration: InputDecoration(hintText: '채팅방 코드 입력'),
            onChanged: (value) {
              chatRoomCode = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                bool exists = await chatProvider.joinChatRoom(chatRoomCode.trim());
                Navigator.pop(context);
                if (exists) {
                  Navigator.push(
                    outerContext,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(chatRoomId: chatRoomCode.trim()),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(outerContext).showSnackBar(
                    SnackBar(content: Text("잘못된 코드입니다. 다시 시도해주세요.")),
                  );
                }
              },
              child: Text('입장'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }
}
