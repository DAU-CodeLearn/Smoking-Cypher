import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 채팅방 코드 생성
  String _generateChatRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // 새로운 채팅방 생성
  Future<String> generateChatRoom() async {
    final chatRoomCode = _generateChatRoomCode();
    final chatRoomRef = _firestore.collection('chats').doc(chatRoomCode);

    await chatRoomRef.set({
      'code': chatRoomCode,
      'createdAt': FieldValue.serverTimestamp(),
      'users': [_auth.currentUser?.uid],
    });

    return chatRoomCode;
  }

  // 채팅방 입장
  Future<bool> joinChatRoom(String chatRoomCode) async {
    final chatRoomRef = _firestore.collection('chats').doc(chatRoomCode);
    final chatRoomSnapshot = await chatRoomRef.get();

    if (chatRoomSnapshot.exists) {
      await chatRoomRef.update({
        'users': FieldValue.arrayUnion([_auth.currentUser?.uid]),
      });
      return true;
    }
    return false;
  }

  // 실시간 메시지 가져오기
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 메시지 전송
  Future<void> sendMessage(String chatRoomId, String message) async {
    if (message.trim().isEmpty) return;
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('chats').doc(chatRoomId).collection('messages').add({
      'text': message,
      'senderId': user.uid,
      'senderEmail': user.email,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
