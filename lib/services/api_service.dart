import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mineral.dart';
import '../providers/mineral_provider.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<IdentifyResult>> identify({
    required double hardness,
    required String luster,
    required bool magnetic,
    required List<String> colors,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/identify/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'hardness': hardness,
              'luster': luster,
              'magnetic': magnetic,
              'color': colors,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results =
            data is List ? data : (data['results'] as List<dynamic>? ?? []);
        return results
            .map((r) => IdentifyResult.fromJson(r as Map<String, dynamic>))
            .toList();
      }
      throw ApiException('Sunucu hatası: ${response.statusCode}');
    } catch (e) {
      if (e is ApiException) rethrow;
      return _mockIdentify(
        hardness: hardness,
        luster: luster,
        magnetic: magnetic,
        colors: colors,
      );
    }
  }

  List<IdentifyResult> _mockIdentify({
    required double hardness,
    required String luster,
    required bool magnetic,
    required List<String> colors,
  }) {
    final minerals = MineralProvider.sampleMinerals;
    final scored = minerals.map((mineral) {
      double score = 0;
      if ((mineral.hardness - hardness).abs() <= 1.5) score += 30;
      if (mineral.luster == luster) score += 30;
      if (mineral.magnetic == magnetic) score += 20;
      final colorMatch =
          mineral.colors.any((c) => colors.any((sel) => c.contains(sel) || sel.contains(c)));
      if (colorMatch) score += 20;
      return IdentifyResult(mineral: mineral, matchPercentage: score);
    }).toList();

    scored.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
    return scored.take(5).toList();
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
