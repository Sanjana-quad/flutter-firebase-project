import 'dart:ui';
import 'package:antidoom/models/deck.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ui_settings_provider.dart';

class DecoratedScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;

  const DecoratedScaffold({super.key, required this.child, this.appBar, required FloatingActionButton floatingActionButton, required StreamBuilder<List<Deck>> body});

  @override
  Widget build(BuildContext context) {
    final uiSettings = Provider.of<UISettingsProvider>(context).settings;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              uiSettings.backgroundAsset,
              fit: BoxFit.cover,
            ),
          ),

          // Optional blur + tint overlay for legibility
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black.withOpacity(0.25),
              ),
            ),
          ),

          // Main content inside SafeArea and padding
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
