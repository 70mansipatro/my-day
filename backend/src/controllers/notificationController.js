const mongoose = require('mongoose');
const Notification = require('../models/Notification');

const parseId = (req) => {
  const { id } = req.params;
  if (!mongoose.Types.ObjectId.isValid(id)) {
    return null;
  }
  return id;
};

const clampInt = (value, fallback, min, max) => {
  const parsed = Number.parseInt(value, 10);
  if (!Number.isFinite(parsed)) return fallback;
  return Math.min(Math.max(parsed, min), max);
};

exports.getNotifications = async (req, res, next) => {
  try {
    const page = clampInt(req.query.page, 1, 1, 100000);
    const limit = clampInt(req.query.limit, 20, 1, 100);
    const query = { userId: req.userId };

    if (req.query.isRead === 'true' || req.query.isRead === 'false') {
      query.isRead = req.query.isRead === 'true';
    }

    const [notifications, total] = await Promise.all([
      Notification.find(query)
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .lean(),
      Notification.countDocuments(query),
    ]);

    res.status(200).json({
      success: true,
      data: {
        notifications,
        page,
        limit,
        total,
        totalPages: Math.max(Math.ceil(total / limit), 1),
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.getUnreadCount = async (req, res, next) => {
  try {
    const count = await Notification.countDocuments({ userId: req.userId, isRead: false });
    res.status(200).json({ success: true, data: { count } });
  } catch (error) {
    next(error);
  }
};

exports.markAsRead = async (req, res, next) => {
  try {
    const notificationId = parseId(req);
    if (!notificationId) {
      return res.status(400).json({ success: false, message: 'Invalid notification ID' });
    }

    const notification = await Notification.findOneAndUpdate(
      { _id: notificationId, userId: req.userId },
      { isRead: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({ success: false, message: 'Notification not found' });
    }

    res.status(200).json({
      success: true,
      message: 'Notification marked as read',
      data: { notification },
    });
  } catch (error) {
    next(error);
  }
};

exports.markAllAsRead = async (req, res, next) => {
  try {
    await Notification.updateMany(
      { userId: req.userId, isRead: false },
      { isRead: true }
    );

    res.status(200).json({
      success: true,
      message: 'All notifications marked as read',
    });
  } catch (error) {
    next(error);
  }
};

exports.deleteNotification = async (req, res, next) => {
  try {
    const notificationId = parseId(req);
    if (!notificationId) {
      return res.status(400).json({ success: false, message: 'Invalid notification ID' });
    }

    const notification = await Notification.findOneAndDelete({
      _id: notificationId,
      userId: req.userId,
    });

    if (!notification) {
      return res.status(404).json({ success: false, message: 'Notification not found' });
    }

    res.status(200).json({
      success: true,
      message: 'Notification deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};
