const express = require('express');
const { body, param, query } = require('express-validator');
const router = express.Router();
const noteController = require('../controllers/noteController');
const authMiddleware = require('../middleware/authMiddleware');

const noteValidation = [
  body('title')
    .optional()
    .trim()
    .isLength({ min: 1, max: 150 })
    .withMessage('Title must be between 1 and 150 characters'),
  body('content')
    .optional()
    .trim()
    .isLength({ min: 1, max: 10000 })
    .withMessage('Content must be between 1 and 10000 characters'),
  body('category')
    .optional()
    .trim()
    .isLength({ max: 50 })
    .withMessage('Category must be 50 characters or fewer'),
  body('isFavorite')
    .optional()
    .isBoolean()
    .withMessage('Favorite status must be a boolean value'),
];

const noteIdValidation = [
  param('id').isMongoId().withMessage('Invalid note ID'),
];

const noteQueryValidation = [
  query('search').optional().isString().trim(),
  query('favorite').optional().isIn(['true', 'false']).withMessage('Favorite must be true or false'),
  query('category').optional().trim(),
  query('sort').optional().isIn(['newest', 'oldest', 'favorite']).withMessage('Invalid sort option'),
];

router.use(authMiddleware);

router.get('/', noteQueryValidation, noteController.getNotes);
router.post('/', noteValidation, noteController.createNote);
router.get('/:id', noteIdValidation, noteController.getNote);
router.put('/:id', noteIdValidation, noteValidation, noteController.updateNote);
router.patch('/:id/favorite', noteIdValidation, noteController.toggleFavorite);
router.delete('/:id', noteIdValidation, noteController.deleteNote);

module.exports = router;
