const mongoose = require('mongoose');
const { validationResult } = require('express-validator');
const Habit = require('../models/Habit');
const HabitLog = require('../models/HabitLog');

const DAY_IN_MS = 24 * 60 * 60 * 1000;

const escapeRegex = (value) => value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

const normalizeDateOnly = (input) => {
  const date = new Date(input);
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
};

const getDateKey = (input) => normalizeDateOnly(input).toISOString().slice(0, 10);

const getUTCWeekday = (date) => normalizeDateOnly(date).getUTCDay();

const clampDays = (value, fallback) => {
  const parsed = Number.parseInt(value, 10);
  if (!Number.isFinite(parsed)) return fallback;
  return Math.min(Math.max(parsed, 1), 365);
};

const isWeeklyHabitScheduled = (habit, date) => {
  if (!habit || habit.frequency !== 'weekly') return true;
  const targetDays = Array.isArray(habit.targetDays) ? habit.targetDays : [];
  if (targetDays.length === 0) return false;
  return targetDays.includes(getUTCWeekday(date));
};

const buildHabitQuery = (req) => {
  const query = { userId: req.userId };
  const activeParam = req.query.active;
  const frequency = typeof req.query.frequency === 'string' ? req.query.frequency.trim().toLowerCase() : '';
  const category = typeof req.query.category === 'string' ? req.query.category.trim() : '';
  const search = typeof req.query.search === 'string' ? req.query.search.trim() : '';

  if (activeParam === undefined) {
    query.isActive = true;
  } else if (activeParam === 'true' || activeParam === 'false') {
    query.isActive = activeParam === 'true';
  }

  if (frequency && ['daily', 'weekly'].includes(frequency)) {
    query.frequency = frequency;
  }

  if (category) {
    query.category = new RegExp(`^${escapeRegex(category)}$`, 'i');
  }

  if (search) {
    query.$or = [
      { name: { $regex: escapeRegex(search), $options: 'i' } },
      { description: { $regex: escapeRegex(search), $options: 'i' } },
    ];
  }

  return query;
};

const getSortConfig = (sortParam) => {
  const allowed = {
    newest: { updatedAt: -1, createdAt: -1 },
    oldest: { updatedAt: 1, createdAt: 1 },
    nameAsc: { name: 1 },
    nameDesc: { name: -1 },
    streak: { updatedAt: -1 },
  };
  return allowed[sortParam] || allowed.newest;
};

const parseHabitId = (req) => {
  const { id } = req.params;
  return mongoose.Types.ObjectId.isValid(id) ? id : null;
};

const getHabitCompletionMap = (habitId, userId, startDate, endDate) => {
  return HabitLog.find({
    userId,
    habitId,
    date: { $gte: startDate, $lte: endDate },
  }).lean();
};

const getCurrentDailyStreak = (logMap, endDate) => {
  let streak = 0;
  let cursor = normalizeDateOnly(endDate);
  while (true) {
    const key = getDateKey(cursor);
    const entry = logMap[key];
    if (entry && entry.completed) {
      streak += 1;
      cursor = new Date(cursor.getTime() - DAY_IN_MS);
    } else {
      break;
    }
  }
  return streak;
};

const getBestDailyStreak = (logMap) => {
  const dates = Object.keys(logMap).sort();
  if (dates.length === 0) return 0;

  let best = 0;
  let current = 0;
  let previousDate = null;

  for (const dateKeyValue of dates) {
    const date = new Date(`${dateKeyValue}T00:00:00.000Z`);
    if (!logMap[dateKeyValue]?.completed) {
      current = 0;
      previousDate = date;
      continue;
    }

    if (previousDate && (date.getTime() - previousDate.getTime()) > DAY_IN_MS) {
      current = 0;
    }

    current += 1;
    best = Math.max(best, current);
    previousDate = date;
  }

  return best;
};

