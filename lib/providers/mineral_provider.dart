import 'package:flutter/foundation.dart';
import '../models/mineral.dart';
import '../services/mta_service.dart';
import '../services/mineral_db_service.dart';

class MineralProvider extends ChangeNotifier {
  final MtaService _mtaService;
  final MineralDbService _dbService;

  List<Mineral> _minerals = [];
  List<String> _categories = [];
  String _searchQuery = '';
  String? _selectedCategory;
  Mineral? _selectedMineral;
  bool _isLoading = false;
  String? _error;
  bool _loaded = false;

  MineralProvider({MtaService? mtaService, MineralDbService? dbService})
      : _mtaService = mtaService ?? MtaService(),
        _dbService = dbService ?? MineralDbService() {
    _initData();
  }

  Future<void> _initData() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _minerals = await _dbService.loadAll();
      _categories = await _dbService.getCategories();
      if (_minerals.isEmpty) {
        await loadFromMta();
      } else {
        _loaded = true;
      }
    } catch (e) {
      await loadFromMta();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Mineral> get minerals {
    var filtered = _minerals;
    
    if (_selectedCategory != null) {
      filtered = filtered.where((m) => m.category == _selectedCategory).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((m) =>
              m.name.toLowerCase().contains(query) ||
              m.description.toLowerCase().contains(query) ||
              (m.formula?.toLowerCase().contains(query) ?? false) ||
              (m.mtaSlug?.toLowerCase().contains(query) ?? false))
          .toList();
    }
    
    return filtered;
  }

  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  List<String> get categories => _categories;
  Mineral? get selectedMineral => _selectedMineral;
  bool get isLoading => _isLoading;
  String? get error => _error;

  static List<Mineral> get sampleMinerals => _fallbackMinerals;

  Future<void> loadFromMta() async {
    try {
      final catalog = await _mtaService.fetchCatalog();
      _minerals = catalog.isNotEmpty ? catalog : _fallbackMinerals;
      _loaded = true;
    } catch (e) {
      _error = 'MTA verileri yüklenemedi';
      if (!_loaded) _minerals = _fallbackMinerals;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void selectMineral(Mineral mineral) {
    _selectedMineral = mineral;
    notifyListeners();
  }

  void clearSelection() {
    _selectedMineral = null;
    notifyListeners();
  }

  Mineral? findById(int id) {
    try {
      return _minerals.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  static final List<Mineral> _fallbackMinerals = [
    Mineral(
      id: 1,
      name: 'Kuvars',
      description: 'Silisyum dioksit minerali. Mohs 7 sertlikte, camsı parlaklığa sahiptir.',
      hardness: 7.0,
      luster: 'camsı',
      colors: const ['şeffaf', 'beyaz', 'pembe', 'mor'],
      magnetic: false,
      imageUrl: 'https://www.mta.gov.tr/v3.0/sayfalar/bilgi-merkezi/endustriyel-hammaddeler/kuvars.jpg',
      mtaSlug: 'kuvars',
      sourceUrl: 'https://www.mta.gov.tr/v3.0/bilgi-merkezi/kuvars',
    ),
    Mineral(
      id: 2,
      name: 'Hematit',
      description: 'Demir oksit minerali. Metalik parlaklığa sahip koyu renkli mineral.',
      hardness: 5.5,
      luster: 'metalik',
      colors: const ['kırmızı', 'gri', 'siyah'],
      magnetic: false,
      imageUrl: 'https://www.mta.gov.tr/v3.0/sayfalar/bilgi-merkezi/mineraller/xhematif.jpg',
      mtaSlug: 'hematit',
      sourceUrl: 'https://www.mta.gov.tr/v3.0/bilgi-merkezi/hematit',
    ),
    Mineral(
      id: 3,
      name: 'Magnetit',
      description: 'Manyetik özellik gösteren demir oksit minerali.',
      hardness: 6.0,
      luster: 'metalik',
      colors: const ['siyah'],
      magnetic: true,
      imageUrl: 'https://www.mta.gov.tr/v3.0/sayfalar/bilgi-merkezi/mineraller/manyetit.jpg',
      mtaSlug: 'manyet',
      sourceUrl: 'https://www.mta.gov.tr/v3.0/bilgi-merkezi/manyet',
    ),
    Mineral(
      id: 4,
      name: 'Kalsit',
      description: 'Kalsiyum karbonat minerali. Asit ile köpürür.',
      hardness: 3.0,
      luster: 'camsı',
      colors: const ['beyaz', 'sarı', 'turuncu'],
      magnetic: false,
      imageUrl: 'https://www.mta.gov.tr/v3.0/sayfalar/bilgi-merkezi/endustriyel-hammaddeler/kalsit.jpg',
      mtaSlug: 'kalsit',
      sourceUrl: 'https://www.mta.gov.tr/v3.0/bilgi-merkezi/kalsit',
    ),
    Mineral(
      id: 5,
      name: 'Pirit',
      description: 'Demir sülfür minerali. Metalik parlaklığı ile bilinir.',
      hardness: 6.5,
      luster: 'metalik',
      colors: const ['sarı', 'altın'],
      magnetic: false,
      imageUrl: 'https://www.mta.gov.tr/v3.0/sayfalar/bilgi-merkezi/mineraller/xpirit.jpg',
      mtaSlug: 'pirit',
      sourceUrl: 'https://www.mta.gov.tr/v3.0/bilgi-merkezi/pirit',
    ),
    Mineral(
      id: 6,
      name: 'Talk',
      description: 'En yumuşak minerallerden biri (Mohs 1).',
      hardness: 1.0,
      luster: 'mat',
      colors: const ['beyaz', 'yeşil', 'gri'],
      magnetic: false,
      imageUrl: 'https://www.mta.gov.tr/v3.0/sayfalar/bilgi-merkezi/endustriyel-hammaddeler/talk.jpg',
      mtaSlug: 'talk',
      sourceUrl: 'https://www.mta.gov.tr/v3.0/bilgi-merkezi/talk',
    ),
    Mineral(
      id: 7,
      name: 'Florit',
      description: 'Kalsiyum florür minerali. Çeşitli renklerde bulunur.',
      hardness: 4.0,
      luster: 'camsı',
      colors: const ['mor', 'yeşil', 'mavi', 'sarı'],
      magnetic: false,
      imageUrl: 'https://www.mta.gov.tr/v3.0/sayfalar/bilgi-merkezi/endustriyel-hammaddeler/fluorit.jpg',
      mtaSlug: 'fluorit',
      sourceUrl: 'https://www.mta.gov.tr/v3.0/bilgi-merkezi/fluorit',
    ),
    Mineral(
      id: 8,
      name: 'Grafit',
      description: 'Karbon minerali. Mat parlaklığa sahiptir.',
      hardness: 1.5,
      luster: 'mat',
      colors: const ['siyah', 'gri'],
      magnetic: false,
      imageUrl: 'https://www.mta.gov.tr/v3.0/sayfalar/bilgi-merkezi/endustriyel-hammaddeler/grafit.jpg',
      mtaSlug: 'grafit',
      sourceUrl: 'https://www.mta.gov.tr/v3.0/bilgi-merkezi/grafit',
    ),
  ];
}
