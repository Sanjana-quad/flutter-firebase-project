// lib/screens/deck_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/deck.dart';
import '../models/card_item.dart';
import '../services/card_service.dart';
import 'review_screen.dart';

class DeckDetailScreen extends StatelessWidget {
  final Deck deck;
  const DeckDetailScreen({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final cardService = CardService(userId: user.uid, deckId: deck.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_play),
            tooltip: 'Start review',
            onPressed: () async {
              // Navigate to review screen (it will handle empty deck)
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReviewScreen(userId: user.uid, deck: deck),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<CardItem>>(
        stream: cardService.streamCards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final cards = snapshot.data ?? [];

          if (cards.isEmpty) {
            return Center(
              child: Text('No cards yet. Tap + to add one.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final c = cards[i];
              return ListTile(
                title: Text(c.front),
                subtitle: Text(
                  c.back.length > 80 ? '${c.back.substring(0, 80)}...' : c.back,
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'delete') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete card'),
                          content: const Text('Are you sure?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await cardService.deleteCard(c.id);
                      }
                    } else if (value == 'edit') {
                      _showEditCardDialog(context, cardService, c);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCardDialog(context, cardService),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateCardDialog(BuildContext context, CardService cardService) {
    final frontController = TextEditingController();
    final backController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Card'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: frontController,
                decoration: const InputDecoration(labelText: 'Front (question)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter front' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: backController,
                decoration: const InputDecoration(labelText: 'Back (answer)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter back' : null,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final valid = formKey.currentState?.validate() ?? false;
              if (!valid) return;
              await cardService.createCard(front: frontController.text.trim(), back: backController.text.trim());
              // ignore: use_build_context_synchronously
              Navigator.of(ctx).pop();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditCardDialog(BuildContext context, CardService cardService, CardItem c) {
    final frontController = TextEditingController(text: c.front);
    final backController = TextEditingController(text: c.back);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Card'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: frontController,
                decoration: const InputDecoration(labelText: 'Front (question)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter front' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: backController,
                decoration: const InputDecoration(labelText: 'Back (answer)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter back' : null,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final valid = formKey.currentState?.validate() ?? false;
              if (!valid) return;
              await cardService.updateCard(cardId: c.id, front: frontController.text.trim(), back: backController.text.trim());
              // ignore: use_build_context_synchronously
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