const getWeeklyStreak = (habit, logMap, endDate) => {
  const effectiveEnd = normalizeDateOnly(endDate);
  const scheduledDates = [];
  const startDate = new Date(effectiveEnd.getTime() - (365 * DAY_IN_MS));

  for (let cursor = new Date(startDate.getTime()); cursor <= effectiveEnd; cursor = new Date(cursor.getTime() + DAY_IN_MS)) {
    const currentDate = normalizeDateOnly(cursor);
    if (isWeeklyHabitScheduled(habit, currentDate)) {
      scheduledDates.push(currentDate);
    }
  }

  if (scheduledDates.length === 0) return 0;

  let streak = 0;
  for (let index = scheduledDates.length - 1; index >= 0; index -= 1) {
    const currentDate = scheduledDates[index];
    const key = getDateKey(currentDate);
    if (logMap[key] && logMap[key].completed) {
      streak += 1;
    } else {
      break;
    }
  }

  return streak;
};

const getWeeklyBestStreak = (habit, logMap) => {
  const startDate = new Date(Date.now() - (365 * DAY_IN_MS));
  const endDate = normalizeDateOnly(new Date());
  const scheduledDates = [];

  for (let cursor = new Date(startDate.getTime()); cursor <= endDate; cursor = new Date(cursor.getTime() + DAY_IN_MS)) {
    const currentDate = normalizeDateOnly(cursor);
    if (isWeeklyHabitScheduled(habit, currentDate)) {
      scheduledDates.push(currentDate);
    }
  }

  if (scheduledDates.length === 0) return 0;

  let best = 0;
  let current = 0;

  for (const currentDate of scheduledDates) {
    const key = getDateKey(currentDate);
    if (logMap[key] && logMap[key].completed) {
      current += 1;
      best = Math.max(best, current);
    } else {
      current = 0;
    }
  }

  return best;
};

const getCompletionStats = (habit, logMap, startDate, endDate) => {
  let completedDays = 0;
  let totalTrackedDays = 0;

  for (let cursor = new Date(startDate.getTime()); cursor <= endDate; cursor = new Date(cursor.getTime() + DAY_IN_MS)) {
    const currentDate = normalizeDateOnly(cursor);
    if (habit.frequency === 'daily' || isWeeklyHabitScheduled(habit, currentDate)) {
      totalTrackedDays += 1;
      const key = getDateKey(currentDate);
      if (logMap[key] && logMap[key].completed) {
        completedDays += 1;
      }
    }
  }

  const completionRate = totalTrackedDays === 0 ? 0 : Math.round((completedDays / totalTrackedDays) * 100);

  return {
    completedDays,
    totalTrackedDays,
    completionRate,
  };
};

exports.getHabits = async (req, res, next) => {
  try {
    const query = buildHabitQuery(req);
    const sortParam = typeof req.query.sort === 'string' ? req.query.sort : 'newest';

    const habits = await Habit.find(query).sort(getSortConfig(sortParam)).lean();

    res.status(200).json({
      success: true,
      data: { habits },
    });
  } catch (error) {
    next(error);
  }
};

exports.createHabit = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: errors.array()[0].msg,
      });
    }

    const name = typeof req.body.name === 'string' ? req.body.name.trim() : '';
    const description = typeof req.body.description === 'string' ? req.body.description.trim() : '';
    const category = typeof req.body.category === 'string' ? req.body.category.trim() : 'General';
    const frequency = typeof req.body.frequency === 'string' ? req.body.frequency.toLowerCase() : 'daily';
    const targetDays = Array.isArray(req.body.targetDays) ? req.body.targetDays.map((day) => Number(day)).filter((day) => Number.isInteger(day) && day >= 0 && day <= 6) : [];

    if (!name) {
      return res.status(400).json({ success: false, message: 'Name is required' });
    }

    if (frequency === 'weekly' && targetDays.length === 0) {
      return res.status(400).json({ success: false, message: 'Weekly habits require at least one target day' });
    }

    const habit = await Habit.create({
      userId: req.userId,
      name,
      description,
      category: category || 'General',
      frequency,
      targetDays: frequency === 'weekly' ? targetDays : [],
      isActive: req.body.isActive !== undefined ? Boolean(req.body.isActive) : true,
    });

    res.status(201).json({
      success: true,
      message: 'Habit created successfully',
      data: { habit },
    });
  } catch (error) {
    if (error.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: Object.values(error.errors)[0]?.message || 'Invalid habit data',
      });
    }

    if (error.name === 'CastError') {
      return res.status(400).json({ success: false, message: 'Invalid habit data' });
    }

    next(error);
  }
};

