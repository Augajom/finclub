const { query } = require('../config/db');

class LoanModel {
  /**
   * Create a new loan record
   * @param {Object} loanData
   * @returns {Promise<Object>} Created loan object
   */
  static async create({
    userId,
    principal,
    interestPerDay,
    totalInterest,
    revenueFee,
    totalAmount,
    tenureDays = 7,
    status = 'approved',
    dueDate,
  }) {
    const sql = `
      INSERT INTO \`loans\` 
      (\`user_id\`, \`principal\`, \`interest_per_day\`, \`total_interest\`, \`revenue_fee\`, \`total_amount\`, \`tenure_days\`, \`status\`, \`due_date\`)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    const result = await query(sql, [
      userId,
      principal,
      interestPerDay,
      totalInterest,
      revenueFee,
      totalAmount,
      tenureDays,
      status,
      dueDate,
    ]);

    return this.findById(result.insertId);
  }

  /**
   * Find loan by ID
   * @param {number} id
   * @returns {Promise<Object|null>}
   */
  static async findById(id) {
    const sql = `SELECT * FROM \`loans\` WHERE \`id\` = ? LIMIT 1`;
    const results = await query(sql, [id]);
    return results.length > 0 ? results[0] : null;
  }

  /**
   * Find all loans for a specific user
   * @param {number} userId
   * @returns {Promise<Array>}
   */
  static async findByUserId(userId) {
    const sql = `SELECT * FROM \`loans\` WHERE \`user_id\` = ? ORDER BY \`created_at\` DESC`;
    return query(sql, [userId]);
  }
}

module.exports = LoanModel;
