const { verifyToken } = require('../config/jwt');
const UserModel = require('../models/userModel');

/**
 * JWT Authentication Middleware
 */
const requireAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'กรุณาเข้าสู่ระบบก่อนทำรายการ (Missing or invalid token)',
      });
    }

    const token = authHeader.split(' ')[1];
    const decoded = verifyToken(token);

    const user = await UserModel.findById(decoded.id);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'ไม่พบบัญชีผู้ใช้ในระบบ',
      });
    }

    req.user = user;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Token หมดอายุหรือไม่ถูกต้อง กรุณาเข้าสู่ระบบใหม่',
      error: error.message,
    });
  }
};

module.exports = {
  requireAuth,
  authenticateToken: requireAuth,
};
