import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/identify_provider.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class IdentifyScreen extends StatefulWidget {
  const IdentifyScreen({super.key});

  @override
  State<IdentifyScreen> createState() => _IdentifyScreenState();
}

class _IdentifyScreenState extends State<IdentifyScreen> {
  final PageController _pageController = PageController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  static const _colorOptions = [
    'beyaz', 'siyah', 'gri', 'kırmızı', 'turuncu',
    'sarı', 'yeşil', 'mavi', 'mor', 'pembe', 'kahverengi',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final provider = context.read<IdentifyProvider>();
    setState(() => _isLoading = true);

    try {
      final results = await _apiService.identify(
        hardness: provider.hardnessValue,
        luster: provider.luster!,
        magnetic: provider.magnetic!,
        colors: provider.colors,
      );

      if (!mounted) return;
      provider.reset();
      _pageController.jumpToPage(0);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(results: results),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IdentifyProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mineral Tanı'),
        actions: [
          TextButton(
            onPressed: () {
              provider.reset();
              _pageController.jumpToPage(0);
            },
            child: const Text('Sıfırla'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Adım ${provider.currentStep + 1}/${IdentifyProvider.totalSteps}',
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      '${((provider.currentStep + 1) / IdentifyProvider.totalSteps * 100).round()}%',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (provider.currentStep + 1) / IdentifyProvider.totalSteps,
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 6,
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {},
              children: [
                _StepCard(
                  question: 'Taş camı çiziyor mu?',
                  child: _YesNoOptions(
                    value: provider.scratchesGlass,
                    onChanged: provider.setScratchesGlass,
                  ),
                ),
                _StepCard(
                  question: 'Parlaklığı nedir?',
                  child: _LusterOptions(
                    value: provider.luster,
                    onChanged: provider.setLuster,
                  ),
                ),
                _StepCard(
                  question: 'Mıknatıs çekiyor mu?',
                  child: _YesNoOptions(
                    value: provider.magnetic,
                    onChanged: provider.setMagnetic,
                  ),
                ),
                _StepCard(
                  question: 'Rengi nedir?',
                  subtitle: 'Birden fazla seçebilirsiniz',
                  child: _ColorOptions(
                    options: _colorOptions,
                    selected: provider.colors,
                    onToggle: provider.toggleColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (provider.currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        provider.previousStep();
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Geri'),
                    ),
                  ),
                if (provider.currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: !provider.canGoNext || _isLoading
                        ? null
                        : () {
                            if (provider.isLastStep) {
                              _submit(context);
                            } else {
                              provider.nextStep();
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(provider.isLastStep ? 'Sonuçları Gör' : 'İleri'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String question;
  final String? subtitle;
  final Widget child;

  const _StepCard({
    required this.question,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ],
              const SizedBox(height: 24),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _YesNoOptions extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool> onChanged;

  const _YesNoOptions({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _OptionTile(
          label: 'Evet',
          icon: Icons.check_circle_outline,
          selected: value == true,
          onTap: () => onChanged(true),
        ),
        const SizedBox(height: 12),
        _OptionTile(
          label: 'Hayır',
          icon: Icons.cancel_outlined,
          selected: value == false,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class _LusterOptions extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChanged;

  const _LusterOptions({required this.value, required this.onChanged});

  static const _options = [
    ('metalik', 'Metalik', Icons.brightness_high),
    ('camsı', 'Camsı', Icons.water_drop_outlined),
    ('mat', 'Mat', Icons.texture),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _options
          .map(
            (opt) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OptionTile(
                label: opt.$2,
                icon: opt.$3,
                selected: value == opt.$1,
                onTap: () => onChanged(opt.$1),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ColorOptions extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const _ColorOptions({
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((color) {
          final isSelected = selected.contains(color);
          return FilterChip(
            label: Text(color),
            selected: isSelected,
            onSelected: (_) => onToggle(color),
            selectedColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            checkmarkColor: Theme.of(context).colorScheme.primary,
          );
        }).toList(),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.1)
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? theme.colorScheme.primary : null,
                ),
              ),
              const Spacer(),
              if (selected)
                Icon(Icons.check, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
