import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/mineral.dart';

class MineralImage extends StatelessWidget {
  final Mineral mineral;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const MineralImage({
    super.key,
    required this.mineral,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12);
    final theme = Theme.of(context);

    Widget image;
    if (mineral.imageUrl != null && mineral.imageUrl!.startsWith('assets/')) {
      image = Image.asset(
        mineral.imageUrl!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _Fallback(name: mineral.name, theme: theme),
      );
    } else if (mineral.imageUrl != null) {
      image = CachedNetworkImage(
        imageUrl: mineral.imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _LoadingPlaceholder(
          width: width,
          height: height,
          theme: theme,
        ),
        errorWidget: (context, url, error) => _Fallback(name: mineral.name, theme: theme),
      );
    } else {
      return _Fallback(
        name: mineral.name,
        theme: theme,
        width: width,
        height: height,
        borderRadius: radius,
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(width: width, height: height, child: image),
    );
  }
}

class _Fallback extends StatelessWidget {
  final String name;
  final ThemeData theme;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const _Fallback({
    required this.name,
    required this.theme,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.8),
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final ThemeData theme;

  const _LoadingPlaceholder({
    required this.width,
    required this.height,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: theme.colorScheme.surfaceContainerHighest,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
