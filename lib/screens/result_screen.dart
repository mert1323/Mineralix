import 'package:flutter/material.dart';
import '../models/mineral.dart';
import '../widgets/mineral_card.dart';
import 'mineral_detail_screen.dart';

class ResultScreen extends StatelessWidget {
  final List<IdentifyResult> results;

  const ResultScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tanı Sonuçları')),
      body: results.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Eşleşen mineral bulunamadı',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    '${results.length} olası eşleşme bulundu',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...results.map(
                  (result) => MineralCard(
                    mineral: result.mineral,
                    trailing: _MatchBadge(percentage: result.matchPercentage),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MineralDetailScreen(mineral: result.mineral),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  final double percentage;

  const _MatchBadge({required this.percentage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = percentage >= 70
        ? Colors.green
        : percentage >= 40
            ? theme.colorScheme.tertiary
            : theme.colorScheme.outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '%${percentage.round()}',
        style: theme.textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
