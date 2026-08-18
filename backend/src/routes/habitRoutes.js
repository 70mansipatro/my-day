const express = require('express');
const { body, param, query } = require('express-validator');
const router = express.Router();
const habitController = require('../controllers/habitController');
const authMiddleware = require('../middleware/authMiddleware');

const habitValidation = [
  body('name')
    .optional()
    .trim()
    .isLength({ min: 1, max: 100 })
    .withMessage('Name must be between 1 and 100 characters'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Description must be 500 characters or fewer'),
  body('category')
    .optional()
    .trim()
    .isLength({ max: 50 })
    .withMessage('Category must be 50 characters or fewer'),
  body('frequency')
    .optional()
    .isIn(['daily', 'weekly'])
    .withMessage('Frequency must be daily or weekly'),
  body('targetDays')
    .optional()
    .isArray()
    .withMessage('Target days must be an array of numbers'),
  body('targetDays.*')
    .optional()
    .isInt({ min: 0, max: 6 })
    .withMessage('Each target day must be a number between 0 and 6'),
  body('isActive')
    .optional()
    .isBoolean()
    .withMessage('isActive must be a boolean value'),
];

const habitIdValidation = [
  param('id').isMongoId().withMessage('Invalid habit ID'),
];

router.use(authMiddleware);

router.get(
  '/',
  [
    query('search').optional().trim(),
    query('active').optional().isIn(['true', 'false']).withMessage('Active must be true or false'),
    query('frequency').optional().isIn(['daily', 'weekly']).withMessage('Frequency must be daily or weekly'),
    query('category').optional().trim(),
    query('sort').optional().isIn(['newest', 'oldest', 'nameAsc', 'nameDesc', 'streak']).withMessage('Invalid sort option'),
  ],
  habitController.getHabits
);
router.post('/', habitValidation, habitController.createHabit);
router.get('/today', habitController.getTodayHabits);
router.get('/:id', habitIdValidation, habitController.getHabit);
router.put('/:id', habitIdValidation, habitValidation, habitController.updateHabit);
router.patch('/:id/toggle', habitIdValidation, habitController.toggleHabit);
router.delete('/:id', habitIdValidation, habitController.deleteHabit);
router.get('/:id/history', habitIdValidation, habitController.getHabitHistory);
router.get('/:id/stats', habitIdValidation, habitController.getHabitStats);

module.exports = router;
