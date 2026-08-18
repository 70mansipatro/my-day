class HabitModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String category;
  final String frequency;
  final List<int> targetDays;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HabitModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    this.category = 'General',
    this.frequency = 'daily',
    this.targetDays = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    final rawTargetDays = json['targetDays'] as List<dynamic>? ?? const [];
    return HabitModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: (json['category'] as String?)?.trim().isNotEmpty == true
          ? (json['category'] as String).trim()
          : 'General',
      frequency: (json['frequency'] as String?) ?? 'daily',
      targetDays: rawTargetDays
          .map((day) => int.tryParse(day.toString()) ?? -1)
          .where((day) => day >= 0 && day <= 6)
          .toList(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'description': description,
    'category': category,
    'frequency': frequency,
    'targetDays': targetDays,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  HabitModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? category,
    String? frequency,
    List<int>? targetDays,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      targetDays: targetDays ?? this.targetDays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
