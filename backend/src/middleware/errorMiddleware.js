// Centralized error handler. Any error passed to next(err) ends up here.
const errorMiddleware = (err, req, res, next) => {
  console.error(err.stack);
  res.status(err.statusCode || 500).json({
    success: false,
    message: err.message || 'Something went wrong',
  });
};

module.exports = errorMiddleware;
