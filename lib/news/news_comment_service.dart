import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewsCommentService {
  static final _db = FirebaseFirestore.instance;

  static Stream<QuerySnapshot<Map<String, dynamic>>> getComments(String newsId) {
    return _db
        .collection('news')
        .doc(newsId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> addComment({
    required String newsId,
    required String content,
    String? userName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    
    await _db
        .collection('news')
        .doc(newsId)
        .collection('comments')
        .add({
          'content': content,
          'userName': userName ?? user?.email ?? '匿名',
          'userId': user?.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  static Future<void> deleteComment(String newsId, String commentId) async {
    final user = FirebaseAuth.instance.currentUser;
    
    final comment = await _db
        .collection('news')
        .doc(newsId)
        .collection('comments')
        .doc(commentId)
        .get();
    
    if (comment.data()?['userId'] == user?.uid || user?.uid == null) {
      await _db
          .collection('news')
          .doc(newsId)
          .collection('comments')
          .doc(commentId)
          .delete();
    }
  }
}
