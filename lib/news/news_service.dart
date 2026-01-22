import 'package:cloud_firestore/cloud_firestore.dart';

class NewsService {
  static final _db = FirebaseFirestore.instance;

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLatestNews() {
    return _db
        .collection('news')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots();
  }

  static Future<void> createNews({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    await _db.collection('news').add({
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
