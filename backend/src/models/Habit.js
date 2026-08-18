const mongoose = require('mongoose');

const habitSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    name: {
      type: String,
      required: [true, 'Name is required'],
      trim: true,
      minlength: 1,
      maxlength: 100,
    },
    description: {
      type: String,
      trim: true,
      default: '',
      maxlength: 500,
    },
    category: {
      type: String,
      trim: true,
      default: 'General',
      maxlength: 50,
    },
    frequency: {
      type: String,
      enum: ['daily', 'weekly'],
      default: 'daily',
    },
    targetDays: {
      type: [Number],
      default: [],
      validate: {
        validator(value) {
          if (!Array.isArray(value)) return false;
          if (value.length === 0) return true;
          return value.every((day) => Number.isInteger(day) && day >= 0 && day <= 6);
        },
        message: 'targetDays must contain numbers from 0 to 6',
      },
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  { timestamps: true }
);

habitSchema.index({ userId: 1, isActive: 1 });
habitSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('Habit', habitSchema);
