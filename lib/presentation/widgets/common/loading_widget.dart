import 'package:flutter/material.dart';

class TokenLoadingWidget extends StatelessWidget {
  final double? height;
  final bool isFullPage;

  const TokenLoadingWidget({super.key, this.height, this.isFullPage = false});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    if (isFullPage) {
      return Center(child: CircularProgressIndicator(color: primary));
    }
    return SizedBox(
      height: height ?? 120,
      child: Center(child: CircularProgressIndicator(color: primary)),
    );
  }
}
