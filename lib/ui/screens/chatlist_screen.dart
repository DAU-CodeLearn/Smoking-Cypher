import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';
import '../../data/services/firestore_service.dart';

class ChatListScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext outerContext) {
    return Scaffold(
      appBar: AppBar(
        title: Text("채팅방 목록"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getChatRooms(),
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
              final roomName = data['name'] ?? '채팅방 ${index + 1}';
              return ListTile(
                title: Text(roomName),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditChatRoomDialog(context, room.id, roomName);
                    } else if (value == 'delete') {
                      _showDeleteChatRoomDialog(context, room.id);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.settings),
                        title: Text("수정"),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text("삭제"),
                      ),
                    ),
                  ],
                ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateChatRoomDialog(outerContext),
        child: Icon(Icons.add),
      ),
    );
  }

  // 채팅방 생성 다이얼로그: 생성 후 ChatScreen으로 이동
  void _showCreateChatRoomDialog(BuildContext outerContext) {
    String chatRoomName = '';
    showDialog(
      context: outerContext,
      barrierDismissible: false, // 바깥 클릭으로 닫히지 않도록 설정
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('채팅방 생성'),
          content: TextField(
            decoration: InputDecoration(
              hintText: '채팅방 이름 입력',
            ),
            onChanged: (value) {
              chatRoomName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (chatRoomName.trim().isNotEmpty) {
                  try {
                    String newChatRoomId = await _firestoreService
                        .createChatRoom(chatRoomName.trim());
                    // 생성 성공 후 다이얼로그 닫기
                    Navigator.pop(dialogContext);
                    Navigator.pushReplacement(
                      outerContext,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatScreen(chatRoomId: newChatRoomId),
                      ),
                    );
                  } catch (e) {
                    print("채팅방 생성 오류: $e");
                  } finally {
                    // 작업 완료 후 반드시 다이얼로그 닫기
                    if (Navigator.canPop(dialogContext)) {
                      Navigator.pop(dialogContext);
                    }
                  }
                } else {
                  // 입력값이 없으면 다이얼로그 닫기
                  Navigator.pop(dialogContext);
                }
              },
              child: Text('생성'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }


  // 채팅방 수정 다이얼로그
  void _showEditChatRoomDialog(
      BuildContext outerContext, String chatRoomId, String currentName) {
    String newName = currentName;
    showDialog(
      context: outerContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('채팅방 수정'),
          content: TextField(
            decoration: InputDecoration(
              hintText: '새 채팅방 이름 입력',
            ),
            controller: TextEditingController(text: currentName),
            onChanged: (value) {
              newName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  if (newName.trim().isNotEmpty && newName != currentName) {
                    await _firestoreService
                        .updateChatRoom(chatRoomId, newName.trim());
                  }
                } catch (e) {
                  print("채팅방 수정 오류: $e");
                } finally {
                  Navigator.pop(context);
                }
              },
              child: Text('수정'),
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

  // 채팅방 삭제 다이얼로그
  void _showDeleteChatRoomDialog(BuildContext outerContext, String chatRoomId) {
    showDialog(
      context: outerContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('채팅방 삭제'),
          content: Text('이 채팅방을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await _firestoreService.deleteChatRoom(chatRoomId);
                } catch (e) {
                  print("채팅방 삭제 오류: $e");
                } finally {
                  Navigator.pop(context);
                }
              },
              child: Text('삭제'),
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
