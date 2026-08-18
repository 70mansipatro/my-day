class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String? taskId;
  final String? habitId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type = 'general',
    this.isRead = false,
    this.taskId,
    this.habitId,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: (json['type'] as String?) ?? 'general',
      isRead: json['isRead'] as bool? ?? false,
      taskId: json['taskId']?.toString(),
      habitId: json['habitId']?.toString(),
      metadata: json['metadata'] as Map<String, dynamic>?,
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
    'title': title,
    'message': message,
    'type': type,
    'isRead': isRead,
    'taskId': taskId,
    'habitId': habitId,
    'metadata': metadata,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      taskId: taskId,
      habitId: habitId,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
