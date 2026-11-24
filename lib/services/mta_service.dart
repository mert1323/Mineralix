import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../models/mineral.dart';

class MtaService {
  static const String baseUrl = 'https://www.mta.gov.tr/v3.0';

  final http.Client _client;

  MtaService({http.Client? client}) : _client = client ?? http.Client();

  static const _featuredSlugs = [
    ('kuvars', 'Kuvars'),
    ('hematit', 'Hematit'),
    ('manyet', 'Magnetit'),
    ('kalsit', 'Kalsit'),
    ('pirit', 'Pirit'),
    ('talk', 'Talk'),
    ('fluorit', 'Florit'),
    ('grafit', 'Grafit'),
  ];

  Future<List<Mineral>> fetchCatalog() async {
    final slugs = await _fetchIndustrialSlugs();
    final featured = await Future.wait(
      _featuredSlugs.map((e) => fetchMineral(e.$1, displayName: e.$2)),
    );

    final featuredSlugs = _featuredSlugs.map((e) => e.$1).toSet();
    final extraSlugs = slugs.where((s) => !featuredSlugs.contains(s)).toList();

    final extras = extraSlugs.map((slug) => _stubMineral(slug)).toList();

    return [
      ...featured.whereType<Mineral>(),
      ...extras,
    ];
  }

