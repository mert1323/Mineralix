import 'package:flutter/material.dart';
import '../widgets/education_card.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eğitim')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          EducationCard(
            icon: Icons.fitness_center,
            title: 'Sertlik (Mohs Ölçeği)',
            description: 'Minerallerin çizilme direncini ölçen 1-10 arası ölçek',
            onTap: () => _showDetail(
              context,
              title: 'Mohs Sertlik Ölçeği',
              content: _hardnessContent,
            ),
          ),
          EducationCard(
            icon: Icons.brightness_high,
            title: 'Parlaklık (Luster)',
            description: 'Mineral yüzeyinin ışığı yansıtma şekli',
            onTap: () => _showDetail(
              context,
              title: 'Parlaklık Türleri',
              content: _lusterContent,
            ),
          ),
          EducationCard(
            icon: Icons.brush,
            title: 'Çizgi Rengi (Streak)',
            description: 'Mineralin çizildiğinde bıraktığı toz rengi',
            onTap: () => _showDetail(
              context,
              title: 'Çizgi Rengi (Streak)',
              content: _streakContent,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _hardnessContent = '''
Mohs sertlik ölçeği, 1812 yılında Friedrich Mohs tarafından geliştirilmiştir. Minerallerin birbirini çizme yeteneğine dayanır.

Ölçek (1-10):
• 1 - Talk: En yumuşak mineral, tırnakla çizilir
• 2 - Gips: Tırnakla çizilebilir
• 3 - Kalsit: Bakır parayla çizilir
• 4 - Florit: Çelik bıçakla zor çizilir
• 5 - Apatit: Çelik bıçakla çizilir
• 6 - Ortoklas: Çelik dosyayla çizilir
• 7 - Kuvars: Camı çizer
• 8 - Topaz
• 9 - Korund
• 10 - Elmas: En sert mineral

Pratik test: Taş camı çiziyorsa sertlik genellikle 5.5 ve üzeridir.''';

  static const _lusterContent = '''
Parlaklık, mineral yüzeyinin ışığı nasıl yansıttığını tanımlar.

Ana türler:
• Metalik: Metal gibi parlak (pirit, hematit, magnetit)
• Camsı (Vitreous): Cam gibi parlak ve şeffaf (kuvars, kalsit)
• Mat (Dull): Işığı dağıtır, parlak değil (talk, kaolin)
• İpek (Silky): İpeksi parlaklık (asbest)
• İnci (Pearly): İnci gibi (muskovit)
• Yağlı (Greasy): Yağlı görünüm (nefelin)

Parlaklık, mineral tanımında en önemli görsel özelliklerden biridir.''';

  static const _streakContent = '''
Çizgi rengi (streak), bir mineralin seramik plaka üzerinde çizildiğinde bıraktığı toz rengidir.

Önemli noktalar:
• Mineralin dış renginden farklı olabilir
• Hematit dışarıdan gri görünür ama kırmızı çizgi bırakır
• Pirit sarı renkte ama siyah-yeşil çizgi bırakır
• Kuvars genellikle beyaz çizgi bırakır

Test yöntemi: Seramik çizgi plakası (streak plate) kullanın. Minerali plaka üzerinde çizin ve toz rengini gözlemleyin.

Çizgi rengi, mineral tanımında çok güvenilir bir özelliktir çünkü dış görünümü etkileyen kirlilik veya oksidasyon çizgi rengini değiştirmez.''';
}
