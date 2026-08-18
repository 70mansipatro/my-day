class NotificationPreferenceModel {
  final bool pushEnabled;
  final bool taskReminderEnabled;
  final bool habitReminderEnabled;
  final bool dueDateReminderEnabled;
  final bool generalNotificationEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const NotificationPreferenceModel({
    this.pushEnabled = true,
    this.taskReminderEnabled = true,
    this.habitReminderEnabled = true,
    this.dueDateReminderEnabled = true,
    this.generalNotificationEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceModel(
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      taskReminderEnabled: json['taskReminderEnabled'] as bool? ?? true,
      habitReminderEnabled: json['habitReminderEnabled'] as bool? ?? true,
      dueDateReminderEnabled: json['dueDateReminderEnabled'] as bool? ?? true,
      generalNotificationEnabled:
          json['generalNotificationEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'pushEnabled': pushEnabled,
    'taskReminderEnabled': taskReminderEnabled,
    'habitReminderEnabled': habitReminderEnabled,
    'dueDateReminderEnabled': dueDateReminderEnabled,
    'generalNotificationEnabled': generalNotificationEnabled,
    'soundEnabled': soundEnabled,
    'vibrationEnabled': vibrationEnabled,
  };

  NotificationPreferenceModel copyWith({
    bool? pushEnabled,
    bool? taskReminderEnabled,
    bool? habitReminderEnabled,
    bool? dueDateReminderEnabled,
    bool? generalNotificationEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationPreferenceModel(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      taskReminderEnabled: taskReminderEnabled ?? this.taskReminderEnabled,
      habitReminderEnabled: habitReminderEnabled ?? this.habitReminderEnabled,
      dueDateReminderEnabled:
          dueDateReminderEnabled ?? this.dueDateReminderEnabled,
      generalNotificationEnabled:
          generalNotificationEnabled ?? this.generalNotificationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}
