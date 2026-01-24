import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GalleryCommentService {
  static final _db = FirebaseFirestore.instance;

  static Stream<QuerySnapshot<Map<String, dynamic>>> getComments(String galleryId) {
    return _db
        .collection('gallery')
        .doc(galleryId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> addComment({
    required String galleryId,
    required String content,
    String? userName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    
    await _db
        .collection('gallery')
        .doc(galleryId)
        .collection('comments')
        .add({
          'content': content,
          'userName': userName ?? user?.email ?? '匿名',
          'userId': user?.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  static Future<void> deleteComment(String galleryId, String commentId) async {
    final user = FirebaseAuth.instance.currentUser;
    
    final comment = await _db
        .collection('gallery')
        .doc(galleryId)
        .collection('comments')
        .doc(commentId)
        .get();
    
    if (comment.data()?['userId'] == user?.uid || user?.uid == null) {
      await _db
          .collection('gallery')
          .doc(galleryId)
          .collection('comments')
          .doc(commentId)
          .delete();
    }
  }
}
