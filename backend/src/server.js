require('dotenv').config();

const app = require('./app');
const connectDB = require('./config/db');
const notificationScheduler = require('./services/notificationScheduler');

const PORT = process.env.PORT || 5000;

// Connect to MongoDB in the background so a slow/unavailable database
// (e.g. MONGO_URI not set up yet) never blocks the API from starting.
connectDB();

notificationScheduler.start();

app.listen(PORT, () => {
  console.log(`MyDay API server running on port ${PORT}`);
});
