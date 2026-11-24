import 'package:flutter/material.dart';
import 'identify_screen.dart';
import 'guide_screen.dart';
import 'education_screen.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int tabIndex)? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.08),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mineralix',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mineralleri keşfet, tanı ve öğren',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 28),
              _WelcomeCard(theme: theme),
              const SizedBox(height: 28),
              Text(
                'Hızlı Erişim',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _QuickAccessButton(
                icon: Icons.search,
                title: 'Mineral Tanı',
                subtitle: 'Adım adım mineral tanıma sihirbazı',
                color: theme.colorScheme.primary,
                onTap: () {
                  if (onNavigate != null) {
                    onNavigate!(1);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const IdentifyScreen()),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              _QuickAccessButton(
                icon: Icons.menu_book,
                title: 'Mineral Kitapçığı',
                subtitle: 'Tüm mineralleri incele',
                color: theme.colorScheme.secondary,
                onTap: () {
                  if (onNavigate != null) {
                    onNavigate!(2);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GuideScreen()),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              _QuickAccessButton(
                icon: Icons.school,
                title: 'Eğitim',
                subtitle: 'Sertlik, parlaklık ve daha fazlası',
                color: theme.colorScheme.tertiary,
                onTap: () {
                  if (onNavigate != null) {
                    onNavigate!(3);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EducationScreen()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final ThemeData theme;

  const _WelcomeCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.diamond, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(
              'Hoş Geldiniz!',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Elinizdeki minerali tanımak için sihirbazı kullanın veya kitapçıktan bilgi edinin.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
