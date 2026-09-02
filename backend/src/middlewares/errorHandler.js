/**
 * Global API error handling middleware
 */
const errorHandler = (err, req, res, next) => {
  console.error('🔥 [Server Error]', err);

  const statusCode = err.statusCode || 500;
  const message = err.message || 'เกิดข้อผิดพลาดภายในระบบเซิร์ฟเวอร์';

  res.status(statusCode).json({
    success: false,
    message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
  });
};

/**
 * 404 Not Found Middleware
 */
const notFound = (req, res, next) => {
  res.status(404).json({
    success: false,
    message: `ไม่พบ API endpoint: ${req.originalUrl}`,
  });
};

module.exports = {
  errorHandler,
  notFound,
};
