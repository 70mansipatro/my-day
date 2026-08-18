const express = require('express');
const cors = require('cors');

const errorMiddleware = require('./middleware/errorMiddleware');
const authRoutes = require('./routes/authRoutes');
const taskRoutes = require('./routes/taskRoutes');
const noteRoutes = require('./routes/noteRoutes');
const habitRoutes = require('./routes/habitRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const notificationPreferenceRoutes = require('./routes/notificationPreferenceRoutes');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'MyDay API is running',
  });
});

app.use('/api/auth', authRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/notes', noteRoutes);
app.use('/api/habits', habitRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/notification-preferences', notificationPreferenceRoutes);

app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

app.use(errorMiddleware);

module.exports = app;
