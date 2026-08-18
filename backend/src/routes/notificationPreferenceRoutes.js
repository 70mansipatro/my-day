const express = require('express');
const { body } = require('express-validator');
const router = express.Router();
const notificationPreferenceController = require('../controllers/notificationPreferenceController');
const authMiddleware = require('../middleware/authMiddleware');

const preferenceValidation = [
  body('pushEnabled').optional().isBoolean().withMessage('pushEnabled must be a boolean'),
  body('taskReminderEnabled').optional().isBoolean().withMessage('taskReminderEnabled must be a boolean'),
  body('habitReminderEnabled').optional().isBoolean().withMessage('habitReminderEnabled must be a boolean'),
  body('dueDateReminderEnabled').optional().isBoolean().withMessage('dueDateReminderEnabled must be a boolean'),
  body('generalNotificationEnabled').optional().isBoolean().withMessage('generalNotificationEnabled must be a boolean'),
  body('soundEnabled').optional().isBoolean().withMessage('soundEnabled must be a boolean'),
  body('vibrationEnabled').optional().isBoolean().withMessage('vibrationEnabled must be a boolean'),
];

router.use(authMiddleware);

router.get('/', notificationPreferenceController.getPreferences);
router.put('/', preferenceValidation, notificationPreferenceController.updatePreferences);

module.exports = router;
