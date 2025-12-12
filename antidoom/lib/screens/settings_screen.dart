import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ui_settings_provider.dart';
import '../models/ui_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UISettingsProvider>(context);
    final settings = provider.settings;

    final bgOptions = [
      'assets/images/neuswanstein.jpg',
      'assets/images/anime-hunter-x-hunter-chrollo-lucilfer-wallpaper-preview.jpg',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Background', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: bgOptions.map((asset) {
              final selected = settings.backgroundAsset == asset;
              return GestureDetector(
                onTap: () => provider.updateBackground(asset),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(asset, width: 140, height: 90, fit: BoxFit.cover),
                    ),
                    if (selected)
                      Container(
                        width: 140,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black38,
                        ),
                        child: const Icon(Icons.check_circle, color: Colors.white, size: 36),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Tile Effect', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...TileEffect.values.map((e) {
            return RadioListTile<TileEffect>(
              value: e,
              groupValue: settings.tileEffect,
              title: Text(e.toString().split('.').last),
              onChanged: (val) {
                if (val != null) provider.updateTileEffect(val);
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
