import 'package:antidoom/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:antidoom/widgets/decorated_scaffold.dart';

import '../models/deck.dart';
import '../services/deck_service.dart';
import 'deck_detail_screen.dart';
import '../widgets/deck_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize notifications when HomeScreen loads
    NotificationService().init().catchError((e) {
      debugPrint('Error initializing notifications: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // This shouldn't normally happen because of AuthGate,
      // but let's be safe.
      return const Scaffold(
        body: Center(child: Text('No user found. Please restart the app.')),
      );
    }

    final deckService = DeckService(userId: user.uid);

    return DecoratedScaffold(
      appBar: AppBar(
        title: const Text('Your Decks'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'logout') {
                await FirebaseAuth.instance.signOut();
              } else if (v == 'reminder') {
                // For MVP, schedule a daily reminder at 8 AM local time
                // Use id = 0 for daily reminder
                await NotificationService().scheduleDailyNotification(
                  id: 0,
                  title: 'FlashFocus • Review Today',
                  body:
                      'You have decks waiting — spend 10 minutes reviewing your cards.',
                  hour: 8,
                  minute: 0,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Daily reminder set at 8:00 AM'),
                  ),
                );
              } else if (v == 'cancel_reminder') {
                await NotificationService().cancel(0);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Daily reminder canceled')),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'reminder',
                child: Text('Set daily reminder (8:00 AM)'),
              ),
              PopupMenuItem(
                value: 'cancel_reminder',
                child: Text('Cancel daily reminder'),
              ),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
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
            return Center(child: Text('Error: ${snapshot.error}'));
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
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final deck = decks[index];
              return DeckTile(
                deck: deck,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DeckDetailScreen(deck: deck),
                  ),
                ),
                onLongPress: () async {
                  // existing delete logic
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
      child: const Icon(Icons.add),
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
                  decoration: const InputDecoration(labelText: 'Title'),
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
