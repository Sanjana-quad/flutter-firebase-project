// lib/services/card_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/card_item.dart';

class CardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;
  final String deckId;

  CardService({required this.userId, required this.deckId});

  CollectionReference<Map<String, dynamic>> get _cardsRef {
    return _db.collection('users').doc(userId).collection('decks').doc(deckId).collection('cards');
  }

  Stream<List<CardItem>> streamCards() {
    return _cardsRef
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => CardItem.fromDocument(d)).toList());
  }

  Future<void> createCard({
    required String front,
    required String back,
  }) async {
    final now = DateTime.now();
    await _cardsRef.add({
      'front': front,
      'back': back,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'lastReviewedAt': null,
      'timesReviewed': 0,
      'ease': null,
    });
  }

  Future<void> updateCard({
    required String cardId,
    String? front,
    String? back,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
    if (front != null) updates['front'] = front;
    if (back != null) updates['back'] = back;

    await _cardsRef.doc(cardId).update(updates);
  }

  Future<void> deleteCard(String cardId) async {
    await _cardsRef.doc(cardId).delete();
  }

  // Update review metadata: set lastReviewedAt to now and increment timesReviewed
  Future<void> markReviewed(String cardId, {int incrementBy = 1}) async {
    final now = Timestamp.fromDate(DateTime.now());
    final docRef = _cardsRef.doc(cardId);

    // Use transaction to be safe
    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;
      final currentTimes = (snap.data()?['timesReviewed'] as num?)?.toInt() ?? 0;
      tx.update(docRef, {
        'lastReviewedAt': now,
        'timesReviewed': currentTimes + incrementBy,
        'updatedAt': now,
      });
    });
  }
}
