const cron = require('node-cron');
const Task = require('../models/Task');
const Habit = require('../models/Habit');
const HabitLog = require('../models/HabitLog');
const Notification = require('../models/Notification');
const NotificationEvent = require('../models/NotificationEvent');
const { getOrCreatePreferences } = require('../controllers/notificationPreferenceController');

const DAY_IN_MS = 24 * 60 * 60 * 1000;

const normalizeDateOnly = (input) => {
  const date = new Date(input);
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
};

const getDateKey = (input) => normalizeDateOnly(input).toISOString().slice(0, 10);

// Atomically claims an event via the unique index — returns true only the
// first time a given (refId, type, dateKey) combination is seen, even if the
// resulting Notification is later deleted by the user.
const claimEvent = async (refId, type, dateKey) => {
  try {
    await NotificationEvent.create({ refId, type, dateKey });
    return true;
  } catch (error) {
    if (error.code === 11000) return false;
    throw error;
  }
};

const getUTCWeekday = (date) => normalizeDateOnly(date).getUTCDay();

const isHabitScheduledToday = (habit, date) => {
  if (habit.frequency !== 'weekly') return true;
  const targetDays = Array.isArray(habit.targetDays) ? habit.targetDays : [];
  if (targetDays.length === 0) return false;
  return targetDays.includes(getUTCWeekday(date));
};

const preferenceCache = new Map();

const getCachedPreferences = async (userId) => {
  const key = userId.toString();
  if (preferenceCache.has(key)) {
    return preferenceCache.get(key);
  }
  const preferences = await getOrCreatePreferences(userId);
  preferenceCache.set(key, preferences);
  return preferences;
};

const checkTaskReminders = async () => {
  const now = new Date();
  const in24Hours = new Date(now.getTime() + DAY_IN_MS);
  const todayStart = normalizeDateOnly(now);
  const todayEnd = new Date(todayStart.getTime() + DAY_IN_MS);

  const upcomingTasks = await Task.find({
    completed: false,
    dueDate: { $gte: now, $lte: in24Hours },
  }).lean();

  for (const task of upcomingTasks) {
    const preferences = await getCachedPreferences(task.userId);
    if (!preferences.pushEnabled || !preferences.taskReminderEnabled) continue;

    const claimed = await claimEvent(task._id, 'task_reminder', 'once');
    if (!claimed) continue;

    await Notification.create({
      userId: task.userId,
      title: 'Task Due Soon',
      message: `"${task.title}" is due soon.`,
      type: 'task_reminder',
      taskId: task._id,
    });
  }

  const dueTodayTasks = await Task.find({
    completed: false,
    dueDate: { $gte: todayStart, $lt: todayEnd },
  }).lean();

  for (const task of dueTodayTasks) {
    const preferences = await getCachedPreferences(task.userId);
    if (!preferences.pushEnabled || !preferences.dueDateReminderEnabled) continue;

    const claimed = await claimEvent(task._id, 'due_date', 'once');
    if (!claimed) continue;

    await Notification.create({
      userId: task.userId,
      title: 'Task Due Today',
      message: `"${task.title}" is due today.`,
      type: 'due_date',
      taskId: task._id,
    });
  }
};

const checkHabitReminders = async () => {
  const now = new Date();
  const todayStart = normalizeDateOnly(now);

  const activeHabits = await Habit.find({ isActive: true }).lean();

  for (const habit of activeHabits) {
    if (!isHabitScheduledToday(habit, now)) continue;

    const log = await HabitLog.findOne({ habitId: habit._id, date: todayStart }).lean();
    if (log && log.completed) continue;

    const preferences = await getCachedPreferences(habit.userId);
    if (!preferences.pushEnabled || !preferences.habitReminderEnabled) continue;

    const claimed = await claimEvent(habit._id, 'habit_reminder', getDateKey(now));
    if (!claimed) continue;

    await Notification.create({
      userId: habit.userId,
      title: 'Habit Reminder',
      message: `Don't forget to complete "${habit.name}" today.`,
      type: 'habit_reminder',
      habitId: habit._id,
    });
  }
};

const runChecks = async () => {
  preferenceCache.clear();
  try {
    await checkTaskReminders();
  } catch (error) {
    console.error('Notification scheduler: task reminder check failed', error);
  }

  const habitReminderHour = Number.parseInt(process.env.HABIT_REMINDER_HOUR, 10);
  const targetHour = Number.isFinite(habitReminderHour) ? habitReminderHour : 19;
  if (new Date().getHours() === targetHour) {
    try {
      await checkHabitReminders();
    } catch (error) {
      console.error('Notification scheduler: habit reminder check failed', error);
    }
  }
};

exports.start = () => {
  cron.schedule('*/15 * * * *', runChecks);
  console.log('Notification scheduler started (checks every 15 minutes)');
};

// Exposed for tests/manual triggering; not used by the app at runtime.
exports.runChecks = runChecks;
