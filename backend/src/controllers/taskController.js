const mongoose = require('mongoose');
const { validationResult } = require('express-validator');
const Task = require('../models/Task');

const PRIORITY_ORDER = { low: 1, medium: 2, high: 3 };

const escapeRegex = (value) => value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

const getSortConfig = (sortParam) => {
  const sort = sortParam || 'newest';
  const allowed = {
    newest: { createdAt: -1 },
    oldest: { createdAt: 1 },
    dueDate: { dueDate: 1, createdAt: -1 },
    priority: { createdAt: -1 },
  };

  return allowed[sort] || allowed.newest;
};

const buildTaskQuery = (req) => {
  const query = { userId: req.userId };
  const search = typeof req.query.search === 'string' ? req.query.search.trim() : '';
  const completed = req.query.completed;
  const priority = typeof req.query.priority === 'string' ? req.query.priority.trim().toLowerCase() : '';
  const category = typeof req.query.category === 'string' ? req.query.category.trim() : '';

  if (search) {
    const safeSearch = escapeRegex(search);
    query.$or = [
      { title: { $regex: safeSearch, $options: 'i' } },
      { description: { $regex: safeSearch, $options: 'i' } },
    ];
  }

  if (completed === 'true' || completed === 'false') {
    query.completed = completed === 'true';
  }

  if (priority && ['low', 'medium', 'high'].includes(priority)) {
    query.priority = priority;
  }

  if (category) {
    query.category = new RegExp(`^${escapeRegex(category)}$`, 'i');
  }

  return query;
};

const applyClientSidePrioritySort = (tasks, sortParam) => {
  if (sortParam !== 'priority') {
    return tasks;
  }

  return [...tasks].sort((a, b) => {
    const priorityDelta = (PRIORITY_ORDER[b.priority] || 0) - (PRIORITY_ORDER[a.priority] || 0);
    if (priorityDelta !== 0) return priorityDelta;
    return new Date(b.createdAt) - new Date(a.createdAt);
  });
};

const parseTaskId = (req) => {
  const { id } = req.params;
  if (!mongoose.Types.ObjectId.isValid(id)) {
    return null;
  }
  return id;
};

exports.getTasks = async (req, res, next) => {
  try {
    const query = buildTaskQuery(req);
    const sortParam = typeof req.query.sort === 'string' ? req.query.sort : 'newest';
    const sortConfig = getSortConfig(sortParam);

    let tasks = await Task.find(query).sort(sortConfig).lean();
    tasks = applyClientSidePrioritySort(tasks, sortParam);

    res.status(200).json({
      success: true,
      data: { tasks },
    });
  } catch (error) {
    next(error);
  }
};

exports.createTask = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: errors.array()[0].msg,
      });
    }

    const payload = {
      userId: req.userId,
      title: req.body.title?.trim(),
      description: req.body.description?.trim() || '',
      priority: req.body.priority || 'medium',
      completed: Boolean(req.body.completed),
      dueDate: req.body.dueDate ? new Date(req.body.dueDate) : undefined,
      category: req.body.category?.trim() || '',
    };

    const task = await Task.create(payload);

    res.status(201).json({
      success: true,
      message: 'Task created successfully',
      data: { task },
    });
  } catch (error) {
    if (error.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: Object.values(error.errors)[0]?.message || 'Invalid task data',
      });
    }

    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid task data',
      });
    }

    next(error);
  }
};

exports.getTask = async (req, res, next) => {
  try {
    const taskId = parseTaskId(req);
    if (!taskId) {
      return res.status(400).json({ success: false, message: 'Invalid task ID' });
    }

    const task = await Task.findOne({ _id: taskId, userId: req.userId });
    if (!task) {
      return res.status(404).json({ success: false, message: 'Task not found' });
    }

    res.status(200).json({ success: true, data: { task } });
  } catch (error) {
    next(error);
  }
};

exports.updateTask = async (req, res, next) => {
  try {
    const taskId = parseTaskId(req);
    if (!taskId) {
      return res.status(400).json({ success: false, message: 'Invalid task ID' });
    }

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: errors.array()[0].msg,
      });
    }

    const task = await Task.findOne({ _id: taskId, userId: req.userId });
    if (!task) {
      return res.status(404).json({ success: false, message: 'Task not found' });
    }

    const updateData = {
      title: req.body.title !== undefined ? req.body.title.trim() : task.title,
      description: req.body.description !== undefined ? req.body.description.trim() : task.description,
      priority: req.body.priority !== undefined ? req.body.priority : task.priority,
      dueDate: req.body.dueDate !== undefined ? (req.body.dueDate ? new Date(req.body.dueDate) : null) : task.dueDate,
      category: req.body.category !== undefined ? req.body.category.trim() : task.category,
      completed: req.body.completed !== undefined ? Boolean(req.body.completed) : task.completed,
    };

    if (req.body.title !== undefined && !updateData.title) {
      return res.status(400).json({ success: false, message: 'Title is required' });
    }

    Object.assign(task, updateData);
    await task.save();

    res.status(200).json({
      success: true,
      message: 'Task updated successfully',
      data: { task },
    });
  } catch (error) {
    if (error.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: Object.values(error.errors)[0]?.message || 'Invalid task data',
      });
    }

    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid task data',
      });
    }

    next(error);
  }
};

exports.toggleTask = async (req, res, next) => {
  try {
    const taskId = parseTaskId(req);
    if (!taskId) {
      return res.status(400).json({ success: false, message: 'Invalid task ID' });
    }

    const task = await Task.findOne({ _id: taskId, userId: req.userId });
    if (!task) {
      return res.status(404).json({ success: false, message: 'Task not found' });
    }

    task.completed = !task.completed;
    await task.save();

    res.status(200).json({
      success: true,
      message: 'Task status updated',
      data: { task },
    });
  } catch (error) {
    next(error);
  }
};

exports.deleteTask = async (req, res, next) => {
  try {
    const taskId = parseTaskId(req);
    if (!taskId) {
      return res.status(400).json({ success: false, message: 'Invalid task ID' });
    }

    const task = await Task.findOneAndDelete({ _id: taskId, userId: req.userId });
    if (!task) {
      return res.status(404).json({ success: false, message: 'Task not found' });
    }

    res.status(200).json({
      success: true,
      message: 'Task deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};
