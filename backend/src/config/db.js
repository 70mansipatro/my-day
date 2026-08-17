const mongoose = require('mongoose');

// Connects to MongoDB Atlas using the connection string from .env.
// Credentials are never hardcoded here.
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('MongoDB connected');
  } catch (error) {
    console.error(`MongoDB connection error: ${error.message}`);
  }
};

module.exports = connectDB;
