import 'package:shared_preferences/shared_preferences.dart';
import '../models/ui_settings.dart';

class SettingsService {
  static const _kBgKey = 'ui_bg';
  static const _kTileKey = 'ui_tile';

  Future<UISettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final bg = prefs.getString(_kBgKey) ?? 'assets/images/neuswanstein.jpg';
    final tileIndex = prefs.getInt(_kTileKey) ?? 0;
    return UISettings(backgroundAsset: bg, tileEffect: TileEffect.values[tileIndex]);
  }

  Future<void> save(UISettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBgKey, settings.backgroundAsset);
    await prefs.setInt(_kTileKey, settings.tileEffect.index);
  }
}


