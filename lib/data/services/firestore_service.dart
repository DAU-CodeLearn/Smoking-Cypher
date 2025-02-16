import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 채팅방 목록 가져오기 (Firestore에 'chatRooms' 컬렉션이 있어야 함)
  Stream<QuerySnapshot> getChatRooms() {
    return _db.collection('chatRooms').snapshots();
  }

  // 특정 채팅방의 메시지 가져오기
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _db
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 특정 채팅방에 메시지 전송하기
  Future<void> sendMessage(String chatRoomId, String message, String sender) async {
    await _db
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'text': message,
      'sender': sender,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // 채팅방 생성 기능: 생성된 채팅방의 Document ID 반환
  Future<String> createChatRoom(String roomName) async {
    DocumentReference docRef = await _db.collection('chatRooms').add({
      'name': roomName,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // 채팅방 수정 기능: 채팅방 이름 업데이트
  Future<void> updateChatRoom(String chatRoomId, String newRoomName) async {
    await _db.collection('chatRooms').doc(chatRoomId).update({
      'name': newRoomName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 채팅방 삭제 기능: 채팅방 문서 삭제
  Future<void> deleteChatRoom(String chatRoomId) async {
    await _db.collection('chatRooms').doc(chatRoomId).delete();
  }
}
