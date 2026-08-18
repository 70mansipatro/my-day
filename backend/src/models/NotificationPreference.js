const mongoose = require('mongoose');

const notificationPreferenceSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
      index: true,
    },
    pushEnabled: { type: Boolean, default: true },
    taskReminderEnabled: { type: Boolean, default: true },
    habitReminderEnabled: { type: Boolean, default: true },
    dueDateReminderEnabled: { type: Boolean, default: true },
    generalNotificationEnabled: { type: Boolean, default: true },
    soundEnabled: { type: Boolean, default: true },
    vibrationEnabled: { type: Boolean, default: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('NotificationPreference', notificationPreferenceSchema);