exports.getHabit = async (req, res, next) => {
  try {
    const habitId = parseHabitId(req);
    if (!habitId) {
      return res.status(400).json({ success: false, message: 'Invalid habit ID' });
    }

    const habit = await Habit.findOne({ _id: habitId, userId: req.userId }).lean();
    if (!habit) {
      return res.status(404).json({ success: false, message: 'Habit not found' });
    }

    res.status(200).json({ success: true, data: { habit } });
  } catch (error) {
    next(error);
  }
};

exports.updateHabit = async (req, res, next) => {
  try {
    const habitId = parseHabitId(req);
    if (!habitId) {
      return res.status(400).json({ success: false, message: 'Invalid habit ID' });
    }

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: errors.array()[0].msg,
      });
    }

    const habit = await Habit.findOne({ _id: habitId, userId: req.userId });
    if (!habit) {
      return res.status(404).json({ success: false, message: 'Habit not found' });
    }

    const nextName = req.body.name !== undefined ? String(req.body.name).trim() : habit.name;
    const nextDescription = req.body.description !== undefined ? String(req.body.description).trim() : habit.description;
    const nextCategory = req.body.category !== undefined ? String(req.body.category).trim() || 'General' : (habit.category || 'General');
    const nextFrequency = req.body.frequency !== undefined ? String(req.body.frequency).toLowerCase() : habit.frequency;
    const nextTargetDays = req.body.targetDays !== undefined ? Array.isArray(req.body.targetDays) ? req.body.targetDays.map((day) => Number(day)).filter((day) => Number.isInteger(day) && day >= 0 && day <= 6) : [] : habit.targetDays;
    const nextActive = req.body.isActive !== undefined ? Boolean(req.body.isActive) : habit.isActive;

    if (!nextName) {
      return res.status(400).json({ success: false, message: 'Name is required' });
    }

    if (nextFrequency === 'weekly' && nextTargetDays.length === 0) {
      return res.status(400).json({ success: false, message: 'Weekly habits require at least one target day' });
    }

    habit.name = nextName;
    habit.description = nextDescription;
    habit.category = nextCategory;
    habit.frequency = nextFrequency;
    habit.targetDays = nextFrequency === 'weekly' ? nextTargetDays : [];
    habit.isActive = nextActive;

    await habit.save();

    res.status(200).json({
      success: true,
      message: 'Habit updated successfully',
      data: { habit },
    });
  } catch (error) {
    if (error.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: Object.values(error.errors)[0]?.message || 'Invalid habit data',
      });
    }

    if (error.name === 'CastError') {
      return res.status(400).json({ success: false, message: 'Invalid habit data' });
    }

    next(error);
  }
};

exports.toggleHabit = async (req, res, next) => {
  try {
    const habitId = parseHabitId(req);
    if (!habitId) {
      return res.status(400).json({ success: false, message: 'Invalid habit ID' });
    }

    const habit = await Habit.findOne({ _id: habitId, userId: req.userId });
    if (!habit) {
      return res.status(404).json({ success: false, message: 'Habit not found' });
    }

    const today = normalizeDateOnly(new Date());
    const existingLog = await HabitLog.findOne({
      userId: req.userId,
      habitId,
      date: today,
    });

    if (!existingLog) {
      const nextLog = await HabitLog.create({
        userId: req.userId,
        habitId,
        date: today,
        completed: true,
      });

      return res.status(200).json({
        success: true,
        message: 'Habit status updated',
        data: { habit, log: nextLog },
      });
    }

    existingLog.completed = !existingLog.completed;
    await existingLog.save();

    res.status(200).json({
      success: true,
      message: 'Habit status updated',
      data: { habit, log: existingLog },
    });
  } catch (error) {
    next(error);
  }
};

