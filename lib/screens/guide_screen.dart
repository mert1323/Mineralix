import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mineral_provider.dart';
import '../widgets/mineral_card.dart';
import 'mineral_detail_screen.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MineralProvider>();
    final minerals = provider.minerals;
    final categories = provider.categories;
    final selectedCategory = provider.selectedCategory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mineral Kitapçığı'),
      ),
      body: Column(
        children: [
          if (provider.error != null)
            MaterialBanner(
              content: Text(provider.error!),
              actions: [
                TextButton(
                  onPressed: provider.loadFromMta,
                  child: const Text('Tekrar dene'),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              hintText: 'Mineral ara...',
              leading: const Icon(Icons.search),
              onChanged: provider.setSearchQuery,
              elevation: WidgetStateProperty.all(1),
            ),
          ),
          if (categories.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isSelected = selectedCategory == null;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Tümü'),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) provider.setCategory(null);
                        },
                      ),
                    );
                  }
                  final category = categories[index - 1];
                  final isSelected = selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (val) {
                        provider.setCategory(val ? category : null);
                      },
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${selectedCategory ?? "Tüm Mineraller"} (${minerals.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          Expanded(
            child: provider.isLoading && minerals.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : minerals.isEmpty
                    ? const Center(child: Text('Sonuç bulunamadı'))
                    : ListView.builder(
                        itemCount: minerals.length,
                        itemBuilder: (context, index) {
                          final mineral = minerals[index];
                          return MineralCard(
                            mineral: mineral,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MineralDetailScreen(mineral: mineral),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
