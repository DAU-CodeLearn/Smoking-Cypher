import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getMessages() {
    return _db.collection('messages')
        .where('timestamp', isNotEqualTo: null) // 🔥 null 값 필터링 추가
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage(String text, String sender) async {
    await _db.collection('messages').add({
      'text': text,
      'sender': sender,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
