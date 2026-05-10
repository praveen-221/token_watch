// Domain enum representing usage level with color mapping
import 'package:flutter/material.dart';

enum UsageLevel {
  healthy,
  approaching,
  nearLimit,
  exceeded,
  ;

  static UsageLevel fromPercent(double percent) {
    final p = percent.clamp(0.0, 100.0);
    if (p >= 100) return UsageLevel.exceeded;
    if (p >= 85) return UsageLevel.nearLimit;
    if (p >= 60) return UsageLevel.approaching;
    return UsageLevel.healthy;
  }

  Color get color {
    switch (this) {
      case UsageLevel.healthy:
        return const Color(0xFF22C55E); // green
      case UsageLevel.approaching:
        return const Color(0xFFEAB308); // yellow
      case UsageLevel.nearLimit:
        return const Color(0xFFEF4444); // red
      case UsageLevel.exceeded:
        return const Color(0xFF991B1B); // dark red
    }
  }
}
