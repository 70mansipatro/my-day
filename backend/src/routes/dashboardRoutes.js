const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');
const dashboardController = require('../controllers/dashboardController');

const router = express.Router();

/**
 * GET /api/dashboard
 * Returns comprehensive dashboard data for the authenticated user
 *
 * Protected: Requires valid JWT
 *
 * Returns:
 *  - Greeting (based on time of day)
 *  - Task statistics and today's tasks
 *  - Notes summary
 *  - Habit statistics and today's habits
 *  - Best current streak
 *  - Weekly progress (last 7 days)
 *  - Recent tasks and notes
 */
router.get('/', authMiddleware, dashboardController.getDashboard);

module.exports = router;
