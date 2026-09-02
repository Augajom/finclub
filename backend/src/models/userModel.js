const { query } = require('../config/db');

class UserModel {
  /**
   * Create a new user in database
   * @param {Object} userData - { email, passwordHash, avatarUrl }
   * @returns {Promise<Object>} Created user record
   */
  static async create({ email, passwordHash, avatarUrl = null }) {
    const sql = `
      INSERT INTO \`users\` (\`email\`, \`password_hash\`, \`avatar_url\`, \`has_accepted_terms\`)
      VALUES (?, ?, ?, FALSE)
    `;
    const result = await query(sql, [email.toLowerCase(), passwordHash, avatarUrl]);
    return this.findById(result.insertId);
  }

  /**
   * Find user by email
   * @param {string} email
   * @returns {Promise<Object|null>}
   */
  static async findByEmail(email) {
    const sql = `SELECT * FROM \`users\` WHERE \`email\` = ? LIMIT 1`;
    const results = await query(sql, [email.toLowerCase()]);
    return results.length > 0 ? results[0] : null;
  }

  /**
   * Find user by ID
   * @param {number} id
   * @returns {Promise<Object|null>}
   */
  static async findById(id) {
    const sql = `
      SELECT \`id\`, \`email\`, \`avatar_url\`, \`has_accepted_terms\`, \`created_at\`, \`updated_at\`
      FROM \`users\`
      WHERE \`id\` = ?
      LIMIT 1
    `;
    const results = await query(sql, [id]);
    return results.length > 0 ? results[0] : null;
  }

  /**
   * Update terms acceptance flag
   * @param {number} userId
   * @param {boolean} hasAccepted
   * @returns {Promise<boolean>}
   */
  static async updateTermsAccepted(userId, hasAccepted = true) {
    const sql = `UPDATE \`users\` SET \`has_accepted_terms\` = ? WHERE \`id\` = ?`;
    const result = await query(sql, [hasAccepted, userId]);
    return result.affectedRows > 0;
  }

  /**
   * Update user avatar
   * @param {number} userId
   * @param {string} avatarUrl
   * @returns {Promise<boolean>}
   */
  static async updateAvatar(userId, avatarUrl) {
    const sql = `UPDATE \`users\` SET \`avatar_url\` = ? WHERE \`id\` = ?`;
    const result = await query(sql, [avatarUrl, userId]);
    return result.affectedRows > 0;
  }

  /**
   * Log terms acceptance
   * @param {number} userId
   * @param {string} ipAddress
   * @param {string} userAgent
   */
  static async logTermsAcceptance(userId, ipAddress, userAgent) {
    const sql = `INSERT INTO \`terms_logs\` (\`user_id\`, \`ip_address\`, \`user_agent\`) VALUES (?, ?, ?)`;
    await query(sql, [userId, ipAddress || null, userAgent || null]);
  }
}

module.exports = UserModel;
