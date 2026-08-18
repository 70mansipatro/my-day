const mongoose = require('mongoose');
const Task = require('../models/Task');
const Note = require('../models/Note');
const Habit = require('../models/Habit');
const HabitLog = require('../models/HabitLog');

const DAY_IN_MS = 24 * 60 * 60 * 1000;

/**
 * Normalizes a date to UTC midnight (00:00:00.000Z)
 */
const normalizeDateOnly = (input) => {
  const date = new Date(input);
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
};

/**
 * Gets date as "YYYY-MM-DD" string
 */
const getDateKey = (input) => normalizeDateOnly(input).toISOString().slice(0, 10);

/**
 * Gets UTC weekday (0 = Sunday, 6 = Saturday)
 */
const getUTCWeekday = (date) => normalizeDateOnly(date).getUTCDay();

/**
 * Checks if a weekly habit is scheduled for the given date
 */
const isWeeklyHabitScheduled = (habit, date) => {
  if (!habit || habit.frequency !== 'weekly') return true;
  const targetDays = Array.isArray(habit.targetDays) ? habit.targetDays : [];
  if (targetDays.length === 0) return false;
  return targetDays.includes(getUTCWeekday(date));
};

/**
 * Calculates the current streak for a habit given its completion logs
 */
const getCurrentStreakFromLogs = (habitLogs, endDate) => {
  if (!Array.isArray(habitLogs) || habitLogs.length === 0) return 0;

  // Create a map of completed dates
  const completedSet = new Set(
    habitLogs
      .filter((log) => log.completed)
      .map((log) => getDateKey(log.date))
  );

  let streak = 0;
  let cursor = normalizeDateOnly(endDate);

  while (true) {
    const key = getDateKey(cursor);
    if (completedSet.has(key)) {
      streak += 1;
      cursor = new Date(cursor.getTime() - DAY_IN_MS);
    } else {
      break;
    }
  }

  return streak;
};

/**
 * Main dashboard endpoint controller
 */
