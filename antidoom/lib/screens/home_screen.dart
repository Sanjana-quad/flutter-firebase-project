import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/deck.dart';
import '../services/deck_service.dart';
import 'deck_detail_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // This shouldn't normally happen because of AuthGate,
      // but let's be safe.
      return const Scaffold(
        body: Center(
          child: Text('No user found. Please restart the app.'),
        ),
      );
    }

    final deckService = DeckService(userId: user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Decks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Deck>>(
        stream: deckService.streamDecks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final decks = snapshot.data ?? [];

          if (decks.isEmpty) {
            return const Center(
              child: Text('No decks yet. Tap + to create one!'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: decks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final deck = decks[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Colors.indigo.withOpacity(0.05),
                title: Text(deck.title),
                subtitle: deck.description != null && deck.description!.isNotEmpty
                    ? Text(deck.description!)
                    : const Text('No description'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DeckDetailScreen(deck: deck),
                      ),
                    );
                },
                onLongPress: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        title: const Text('Delete deck'),
                        content: Text(
                            'Are you sure you want to delete "${deck.title}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    await deckService.deleteDeck(deck.id);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateDeckDialog(context, deckService);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDeckDialog(BuildContext context, DeckService deckService) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('New Deck'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final isValid = formKey.currentState?.validate() ?? false;
                if (!isValid) return;

                await deckService.createDeck(
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                );

                // Close dialog
                // ignore: use_build_context_synchronously
                Navigator.of(ctx).pop();
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
