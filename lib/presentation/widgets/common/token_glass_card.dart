import 'dart:ui';

import 'package:flutter/material.dart';

/// Shared glass-like card used across all screens.
/// Keeps border radius + blur consistent and reduces styling duplication.
class TokenGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final double blurSigmaX;
  final double blurSigmaY;
  final double backgroundOpacity;
  final Color? backgroundColorOverride;
  final Color? borderColorOverride;

  const TokenGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 12,
    this.blurSigmaX = 12,
    this.blurSigmaY = 12,
    this.backgroundOpacity = 0.62,
    this.backgroundColorOverride,
    this.borderColorOverride,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final backgroundColor =
        (backgroundColorOverride ?? cs.surfaceContainerHighest)
            .withValues(alpha: backgroundOpacity);
    final borderColor =
        (borderColorOverride ?? cs.outlineVariant).withValues(alpha: 0.5);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigmaX, sigmaY: blurSigmaY),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
