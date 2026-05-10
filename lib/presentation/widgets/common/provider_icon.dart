import 'package:flutter/material.dart';
import 'package:token_watch/domain/entities/provider_id.dart';

/// A branded avatar widget for an AI provider.
///
/// Shows a coloured circle with the provider's initial letter(s),
/// using the provider's well-known brand colour when possible.
class ProviderIcon extends StatelessWidget {
  final ProviderId providerId;
  final double radius;

  const ProviderIcon({
    super.key,
    required this.providerId,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: providerId.brandColor,
      child: Text(
        providerId.initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.85,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
    );
  }
}
