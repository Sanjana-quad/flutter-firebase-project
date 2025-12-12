enum TileEffect {
  elevated,
  glass,
  neumorphism,
  gradient,
}

class UISettings {
  final String backgroundAsset;
  final TileEffect tileEffect;

  UISettings({
    required this.backgroundAsset,
    required this.tileEffect,
  });

  UISettings copyWith({String? backgroundAsset, TileEffect? tileEffect}) {
    return UISettings(
      backgroundAsset: backgroundAsset ?? this.backgroundAsset,
      tileEffect: tileEffect ?? this.tileEffect,
    );
  }
}
