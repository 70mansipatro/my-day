const mongoose = require('mongoose');
const { validationResult } = require('express-validator');
const Note = require('../models/Note');

const escapeRegex = (value) => value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

const getSortConfig = (sortParam) => {
  const sort = sortParam || 'newest';
  const allowed = {
    newest: { updatedAt: -1, createdAt: -1 },
    oldest: { updatedAt: 1, createdAt: 1 },
    favorite: { isFavorite: -1, updatedAt: -1, createdAt: -1 },
  };

  return allowed[sort] || allowed.newest;
};

const buildNoteQuery = (req) => {
  const query = { userId: req.userId };
  const search = typeof req.query.search === 'string' ? req.query.search.trim() : '';
  const category = typeof req.query.category === 'string' ? req.query.category.trim() : '';
  const favorite = req.query.favorite;

  if (search) {
    query.$or = [
      { title: { $regex: escapeRegex(search), $options: 'i' } },
      { content: { $regex: escapeRegex(search), $options: 'i' } },
    ];
  }

  if (favorite === 'true' || favorite === 'false') {
    query.isFavorite = favorite === 'true';
  }

  if (category) {
    query.category = new RegExp(`^${escapeRegex(category)}$`, 'i');
  }

  return query;
};

const parseNoteId = (req) => {
  const { id } = req.params;
  if (!mongoose.Types.ObjectId.isValid(id)) {
    return null;
  }

  return id;
};

exports.getNotes = async (req, res, next) => {
  try {
    const query = buildNoteQuery(req);
    const sortParam = typeof req.query.sort === 'string' ? req.query.sort : 'newest';

    const notes = await Note.find(query).sort(getSortConfig(sortParam)).lean();

    res.status(200).json({
      success: true,
      data: { notes },
    });
  } catch (error) {
    next(error);
  }
};

exports.createNote = async (req, res, next) => {
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
      content: req.body.content?.trim(),
      category: req.body.category?.trim() || 'General',
      isFavorite: Boolean(req.body.isFavorite),
    };

    const note = await Note.create(payload);

    res.status(201).json({
      success: true,
      message: 'Note created successfully',
      data: { note },
    });
  } catch (error) {
    if (error.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: Object.values(error.errors)[0]?.message || 'Invalid note data',
      });
    }

    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid note data',
      });
    }

    next(error);
  }
};

exports.getNote = async (req, res, next) => {
  try {
    const noteId = parseNoteId(req);
    if (!noteId) {
      return res.status(400).json({ success: false, message: 'Invalid note ID' });
    }

    const note = await Note.findOne({ _id: noteId, userId: req.userId });
    if (!note) {
      return res.status(404).json({ success: false, message: 'Note not found' });
    }

    res.status(200).json({
      success: true,
      data: { note },
    });
  } catch (error) {
    next(error);
  }
};

exports.updateNote = async (req, res, next) => {
  try {
    const noteId = parseNoteId(req);
    if (!noteId) {
      return res.status(400).json({ success: false, message: 'Invalid note ID' });
    }

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: errors.array()[0].msg,
      });
    }

    const note = await Note.findOne({ _id: noteId, userId: req.userId });
    if (!note) {
      return res.status(404).json({ success: false, message: 'Note not found' });
    }

    const nextTitle = req.body.title !== undefined ? req.body.title.trim() : note.title;
    const nextContent = req.body.content !== undefined ? req.body.content.trim() : note.content;
    const nextCategory = req.body.category !== undefined ? req.body.category.trim() || 'General' : note.category || 'General';
    const nextFavorite = req.body.isFavorite !== undefined ? Boolean(req.body.isFavorite) : note.isFavorite;

    if (req.body.title !== undefined && !nextTitle) {
      return res.status(400).json({ success: false, message: 'Title is required' });
    }

    if (req.body.content !== undefined && !nextContent) {
      return res.status(400).json({ success: false, message: 'Content is required' });
    }

    note.title = nextTitle;
    note.content = nextContent;
    note.category = nextCategory;
    note.isFavorite = nextFavorite;

    await note.save();

    res.status(200).json({
      success: true,
      message: 'Note updated successfully',
      data: { note },
    });
  } catch (error) {
    if (error.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: Object.values(error.errors)[0]?.message || 'Invalid note data',
      });
    }

    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid note data',
      });
    }

    next(error);
  }
};

exports.toggleFavorite = async (req, res, next) => {
  try {
    const noteId = parseNoteId(req);
    if (!noteId) {
      return res.status(400).json({ success: false, message: 'Invalid note ID' });
    }

    const note = await Note.findOne({ _id: noteId, userId: req.userId });
    if (!note) {
      return res.status(404).json({ success: false, message: 'Note not found' });
    }

    note.isFavorite = !note.isFavorite;
    await note.save();

    res.status(200).json({
      success: true,
      message: 'Favorite status updated',
      data: { note },
    });
  } catch (error) {
    next(error);
  }
};

exports.deleteNote = async (req, res, next) => {
  try {
    const noteId = parseNoteId(req);
    if (!noteId) {
      return res.status(400).json({ success: false, message: 'Invalid note ID' });
    }

    const note = await Note.findOneAndDelete({ _id: noteId, userId: req.userId });
    if (!note) {
      return res.status(404).json({ success: false, message: 'Note not found' });
    }

    res.status(200).json({
      success: true,
      message: 'Note deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};