exports.getDashboard = async (req, res, next) => {
  try {
    const userId = req.userId;
    const now = new Date();
    const today = normalizeDateOnly(now);
    const weekStart = new Date(today.getTime() - (today.getUTCDay() * DAY_IN_MS));

    // Parallel queries for all data
    const [allTasks, todayTasks, allNotes, allHabits, habitLogs] = await Promise.all([
      Task.find({ userId }).lean(),
      Task.find({
        userId,
        dueDate: {
          $gte: today,
          $lt: new Date(today.getTime() + DAY_IN_MS),
        },
      }).lean(),
      Note.find({ userId }).lean(),
      Habit.find({ userId, isActive: true }).lean(),
      HabitLog.find({
        userId,
        date: { $gte: weekStart, $lt: new Date(today.getTime() + DAY_IN_MS) },
      }).lean(),
    ]);

    // Calculate task statistics
    const totalTasks = allTasks.length;
    const completedTasks = allTasks.filter((task) => task.completed).length;
    const pendingTasks = totalTasks - completedTasks;
    const taskCompletionRate = totalTasks === 0 ? 0 : (completedTasks / totalTasks) * 100;

    // Calculate today's task statistics
    const todayCompleted = todayTasks.filter((task) => task.completed).length;
    const todayPending = todayTasks.length - todayCompleted;

    // Calculate notes statistics
    const totalNotes = allNotes.length;
    const favoriteNotes = allNotes.filter((note) => note.isFavorite).length;

    // Get recent notes (limit 5, sorted by updatedAt descending)
    const recentNotes = allNotes
      .sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt))
      .slice(0, 5)
      .map((note) => ({
        id: note._id,
        title: note.title,
        category: note.category,
        isFavorite: note.isFavorite,
        updatedAt: note.updatedAt,
      }));

    // Build habit data with completion tracking
    const habitData = allHabits.map((habit) => {
      // Get today's completion status for this habit
      const scheduledToday = isWeeklyHabitScheduled(habit, today);
      const todayLog = habitLogs.find(
        (log) => log.habitId.toString() === habit._id.toString() && getDateKey(log.date) === getDateKey(today)
      );
      const completedToday = scheduledToday && todayLog && todayLog.completed;

      // Calculate current streak
      const habitSpecificLogs = habitLogs.filter(
        (log) => log.habitId.toString() === habit._id.toString()
      );
      const currentStreak = getCurrentStreakFromLogs(habitSpecificLogs, today);

      return {
        id: habit._id,
        name: habit.name,
        category: habit.category,
        frequency: habit.frequency,
        completedToday,
        scheduledToday,
        currentStreak,
      };
    });

    // Calculate habit statistics
    const totalActiveHabits = allHabits.length;
    const completedTodayHabits = habitData.filter((h) => h.completedToday).length;
    const pendingTodayHabits = habitData.filter((h) => h.scheduledToday && !h.completedToday).length;
    const habitCompletionRate =
      totalActiveHabits === 0 ? 0 : (completedTodayHabits / totalActiveHabits) * 100;

    // Get best current streak among all habits
    const bestCurrentStreak = habitData.length > 0 ? Math.max(...habitData.map((h) => h.currentStreak)) : 0;

    // Calculate weekly progress (last 7 days)
    const weeklyProgress = [];
    for (let i = 6; i >= 0; i -= 1) {
      const date = new Date(today.getTime() - i * DAY_IN_MS);
      const dateKey = getDateKey(date);
      const dayName = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.getUTCDay()];

      // Count tasks completed on this date
      const tasksCompletedOnDate = allTasks.filter((task) => {
        if (!task.completed || !task.dueDate) return false;
        return getDateKey(task.dueDate) === dateKey;
      }).length;

      // Count habits completed on this date
      const habitsCompletedOnDate = habitLogs.filter(
        (log) => log.completed && getDateKey(log.date) === dateKey
      ).length;

      weeklyProgress.push({
        date: dateKey,
        day: dayName,
        tasksCompleted: tasksCompletedOnDate,
        habitsCompleted: habitsCompletedOnDate,
      });
    }

    // Get greeting based on time of day
    const hours = now.getHours();
    let greeting = 'Good morning';
    if (hours >= 12 && hours < 17) {
      greeting = 'Good afternoon';
    } else if (hours >= 17 && hours < 21) {
      greeting = 'Good evening';
    } else if (hours >= 21 || hours < 5) {
      greeting = 'Good night';
    }

    // Get recent tasks (limit 5, sorted by updatedAt descending)
    const recentTasks = allTasks
      .sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt))
      .slice(0, 5)
      .map((task) => ({
        id: task._id,
        title: task.title,
        completed: task.completed,
        priority: task.priority,
        dueDate: task.dueDate,
      }));

    // Get today's habit list (limit 10)
    const todayHabits = habitData.filter((h) => h.scheduledToday).slice(0, 10);

    res.status(200).json({
      success: true,
      data: {
        greeting,
        date: getDateKey(today),

        tasks: {
          total: totalTasks,
          completed: completedTasks,
          pending: pendingTasks,
          completionRate: Math.round(taskCompletionRate * 10) / 10,
        },

        todayTasks: {
          total: todayTasks.length,
          completed: todayCompleted,
          pending: todayPending,
        },

        notes: {
          total: totalNotes,
          favorites: favoriteNotes,
        },

        habits: {
          total: totalActiveHabits,
          completedToday: completedTodayHabits,
          pendingToday: pendingTodayHabits,
          completionRate: Math.round(habitCompletionRate * 10) / 10,
        },

        streaks: {
          bestCurrentStreak,
        },

        weeklyProgress,
        recentTasks,
        recentNotes,
        todayHabits,
      },
    });
  } catch (error) {
    next(error);
  }
};
