import 'package:flutter/material.dart';
import '../models/mineral.dart';
import '../widgets/mineral_image.dart';

class MineralDetailScreen extends StatelessWidget {
  final Mineral mineral;

  const MineralDetailScreen({super.key, required this.mineral});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    String hardnessStr = mineral.hardness.toString();
    if (mineral.hardnessMax != null && mineral.hardnessMax != mineral.hardness) {
      hardnessStr = '${mineral.hardness} - ${mineral.hardnessMax}';
    }

    return Scaffold(
      appBar: AppBar(title: Text(mineral.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MineralImage(
              mineral: mineral,
              width: double.infinity,
              height: 250,
              borderRadius: BorderRadius.circular(16),
            ),
            const SizedBox(height: 20),
            Text(
              mineral.name,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            if (mineral.formula != null) ...[
              const SizedBox(height: 4),
              Text(
                mineral.formula!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              mineral.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            _PropertyCard(
              icon: Icons.fitness_center,
              title: 'Sertlik (Mohs)',
              value: hardnessStr,
            ),
            _PropertyCard(
              icon: Icons.brightness_high,
              title: 'Parlaklık',
              value: mineral.luster,
            ),
            if (mineral.colors.isNotEmpty)
              _PropertyCard(
                icon: Icons.palette,
                title: 'Renkler',
                value: mineral.colors.join(', '),
              ),
            if (mineral.streak != null)
              _PropertyCard(
                icon: Icons.gesture,
                title: 'Çizgi Rengi',
                value: mineral.streak!,
              ),
            if (mineral.crystalSystem != null)
              _PropertyCard(
                icon: Icons.hexagon_outlined,
                title: 'Kristal Sistemi',
                value: mineral.crystalSystem!,
              ),
            if (mineral.cleavage != null)
              _PropertyCard(
                icon: Icons.call_split,
                title: 'Dilinim',
                value: mineral.cleavage!,
              ),
            if (mineral.fracture != null)
              _PropertyCard(
                icon: Icons.broken_image,
                title: 'Kırılma',
                value: mineral.fracture!,
              ),
            if (mineral.specificGravity != null)
              _PropertyCard(
                icon: Icons.scale,
                title: 'Özgül Ağırlık',
                value: mineral.specificGravity.toString(),
              ),
            _PropertyCard(
              icon: Icons.explore,
              title: 'Manyetik',
              value: mineral.magnetic ? 'Evet' : 'Hayır',
            ),
            if (mineral.category != null)
              _PropertyCard(
                icon: Icons.category,
                title: 'Kategori',
                value: mineral.category!,
              ),
          ],
        ),
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _PropertyCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
