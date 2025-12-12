import 'package:flutter/material.dart';
import '../models/ui_settings.dart';
import '../services/settings_service.dart';

class UISettingsProvider extends ChangeNotifier {
  UISettings _settings;
  final SettingsService _service;

  UISettingsProvider(this._settings, this._service);

  UISettings get settings => _settings;

  Future<void> updateBackground(String asset) async {
    _settings = _settings.copyWith(backgroundAsset: asset);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateTileEffect(TileEffect effect) async {
    _settings = _settings.copyWith(tileEffect: effect);
    await _service.save(_settings);
    notifyListeners();
  }
}
