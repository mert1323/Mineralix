class Mineral {
  final int id;
  final String name;
  final String description;
  final double hardness;
  final String luster;
  final List<String> colors;
  final bool magnetic;
  final String? imageUrl;
  final String? mtaSlug;
  final String? sourceUrl;
  final String? formula;
  final String? crystalSystem;
  final String? streak;
  final String? cleavage;
  final String? fracture;
  final double? specificGravity;
  final String? category;
  final int? mindatId;
  final double? hardnessMax;
  final String? nameTr;

  const Mineral({
    required this.id,
    required this.name,
    required this.description,
    required this.hardness,
    required this.luster,
    required this.colors,
    required this.magnetic,
    this.imageUrl,
    this.mtaSlug,
    this.sourceUrl,
    this.formula,
    this.crystalSystem,
    this.streak,
    this.cleavage,
    this.fracture,
    this.specificGravity,
    this.category,
    this.mindatId,
    this.hardnessMax,
    this.nameTr,
  });

  factory Mineral.fromJson(Map<String, dynamic> json) {
    return Mineral(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      hardness: (json['hardness'] as num).toDouble(),
      luster: json['luster'] as String,
      colors: (json['colors'] as List<dynamic>?)
              ?.map((c) => c.toString())
              .toList() ??
          [],
      magnetic: json['magnetic'] as bool? ?? false,
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String? ?? json['photo_url'] as String?,
      mtaSlug: json['mta_slug'] as String? ?? json['mtaSlug'] as String?,
      sourceUrl: json['source_url'] as String? ?? json['sourceUrl'] as String?,
      formula: json['formula'] as String?,
      crystalSystem: json['crystal_system'] as String? ?? json['crystalSystem'] as String?,
      streak: json['streak'] as String?,
      cleavage: json['cleavage'] as String?,
      fracture: json['fracture'] as String?,
      specificGravity: (json['specific_gravity'] as num?)?.toDouble() ?? (json['specificGravity'] as num?)?.toDouble(),
      category: json['category'] as String?,
      mindatId: json['mindat_id'] as int? ?? json['mindatId'] as int?,
      hardnessMax: (json['hardness_max'] as num?)?.toDouble() ?? (json['hardnessMax'] as num?)?.toDouble(),
      nameTr: json['name_tr'] as String? ?? json['nameTr'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'hardness': hardness,
        'luster': luster,
        'colors': colors,
        'magnetic': magnetic,
        'image_url': imageUrl,
        'mta_slug': mtaSlug,
        'source_url': sourceUrl,
        'formula': formula,
        'crystal_system': crystalSystem,
        'streak': streak,
        'cleavage': cleavage,
        'fracture': fracture,
        'specific_gravity': specificGravity,
        'category': category,
        'mindat_id': mindatId,
        'hardness_max': hardnessMax,
        'name_tr': nameTr,
      };
}

class IdentifyResult {
  final Mineral mineral;
  final double matchPercentage;

  const IdentifyResult({
    required this.mineral,
    required this.matchPercentage,
  });

  factory IdentifyResult.fromJson(Map<String, dynamic> json) {
    return IdentifyResult(
      mineral: Mineral.fromJson(json['mineral'] as Map<String, dynamic>),
      matchPercentage: (json['match_percentage'] as num?)?.toDouble() ??
          (json['matchPercentage'] as num?)?.toDouble() ??
          0,
    );
  }
}
