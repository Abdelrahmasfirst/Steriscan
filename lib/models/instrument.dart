/// Status of an instrument within a kit scan.
enum InstrumentStatus {
  present,
  missing,
  extra,
  damaged,
}

/// A single surgical instrument detected or expected in a kit.
class Instrument {
  final String id;
  final String name;
  final String? category;
  final InstrumentStatus status;
  final double confidenceScore;
  final String? imageUrl;
  final String? description;

  const Instrument({
    required this.id,
    required this.name,
    this.category,
    required this.status,
    this.confidenceScore = 0.0,
    this.imageUrl,
    this.description,
  });

  factory Instrument.fromJson(Map<String, dynamic> json) => Instrument(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String?,
        status: InstrumentStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => InstrumentStatus.present,
        ),
        confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
        imageUrl: json['imageUrl'] as String?,
        description: json['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (category != null) 'category': category,
        'status': status.name,
        'confidenceScore': confidenceScore,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (description != null) 'description': description,
      };

  Instrument copyWith({
    String? id,
    String? name,
    String? category,
    InstrumentStatus? status,
    double? confidenceScore,
    String? imageUrl,
    String? description,
  }) =>
      Instrument(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        status: status ?? this.status,
        confidenceScore: confidenceScore ?? this.confidenceScore,
        imageUrl: imageUrl ?? this.imageUrl,
        description: description ?? this.description,
      );
}
