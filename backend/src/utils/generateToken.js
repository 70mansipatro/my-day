const jwt = require('jsonwebtoken');

// Signs a JWT carrying only the user's id. Never embed sensitive data here —
// the payload is base64, not encrypted.
const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
};

module.exports = generateToken;
