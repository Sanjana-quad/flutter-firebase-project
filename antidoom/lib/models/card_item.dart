// lib/models/card_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CardItem {
  final String id;
  final String front;
  final String back;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastReviewedAt;
  final int timesReviewed;
  final double? ease; // optional for future spaced rep

  CardItem({
    required this.id,
    required this.front,
    required this.back,
    required this.createdAt,
    required this.updatedAt,
    this.lastReviewedAt,
    required this.timesReviewed,
    this.ease,
  });

  factory CardItem.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CardItem(
      id: doc.id,
      front: data['front'] as String? ?? '',
      back: data['back'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastReviewedAt:
          data['lastReviewedAt'] != null ? (data['lastReviewedAt'] as Timestamp).toDate() : null,
      timesReviewed: (data['timesReviewed'] as num?)?.toInt() ?? 0,
      ease: (data['ease'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'front': front,
      'back': back,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastReviewedAt': lastReviewedAt != null ? Timestamp.fromDate(lastReviewedAt!) : null,
      'timesReviewed': timesReviewed,
      'ease': ease,
    };
  }
}
