import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/deck.dart';
import '../models/ui_settings.dart';
import '../providers/ui_settings_provider.dart';

class DeckTile extends StatelessWidget {
  final Deck deck;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const DeckTile({super.key, required this.deck, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final ui = Provider.of<UISettingsProvider>(context).settings;
    switch (ui.tileEffect) {
      case TileEffect.glass:
        return _glassTile(context);
      case TileEffect.neumorphism:
        return _neumorphismTile(context);
      case TileEffect.gradient:
        return _gradientTile(context);
      case TileEffect.elevated:
      default:
        return _elevatedTile(context);
    }
  }

  Widget _elevatedTile(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: _tileContent(context),
      ),
    );
  }

  Widget _glassTile(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.white.withOpacity(0.12),
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: _tileContent(context),
          ),
        ),
      ),
    );
  }

  Widget _neumorphismTile(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
          BoxShadow(color: Colors.black12, offset: Offset(6, 6), blurRadius: 12),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        onLongPress: onLongPress,
        child: _tileContent(context),
      ),
    );
  }

  Widget _gradientTile(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo.shade300, Colors.purple.shade300]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: _tileContent(context, useWhiteText: true),
      ),
    );
  }

  Widget _tileContent(BuildContext context, {bool useWhiteText = false}) {
    final titleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: useWhiteText ? Colors.white : Colors.black87);
    final subtitleStyle = TextStyle(color: useWhiteText ? Colors.white70 : Colors.black54);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Row(
        children: [
          Icon(Icons.book, size: 36, color: useWhiteText ? Colors.white70 : Colors.indigo),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(deck.title, style: titleStyle),
                const SizedBox(height: 6),
                Text(deck.description ?? 'No description', style: subtitleStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
