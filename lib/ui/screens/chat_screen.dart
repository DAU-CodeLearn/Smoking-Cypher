import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../data/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smoking_cypher/providers/auth_provider.dart' as local;

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
      final senderName = user.displayName ?? 'Unknown';
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
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final doc = messages[index];
                    final data = (doc.data() as Map<String, dynamic>?) ?? {};
                    return ListTile(
                      title: data['text'] != null ? Text(data['text'] ?? '') : null,
                      subtitle: Text(data['sender'] ?? 'Unknown'),
                      leading: data['imageUrl'] != null
                          ? Image.network(data['imageUrl']!, width: 100, height: 100)
                          : null,
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
