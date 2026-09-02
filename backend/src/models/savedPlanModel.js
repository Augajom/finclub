const { query } = require('../config/db');

class SavedPlanModel {
  /**
   * Create a new saved loan plan for user
   */
  static async create({
    userId,
    title,
    loanAmount,
    interestPerDay,
    totalInterest,
    revenueFee,
    totalAmount,
    tenureDays = 7,
    dueDate,
    annualInterestRate = 35.80,
    note = null,
  }) {
    const sql = `
      INSERT INTO \`saved_plans\` 
        (\`user_id\`, \`title\`, \`loan_amount\`, \`interest_per_day\`, \`total_interest\`, \`revenue_fee\`, \`total_amount\`, \`tenure_days\`, \`due_date\`, \`annual_interest_rate\`, \`note\`)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    const params = [
      userId,
      title,
      loanAmount,
      interestPerDay,
      totalInterest,
      revenueFee,
      totalAmount,
      tenureDays,
      dueDate,
      annualInterestRate,
      note,
    ];

    const result = await query(sql, params);
    return {
      id: result.insertId,
      user_id: userId,
      title,
      loan_amount: loanAmount,
      interest_per_day: interestPerDay,
      total_interest: totalInterest,
      revenue_fee: revenueFee,
      total_amount: totalAmount,
      tenure_days: tenureDays,
      due_date: dueDate,
      annual_interest_rate: annualInterestRate,
      note,
      created_at: new Date(),
    };
  }

  /**
   * Find all saved plans for a specific user ID
   */
  static async findByUserId(userId) {
    const sql = `
      SELECT * FROM \`saved_plans\` 
      WHERE \`user_id\` = ? 
      ORDER BY \`created_at\` DESC
    `;
    const rows = await query(sql, [userId]);
    return rows;
  }

  /**
   * Delete a saved plan by ID for a specific user ID
   */
  static async deleteByIdAndUserId(id, userId) {
    const sql = `
      DELETE FROM \`saved_plans\` 
      WHERE \`id\` = ? AND \`user_id\` = ?
    `;
    const result = await query(sql, [id, userId]);
    return result.affectedRows > 0;
  }
}

module.exports = SavedPlanModel;
