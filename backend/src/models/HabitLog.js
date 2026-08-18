const mongoose = require('mongoose');

const habitLogSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    habitId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Habit',
      required: true,
      index: true,
    },
    date: {
      type: Date,
      required: true,
      set(value) {
        if (!value) return value;
        const next = new Date(value);
        return new Date(Date.UTC(next.getUTCFullYear(), next.getUTCMonth(), next.getUTCDate()));
      },
    },
    completed: {
      type: Boolean,
      default: true,
    },
  },
  { timestamps: true }
);

habitLogSchema.index({ habitId: 1, date: 1 }, { unique: true });
habitLogSchema.index({ userId: 1, date: 1 });

module.exports = mongoose.model('HabitLog', habitLogSchema);
