import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GalleryService {
  static final _db = FirebaseFirestore.instance;

  static Stream<QuerySnapshot<Map<String, dynamic>>> getItems({
    String? category,
  }) {
    final baseQuery = _db
        .collection('gallery')
        .orderBy('createdAt', descending: true);

    if (category == null || category == 'all') {
      return baseQuery.snapshots();
    }

    return baseQuery
        .where('tags', arrayContains: category)
        .snapshots();
  }

  static Future<void> createItem({
    required String imageUrl,
    required String caption,
    required List<String> tags,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    await _db.collection('gallery').add({
      'imageUrl': imageUrl,
      'caption': caption,
      'tags': tags,
      'ownerUid': user?.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteItem(String id) async {
    await _db.collection('gallery').doc(id).delete();
  }

  static Future<void> updateItem({
    required String id,
    required String imageUrl,
    required String caption,
    required List<String> tags,
  }) async {
    await _db.collection('gallery').doc(id).update({
      'imageUrl': imageUrl,
      'caption': caption,
      'tags': tags,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
