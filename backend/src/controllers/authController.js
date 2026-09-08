const AuthService = require('../services/authService');

class AuthController {
  /**
   * POST /api/auth/register
   */
  static async register(req, res, next) {
    try {
      const { email, password, re_password } = req.body;
      const baseUrl = `${req.protocol}://${req.get('host')}`;

      const result = await AuthService.register({
        email,
        password,
        rePassword: re_password,
        avatarFile: req.file,
        baseUrl,
      });

      res.status(201).json({
        success: true,
        message: 'สมัครสมาชิกสำเร็จยินดีต้อนรับสู่ Finclub',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/auth/login
   */
  static async login(req, res, next) {
    try {
      const { email, password } = req.body;
      const result = await AuthService.login({ email, password });

      res.status(200).json({
        success: true,
        message: 'เข้าสู่ระบบสำเร็จ',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/auth/accept-terms
   */
  static async acceptTerms(req, res, next) {
    try {
      const userId = req.user.id;
      const ipAddress = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
      const userAgent = req.headers['user-agent'];

      const updatedUser = await AuthService.acceptTerms(userId, ipAddress, userAgent);

      res.status(200).json({
        success: true,
        message: 'บันทึกการยอมรับข้อกำหนดและเงื่อนไขเรียบร้อยแล้ว',
        data: { user: updatedUser },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/auth/me
   */
  static async getMe(req, res, next) {
    try {
      const user = await AuthService.getProfile(req.user.id);
      res.status(200).json({
        success: true,
        data: { user },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * DELETE /api/auth/account (Google Play Account Deletion)
   */
  static async deleteAccount(req, res, next) {
    try {
      await AuthService.deleteAccount(req.user.id);
      res.status(200).json({
        success: true,
        message: 'ลบบัญชีผู้ใช้และข้อมูลทั้งหมดเรียบร้อยแล้ว',
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = AuthController;
