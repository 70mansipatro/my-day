const express = require('express');
const { body, param, query } = require('express-validator');
const router = express.Router();
const taskController = require('../controllers/taskController');
const authMiddleware = require('../middleware/authMiddleware');

const taskValidation = [
  body('title')
    .optional()
    .trim()
    .isLength({ min: 1, max: 150 })
    .withMessage('Title must be between 1 and 150 characters'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 1000 })
    .withMessage('Description must be 1000 characters or fewer'),
  body('priority')
    .optional()
    .isIn(['low', 'medium', 'high'])
    .withMessage('Priority must be low, medium, or high'),
  body('dueDate')
    .optional()
    .custom((value) => {
      if (!value) return true;
      const date = new Date(value);
      if (Number.isNaN(date.getTime())) {
        throw new Error('Due date is invalid');
      }
      return true;
    }),
  body('category')
    .optional()
    .trim()
    .isLength({ max: 50 })
    .withMessage('Category must be 50 characters or fewer'),
  body('completed').optional().isBoolean().withMessage('Completed must be a boolean value'),
];

const taskIdValidation = [
  param('id').isMongoId().withMessage('Invalid task ID'),
];

router.use(authMiddleware);

router.get(
  '/',
  [
    query('search').optional().isString().trim(),
    query('completed').optional().isIn(['true', 'false']).withMessage('Completed must be true or false'),
    query('priority').optional().isIn(['low', 'medium', 'high']).withMessage('Priority must be low, medium, or high'),
    query('category').optional().trim(),
    query('sort').optional().isIn(['newest', 'oldest', 'dueDate', 'priority']).withMessage('Invalid sort option'),
  ],
  taskController.getTasks
);
router.post('/', taskValidation, taskController.createTask);
router.get('/:id', taskIdValidation, taskController.getTask);
router.put('/:id', taskIdValidation, taskValidation, taskController.updateTask);
router.patch('/:id/toggle', taskIdValidation, taskController.toggleTask);
router.delete('/:id', taskIdValidation, taskController.deleteTask);

module.exports = router;
