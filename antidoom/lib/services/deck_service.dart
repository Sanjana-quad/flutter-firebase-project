import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/deck.dart';

class DeckService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;

  DeckService({required this.userId});

  CollectionReference<Map<String, dynamic>> get _decksRef {
    return _db.collection('users').doc(userId).collection('decks');
  }

  Stream<List<Deck>> streamDecks() {
    return _decksRef
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Deck.fromDocument(doc))
          .toList();
    });
  }

  Future<void> createDeck({
    required String title,
    String? description,
  }) async {
    final now = DateTime.now();
    await _decksRef.add({
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  Future<void> updateDeck({
    required String deckId,
    required String title,
    String? description,
  }) async {
    await _decksRef.doc(deckId).update({
      'title': title,
      'description': description,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteDeck(String deckId) async {
    await _decksRef.doc(deckId).delete();
  }
}