  Future<Mineral?> fetchMineral(String slug, {String? displayName}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/bilgi-merkezi/$slug'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return null;

      final body = _decodeBody(response);
      final document = html_parser.parse(body);

      final title = document.querySelector('h1')?.text.trim() ??
          displayName ??
          _titleFromSlug(slug);
      final paragraphs = document
          .querySelectorAll('p')
          .map((e) => _cleanText(e.text))
          .where((t) => t.length > 40)
          .toList();

      final description = paragraphs.isNotEmpty
          ? paragraphs.take(3).join('\n\n')
          : '$title hakkında MTA bilgi merkezi verisi.';

      final imagePath = _extractImagePath(body);
      final imageUrl = imagePath != null ? '$baseUrl/$imagePath' : null;
      final fullText = paragraphs.join(' ');

      return Mineral(
        id: slug.hashCode.abs(),
        name: _normalizeTitle(title),
        description: description,
        hardness: _parseHardness(fullText, slug),
        luster: _parseLuster(fullText, slug),
        colors: _parseColors(fullText),
        magnetic: _parseMagnetic(fullText, slug),
        imageUrl: imageUrl,
        mtaSlug: slug,
        sourceUrl: '$baseUrl/bilgi-merkezi/$slug',
      );
    } catch (_) {
      return _stubMineral(slug, displayName: displayName);
    }
  }

  Future<List<String>> _fetchIndustrialSlugs() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/bilgi-merkezi/endustriyel-hammaddeler'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return [];

      final body = _decodeBody(response);
      final regex = RegExp(r'bilgi-merkezi/([a-z0-9\-]+)');
      final matches = regex.allMatches(body).map((m) => m.group(1)!).toSet();

      return matches
          .where((s) => !_ignoredSlugs.contains(s))
          .toList()
        ..sort();
    } catch (_) {
      return [];
    }
  }

  Mineral _stubMineral(String slug, {String? displayName}) {
    return Mineral(
      id: slug.hashCode.abs(),
      name: displayName ?? _titleFromSlug(slug),
      description: '${displayName ?? _titleFromSlug(slug)} — MTA bilgi merkezi.',
      hardness: _defaultHardness(slug),
      luster: _defaultLuster(slug),
      colors: const ['çeşitli'],
      magnetic: slug == 'manyet',
      imageUrl: _guessImageUrl(slug),
      mtaSlug: slug,
      sourceUrl: '$baseUrl/bilgi-merkezi/$slug',
    );
  }

  static const _ignoredSlugs = {
    'endustriyel-hammaddeler',
    'mineraller',
    'maden-kullanim-alanlari',
    'ekonomik-gostergeler',
    'heyelan',
    'il-maden-potansiyelleri',
    'kiymetli-taslar',
    'maden-arama-asamalari',
    'maden-dis-ticaret',
    'maden-dis-ticaret-aylik-veriler',
    'maden-serisi',
    'maden-yataklari',
    'nukleer-enerji-hammaddeler',
    'planlamada-yerbilim-verileri',
    'son-depremler',
    'turkiyenin-deprem-potansiyeli',
  };

  String? _extractImagePath(String html) {
    final regex = RegExp(
      r'''(?:src|href)=["'](sayfalar/bilgi-merkezi/[^"']+\.(?:jpg|jpeg|png))["']''',
      caseSensitive: false,
    );
    final match = regex.firstMatch(html);
    return match?.group(1);
  }

  double _parseHardness(String text, String slug) {
    final mohs = RegExp(
      r'(?:Mohs|mohs)[^0-9]{0,20}(\d+(?:[.,]\d+)?)',
      caseSensitive: false,
    ).firstMatch(text);
    if (mohs != null) {
      return double.tryParse(mohs.group(1)!.replaceAll(',', '.')) ?? 5;
    }

    final sertlik = RegExp(
      r'sertli[gğ]i[^0-9]{0,10}(\d+(?:[.,]\d+)?)',
      caseSensitive: false,
    ).firstMatch(text);
    if (sertlik != null) {
      return double.tryParse(sertlik.group(1)!.replaceAll(',', '.')) ?? 5;
    }

    return _defaultHardness(slug);
  }

  String _parseLuster(String text, String slug) {
    final lower = text.toLowerCase();
    if (lower.contains('metalik')) return 'metalik';
    if (lower.contains('camsı') || lower.contains('cam parlak')) return 'camsı';
    if (lower.contains('mat')) return 'mat';
    return _defaultLuster(slug);
  }

  List<String> _parseColors(String text) {
    const colorWords = [
      'beyaz', 'siyah', 'gri', 'kırmızı', 'turuncu', 'sarı',
      'yeşil', 'mavi', 'mor', 'pembe', 'kahverengi', 'şeffaf',
    ];
    final lower = text.toLowerCase();
    final found = colorWords.where((c) => lower.contains(c)).toList();
    return found.isEmpty ? ['çeşitli'] : found;
  }

  bool _parseMagnetic(String text, String slug) {
    if (slug == 'manyet') return true;
    final lower = text.toLowerCase();
    return lower.contains('manyetik') && !lower.contains('manyetik değil');
  }

  double _defaultHardness(String slug) => switch (slug) {
        'kuvars' => 7.0,
        'hematit' => 5.5,
        'manyet' => 6.0,
        'kalsit' => 3.0,
        'pirit' => 6.5,
        'talk' => 1.0,
        'fluorit' => 4.0,
        'grafit' => 1.5,
        _ => 5.0,
      };

  String _defaultLuster(String slug) => switch (slug) {
        'hematit' || 'manyet' || 'pirit' => 'metalik',
        'talk' || 'grafit' => 'mat',
        _ => 'camsı',
      };

  String? _guessImageUrl(String slug) {
    return '$baseUrl/sayfalar/bilgi-merkezi/endustriyel-hammaddeler/$slug.jpg';
  }

  String _titleFromSlug(String slug) {
    if (slug == 'manyet') return 'Magnetit';
    if (slug == 'fluorit') return 'Florit';
    return slug[0].toUpperCase() + slug.substring(1);
  }

  String _normalizeTitle(String title) {
    if (title.toUpperCase() == 'MANYET') return 'Magnetit';
    if (title.toUpperCase() == 'FLUORİT' || title.toUpperCase() == 'FLUORIT') {
      return 'Florit';
    }
    return title.isNotEmpty
        ? '${title[0].toUpperCase()}${title.substring(1).toLowerCase()}'
        : title;
  }

  String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  String _decodeBody(http.Response response) {
    final charset = RegExp(
      r'charset=([^";\s]+)',
      caseSensitive: false,
    ).firstMatch(response.headers['content-type'] ?? '')?.group(1);

    if (charset != null && charset.toLowerCase().contains('utf')) {
      return utf8.decode(response.bodyBytes, allowMalformed: true);
    }
    return latin1.decode(response.bodyBytes, allowInvalid: true);
  }

  Map<String, String> get _headers => const {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'text/html,application/xhtml+xml',
        'Accept-Language': 'tr-TR,tr;q=0.9',
      };
}
