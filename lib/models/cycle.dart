/// Represents a sterilization cycle with tracking metadata.
class Cycle {
  final String id;
  final DateTime timestamp;
  final String status;
  final String? kitId;
  final String? operatorName;
  final String? notes;

  Cycle({
    required this.id,
    required this.timestamp,
    required this.status,
    this.kitId,
    this.operatorName,
    this.notes,
  });

  factory Cycle.fromJson(Map<String, dynamic> json) => Cycle(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        status: json['status'] as String,
        kitId: json['kitId'] as String?,
        operatorName: json['operatorName'] as String?,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'status': status,
        if (kitId != null) 'kitId': kitId,
        if (operatorName != null) 'operatorName': operatorName,
        if (notes != null) 'notes': notes,
      };

  Cycle copyWith({
    String? id,
    DateTime? timestamp,
    String? status,
    String? kitId,
    String? operatorName,
    String? notes,
  }) =>
      Cycle(
        id: id ?? this.id,
        timestamp: timestamp ?? this.timestamp,
        status: status ?? this.status,
        kitId: kitId ?? this.kitId,
        operatorName: operatorName ?? this.operatorName,
        notes: notes ?? this.notes,
      );
}
