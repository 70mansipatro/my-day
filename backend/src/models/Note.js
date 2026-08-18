const mongoose = require('mongoose');

const noteSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    title: {
      type: String,
      required: [true, 'Title is required'],
      trim: true,
      minlength: 1,
      maxlength: 150,
    },
    content: {
      type: String,
      required: [true, 'Content is required'],
      trim: true,
      minlength: 1,
      maxlength: 10000,
    },
    category: {
      type: String,
      trim: true,
      default: 'General',
      maxlength: 50,
    },
    isFavorite: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

noteSchema.index({ userId: 1 });
noteSchema.index({ userId: 1, isFavorite: 1 });

module.exports = mongoose.model('Note', noteSchema);
