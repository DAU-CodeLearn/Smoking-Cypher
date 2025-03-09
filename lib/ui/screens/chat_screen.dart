import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smoking_cypher/providers/auth_provider.dart' as local;
import 'package:intl/intl.dart'; // ✅ 시간 포맷을 위한 패키지 추가

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  ChatScreen({required this.chatRoomId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _picker = ImagePicker(); // 이미지 선택기 추가

  void sendMessage({String? imageUrl}) async {
    final authProvider = Provider.of<local.AuthProvider>(context, listen: false);
    final User? user = authProvider.user;

    if (user != null && (messageController.text.isNotEmpty || imageUrl != null)) {
      final senderName = user.displayName ?? user.email ?? 'Unknown'; // ✅ displayName이 없으면 email 사용
      await _firestoreService.sendMessage(
        widget.chatRoomId,
        messageController.text.isNotEmpty ? messageController.text : null,
        senderName,
        imageUrl: imageUrl, // 이미지 URL이 있을 경우 함께 저장
      );
      messageController.clear();
    }
  }

  Future<void> pickAndUploadImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    String? imageUrl = await _firestoreService.uploadImage(imageFile, widget.chatRoomId);

    if (imageUrl != null) {
      sendMessage(imageUrl: imageUrl);
    }
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('HH:mm').format(dateTime); // ✅ 시간 포맷 (예: 14:30)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("채팅방")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestoreService.getMessages(widget.chatRoomId),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text("메시지가 없습니다."));
                }

                final messages = snapshot.data.docs;
                final User? currentUser = FirebaseAuth.instance.currentUser;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final doc = messages[index];
                    final data = (doc.data() as Map<String, dynamic>?) ?? {};

                    bool isMe = currentUser?.displayName == data['sender']; // ✅ 본인의 메시지 여부 체크 (이름 기준)

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start, // ✅ 말풍선 정렬
                        children: [
                          if (!isMe) // ✅ 상대방 메시지일 경우, 프로필 아이콘 추가 가능
                            CircleAvatar(
                              child: Text(data['sender'][0]), // 이름의 첫 글자 표시
                              backgroundColor: Colors.grey[300],
                            ),
                          SizedBox(width: 5), // 아이콘과 메시지 간격

                          // ✅ Wrap을 사용하여 말풍선 크기를 유동적으로 조절
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  // 보낸 사람 이름
                                  Text(
                                    data['sender'] ?? 'Unknown',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                                  ),
                                  // 말풍선 UI
                                  Container(
                                    margin: EdgeInsets.only(top: 3),
                                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isMe ? Colors.blueAccent : Colors.grey[300],
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                        bottomLeft: isMe ? Radius.circular(12) : Radius.zero, // ✅ 내 메시지는 오른쪽 둥글게
                                        bottomRight: isMe ? Radius.zero : Radius.circular(12), // ✅ 상대 메시지는 왼쪽 둥글게
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min, // ✅ 텍스트 길이에 맞게 크기 조절
                                      children: [
                                        // 텍스트 메시지
                                        if (data['text'] != null)
                                          Text(
                                            data['text'],
                                            style: TextStyle(fontSize: 16, color: isMe ? Colors.white : Colors.black),
                                          ),
                                        // 이미지 메시지
                                        if (data['imageUrl'] != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 5),
                                            child: Image.network(data['imageUrl'], width: 200, height: 200),
                                          ),
                                        // 보낸 시간 (말풍선 아래 우측 정렬)
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            formatTimestamp(data['timestamp']),
                                            style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.black54),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // 입력 필드
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo),
                  onPressed: pickAndUploadImage,
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      labelText: "메시지 입력",
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) => sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
