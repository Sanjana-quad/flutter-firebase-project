// lib/screens/review_screen.dart
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';

import '../models/deck.dart';
import '../models/card_item.dart';
import '../services/card_service.dart';

class ReviewScreen extends StatefulWidget {
  final String userId;
  final Deck deck;
  const ReviewScreen({super.key, required this.userId, required this.deck});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late final CardService _cardService;
  List<CardItem> _cards = [];
  int _currentIndex = 0;
  bool _showBack = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cardService = CardService(userId: widget.userId, deckId: widget.deck.id);

    // Subscribe once to initial list (not streaming UI here; we want a static review set snapshot)
    _cardService.streamCards().first.then((cards) {
      if (mounted) {
        setState(() {
          _cards = cards;
          _loading = false;
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load cards: $e')));
      }
    });
  }

  void nextCard({required bool countedAsKnown}) async {
    if (_cards.isEmpty) return;

    final current = _cards[_currentIndex];

    // Mark reviewed in Firestore
    await _cardService.markReviewed(current.id, incrementBy: 1);

    setState(() {
      _showBack = false;
      // Move to next card; loop to start when finished
      _currentIndex = (_currentIndex + 1) % _cards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Review • ${widget.deck.title}')),
        body: const Center(child: Text('No cards to review. Add some cards first.')),
      );
    }

    final card = _cards[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Review • ${widget.deck.title}')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              'Card ${_currentIndex + 1} of ${_cards.length}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showBack = !_showBack;
                    });
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: SingleChildScrollView(
                        child: Text(
                          _showBack ? card.back : card.front,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_showBack)
              Text('Tap the card to reveal the answer.', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: !_showBack ? null : () async {
                      // Again (treat as reviewed but user failed to recall)
                      await _cardService.markReviewed(card.id, incrementBy: 1);
                      // For future SR, we might adjust 'ease' differently; for now both increment
                      if (mounted) {
                        setState(() {
                          _showBack = false;
                          _currentIndex = (_currentIndex + 1) % _cards.length;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: const Text('Again'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: !_showBack ? null : () async {
                      // Got it
                      await _cardService.markReviewed(card.id, incrementBy: 1);
                      if (mounted) {
                        setState(() {
                          _showBack = false;
                          _currentIndex = (_currentIndex + 1) % _cards.length;
                        });
                      }
                    },
                    child: const Text('Got it'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
