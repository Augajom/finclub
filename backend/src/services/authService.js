const bcrypt = require('bcryptjs');
const UserModel = require('../models/userModel');
const { generateToken } = require('../config/jwt');

class AuthService {
  /**
   * Validate password complexity
   * Rules: Uppercase, Lowercase, Number, Special Character, at least 8 chars
   * @param {string} password
   * @returns {{ isValid: boolean, error?: string }}
   */
  static validatePasswordComplexity(password) {
    if (!password || password.length < 8) {
      return { isValid: false, error: 'รหัสผ่านต้องมีความยาวอย่างน้อย 8 ตัวอักษร' };
    }
    if (!/[A-Z]/.test(password)) {
      return { isValid: false, error: 'รหัสผ่านต้องมีตัวอักษรภาษาอังกฤษพิมพ์ใหญ่ (A-Z) อย่างน้อย 1 ตัว' };
    }
    if (!/[a-z]/.test(password)) {
      return { isValid: false, error: 'รหัสผ่านต้องมีตัวอักษรภาษาอังกฤษพิมพ์เล็ก (a-z) อย่างน้อย 1 ตัว' };
    }
    if (!/[0-9]/.test(password)) {
      return { isValid: false, error: 'รหัสผ่านต้องมีตัวเลข (0-9) อย่างน้อย 1 ตัว' };
    }
    if (!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~`]/.test(password)) {
      return { isValid: false, error: 'รหัสผ่านต้องมีอักขระพิเศษ (!@#$%^&*...) อย่างน้อย 1 ตัว' };
    }
    return { isValid: true };
  }

  /**
   * Register new user
   * @param {Object} params - { email, password, rePassword, avatarFile, baseUrl }
   */
  static async register({ email, password, rePassword, avatarFile, baseUrl = 'http://localhost:5000' }) {
    // 1. Basic validation
    if (!email || !password || !rePassword) {
      const error = new Error('กรุณากรอกข้อมูลให้ครบถ้วน (Email, Password, Re-password)');
      error.statusCode = 400;
      throw error;
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      const error = new Error('รูปแบบอีเมลไม่ถูกต้อง');
      error.statusCode = 400;
      throw error;
    }

    // 2. Password match check
    if (password !== rePassword) {
      const error = new Error('รหัสผ่านและการยืนยันรหัสผ่าน (re-password) ไม่ตรงกัน');
      error.statusCode = 400;
      throw error;
    }

    // 3. Password complexity check
    const complexity = this.validatePasswordComplexity(password);
    if (!complexity.isValid) {
      const error = new Error(complexity.error);
      error.statusCode = 400;
      throw error;
    }

    // 4. Duplicate email check
    const existing = await UserModel.findByEmail(email);
    if (existing) {
      const error = new Error('อีเมลนี้ถูกลงทะเบียนในระบบแล้ว กรุณาใช้อีเมลอื่นหรือเข้าสู่ระบบ');
      error.statusCode = 409;
      throw error;
    }

    // 5. Hash password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // 6. Build avatar URL
    let avatarUrl = null;
    if (avatarFile) {
      avatarUrl = `${baseUrl}/uploads/${avatarFile.filename}`;
    }

    // 7. Save to DB
    const user = await UserModel.create({
      email,
      passwordHash,
      avatarUrl,
    });

    // 8. Generate JWT token
    const token = generateToken({ id: user.id, email: user.email });

    return {
      user: {
        id: user.id,
        email: user.email,
        avatar_url: user.avatar_url,
        has_accepted_terms: Boolean(user.has_accepted_terms),
        created_at: user.created_at,
      },
      token,
    };
  }

  /**
   * Login user with email and password
   * @param {Object} params - { email, password }
   */
  static async login({ email, password }) {
    if (!email || !password) {
      const error = new Error('กรุณากรอก Email และ Password');
      error.statusCode = 400;
      throw error;
    }

    const user = await UserModel.findByEmail(email);
    if (!user) {
      const error = new Error('อีเมลหรือรหัสผ่านไม่ถูกต้อง');
      error.statusCode = 401;
      throw error;
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      const error = new Error('อีเมลหรือรหัสผ่านไม่ถูกต้อง');
      error.statusCode = 401;
      throw error;
    }

    const token = generateToken({ id: user.id, email: user.email });

    return {
      user: {
        id: user.id,
        email: user.email,
        avatar_url: user.avatar_url,
        has_accepted_terms: Boolean(user.has_accepted_terms),
        created_at: user.created_at,
      },
      token,
    };
  }

  /**
   * Accept terms and conditions for user
   * @param {number} userId
   * @param {string} ipAddress
   * @param {string} userAgent
   */
  static async acceptTerms(userId, ipAddress, userAgent) {
    await UserModel.updateTermsAccepted(userId, true);
    await UserModel.logTermsAcceptance(userId, ipAddress, userAgent);

    const user = await UserModel.findById(userId);
    return {
      id: user.id,
      email: user.email,
      avatar_url: user.avatar_url,
      has_accepted_terms: true,
    };
  }

  /**
   * Get user profile by ID
   * @param {number} userId
   */
  static async getProfile(userId) {
    const user = await UserModel.findById(userId);
    if (!user) {
      const error = new Error('ไม่พบข้อมูลผู้ใช้');
      error.statusCode = 404;
      throw error;
    }
    return user;
  }

  /**
   * Delete user account and all personal data (Google Play Account Deletion)
   * @param {number} userId
   */
  static async deleteAccount(userId) {
    const user = await UserModel.findById(userId);
    if (!user) {
      const error = new Error('ไม่พบข้อมูลผู้ใช้');
      error.statusCode = 404;
      throw error;
    }
    await UserModel.deleteById(userId);
    return true;
  }
}

module.exports = AuthService;
