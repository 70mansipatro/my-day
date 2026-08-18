const mongoose = require('mongoose');

// Durable record of "this reminder was already sent" — kept separate from
// Notification so that a user deleting a notification from their inbox does
// not cause the scheduler to regenerate it on the next tick.
const notificationEventSchema = new mongoose.Schema(
  {
    refId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
    },
    type: {
      type: String,
      required: true,
    },
    // 'once' for one-time events (task reminder / due date), or a
    // YYYY-MM-DD key for recurring daily events (habit reminders).
    dateKey: {
      type: String,
      required: true,
    },
  },
  { timestamps: true }
);

notificationEventSchema.index({ refId: 1, type: 1, dateKey: 1 }, { unique: true });

module.exports = mongoose.model('NotificationEvent', notificationEventSchema);