exports.deleteHabit = async (req, res, next) => {
  try {
    const habitId = parseHabitId(req);
    if (!habitId) {
      return res.status(400).json({ success: false, message: 'Invalid habit ID' });
    }

    const habit = await Habit.findOneAndDelete({ _id: habitId, userId: req.userId });
    if (!habit) {
      return res.status(404).json({ success: false, message: 'Habit not found' });
    }

    await HabitLog.deleteMany({ userId: req.userId, habitId });

    res.status(200).json({
      success: true,
      message: 'Habit deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

exports.getTodayHabits = async (req, res, next) => {
  try {
    const habits = await Habit.find({ userId: req.userId, isActive: true }).lean();
    const today = normalizeDateOnly(new Date());
    const todayKey = getDateKey(today);

    const mapped = await Promise.all(
      habits.map(async (habit) => {
        if (habit.frequency === 'weekly' && !isWeeklyHabitScheduled(habit, today)) {
          return null;
        }

        const log = await HabitLog.findOne({ userId: req.userId, habitId: habit._id, date: today }).lean();
        const logs = await HabitLog.find({ userId: req.userId, habitId: habit._id }).lean();
        const logMap = {};
        logs.forEach((entry) => {
          logMap[getDateKey(entry.date)] = entry;
        });

        return {
          id: habit._id.toString(),
          name: habit.name,
          category: habit.category,
          frequency: habit.frequency,
          completedToday: Boolean(log && log.completed),
          currentStreak: habit.frequency === 'daily'
            ? getCurrentDailyStreak(logMap, today)
            : getWeeklyStreak(habit, logMap, today),
        };
      })
    );

    res.status(200).json({
      success: true,
      data: {
        habits: mapped.filter(Boolean),
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.getHabitHistory = async (req, res, next) => {
  try {
    const habitId = parseHabitId(req);
    if (!habitId) {
      return res.status(400).json({ success: false, message: 'Invalid habit ID' });
    }

    const habit = await Habit.findOne({ _id: habitId, userId: req.userId });
    if (!habit) {
      return res.status(404).json({ success: false, message: 'Habit not found' });
    }

    const days = clampDays(req.query.days || 30, 30);
    const end = normalizeDateOnly(new Date());
    const start = new Date(end.getTime() - ((days - 1) * DAY_IN_MS));

    const logs = await HabitLog.find({
      userId: req.userId,
      habitId,
      date: { $gte: start, $lte: end },
    }).lean();

    const logMap = {};
    logs.forEach((entry) => {
      logMap[getDateKey(entry.date)] = entry.completed;
    });

    const history = [];
    for (let cursor = new Date(start.getTime()); cursor <= end; cursor = new Date(cursor.getTime() + DAY_IN_MS)) {
      const currentDate = normalizeDateOnly(cursor);
      const dateKey = getDateKey(currentDate);
      const completed = (habit.frequency === 'daily' || isWeeklyHabitScheduled(habit, currentDate)) && Boolean(logMap[dateKey]);
      history.push({ date: dateKey, completed });
    }

    res.status(200).json({ success: true, data: { history } });
  } catch (error) {
    next(error);
  }
};

exports.getHabitStats = async (req, res, next) => {
  try {
    const habitId = parseHabitId(req);
    if (!habitId) {
      return res.status(400).json({ success: false, message: 'Invalid habit ID' });
    }

    const habit = await Habit.findOne({ _id: habitId, userId: req.userId });
    if (!habit) {
      return res.status(404).json({ success: false, message: 'Habit not found' });
    }

    const today = normalizeDateOnly(new Date());
    const startDate = new Date(today.getTime() - (365 * DAY_IN_MS));
    const logs = await HabitLog.find({
      userId: req.userId,
      habitId,
      date: { $gte: startDate, $lte: today },
    }).lean();

    const logMap = {};
    logs.forEach((entry) => {
      logMap[getDateKey(entry.date)] = entry;
    });

    const currentStreak = habit.frequency === 'daily'
      ? getCurrentDailyStreak(logMap, today)
      : getWeeklyStreak(habit, logMap, today);

    const bestStreak = habit.frequency === 'daily'
      ? getBestDailyStreak(logMap)
      : getWeeklyBestStreak(habit, logMap);

    const stats = getCompletionStats(habit, logMap, startDate, today);

    res.status(200).json({
      success: true,
      data: {
        currentStreak,
        bestStreak,
        completionRate: stats.completionRate,
        completedDays: stats.completedDays,
        totalTrackedDays: stats.totalTrackedDays,
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.getHabit = async (req, res, next) => { /* duplicate placeholder replaced by prior definition above */ };
