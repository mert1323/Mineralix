import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/mineral.dart';

class MineralDbService {
  List<Mineral>? _cache;

  Future<List<Mineral>> loadAll() async {
    if (_cache != null) return _cache!;
    final jsonStr = await rootBundle.loadString('assets/minerals_db.json');
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    _cache = jsonList.map((e) => Mineral.fromJson(e as Map<String, dynamic>)).toList();
    _cache!.sort((a, b) => a.name.compareTo(b.name));
    return _cache!;
  }

  Future<List<Mineral>> search(String query) async {
    final all = await loadAll();
    if (query.isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((m) =>
      m.name.toLowerCase().contains(q) ||
      (m.formula?.toLowerCase().contains(q) ?? false) ||
      (m.description.toLowerCase().contains(q))
    ).toList();
  }

  Future<List<Mineral>> filterByCategory(String category) async {
    final all = await loadAll();
    return all.where((m) => m.category == category).toList();
  }

  Future<List<String>> getCategories() async {
    final all = await loadAll();
    return all.map((m) => m.category ?? 'Diğer').toSet().toList()..sort();
  }

  void clearCache() => _cache = null;
}
