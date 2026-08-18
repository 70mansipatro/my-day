const { validationResult } = require('express-validator');
const NotificationPreference = require('../models/NotificationPreference');

const PREFERENCE_FIELDS = [
  'pushEnabled',
  'taskReminderEnabled',
  'habitReminderEnabled',
  'dueDateReminderEnabled',
  'generalNotificationEnabled',
  'soundEnabled',
  'vibrationEnabled',
];

// Shared by the API and the notification scheduler: every user gets sensible
// default preferences automatically the first time they're looked up.
const getOrCreatePreferences = async (userId) => {
  return NotificationPreference.findOneAndUpdate(
    { userId },
    { $setOnInsert: { userId } },
    { upsert: true, new: true, setDefaultsOnInsert: true }
  );
};

exports.getOrCreatePreferences = getOrCreatePreferences;

exports.getPreferences = async (req, res, next) => {
  try {
    const preferences = await getOrCreatePreferences(req.userId);
    res.status(200).json({ success: true, data: { preferences } });
  } catch (error) {
    next(error);
  }
};

exports.updatePreferences = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: errors.array()[0].msg,
      });
    }

    const update = {};
    for (const field of PREFERENCE_FIELDS) {
      if (req.body[field] !== undefined) {
        update[field] = Boolean(req.body[field]);
      }
    }

    const preferences = await NotificationPreference.findOneAndUpdate(
      { userId: req.userId },
      { $set: update, $setOnInsert: { userId: req.userId } },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    res.status(200).json({
      success: true,
      message: 'Notification preferences updated successfully',
      data: { preferences },
    });
  } catch (error) {
    if (error.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: Object.values(error.errors)[0]?.message || 'Invalid preference data',
      });
    }
    next(error);
  }
};
