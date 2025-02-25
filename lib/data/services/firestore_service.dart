import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ✅ 채팅방 목록 가져오기 (최신 채팅방이 위로 정렬)
  Stream<QuerySnapshot> getChatRooms() {
    return _db
        .collection('chatRooms')
        .orderBy('createdAt', descending: true) // 최신 채팅방이 먼저 나오도록 정렬
        .snapshots();
  }

  // ✅ 특정 채팅방의 메시지 가져오기
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _db
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true) // 최신 메시지가 위로 오도록 정렬
        .snapshots();
  }

  // ✅ 메시지 전송 (텍스트 & 이미지 지원)
  Future<void> sendMessage(String chatRoomId, String? text, String sender, {String? imageUrl}) async {
    if (text == null && imageUrl == null) return; // 둘 다 없으면 전송하지 않음

    await _db
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'text': text, // 텍스트 메시지
      'imageUrl': imageUrl, // 이미지 URL (없으면 null)
      'sender': sender,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ✅ 채팅방 생성 기능 (채팅방 ID 반환)
  Future<String> createChatRoom(String roomName) async {
    DocumentReference docRef = await _db.collection('chatRooms').add({
      'name': roomName,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // ✅ 채팅방 이름 수정 기능
  Future<void> updateChatRoom(String chatRoomId, String newRoomName) async {
    await _db.collection('chatRooms').doc(chatRoomId).update({
      'name': newRoomName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ 채팅방 삭제 기능 (채팅방 & 해당 채팅방의 모든 메시지 삭제)
  Future<void> deleteChatRoom(String chatRoomId) async {
    // 1. 채팅방 내 메시지 모두 삭제
    QuerySnapshot messagesSnapshot = await _db
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .get();

    for (var doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }

    // 2. 채팅방 삭제
    await _db.collection('chatRooms').doc(chatRoomId).delete();
  }

  // ✅ 이미지 업로드 기능 (Firebase Storage)
  Future<String?> uploadImage(File imageFile, String chatRoomId) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('chat_images/$chatRoomId/$fileName');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL(); // 업로드 후 URL 반환
    } catch (e) {
      print("❌ 이미지 업로드 실패: $e");
      return null;
    }
  }
}
