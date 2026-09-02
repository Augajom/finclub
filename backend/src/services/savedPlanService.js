const SavedPlanModel = require('../models/savedPlanModel');
const LoanService = require('./loanService');

class SavedPlanService {
  /**
   * Get all saved plans for a user
   * @param {number} userId
   */
  static async getPlansByUser(userId) {
    const plans = await SavedPlanModel.findByUserId(userId);
    return plans.map((p) => ({
      id: p.id.toString(),
      title: p.title,
      loanAmount: parseFloat(p.loan_amount),
      interestPerDay: parseFloat(p.interest_per_day),
      totalInterest: parseFloat(p.total_interest),
      revenueFee: parseFloat(p.revenue_fee),
      totalAmount: parseFloat(p.total_amount),
      tenureDays: parseInt(p.tenure_days, 10),
      dueDate: p.due_date,
      annualInterestRate: parseFloat(p.annual_interest_rate),
      note: p.note,
      createdAt: p.created_at,
    }));
  }

  /**
   * Create and save a new 7-day loan plan for a user
   * @param {number} userId
   * @param {Object} planData
   */
  static async createPlan(userId, { title, loanAmount, annualRate = 35.80, note }) {
    const amount = parseFloat(loanAmount);
    if (isNaN(amount) || amount < 1000 || amount > 50000) {
      const error = new Error('วงเงินสินเชื่อต้องอยู่ระหว่าง 1,000 ถึง 50,000 บาท');
      error.statusCode = 400;
      throw error;
    }

    const rate = parseFloat(annualRate) || 35.80;

    // Compute metrics
    const calculation = LoanService.calculate7DaysLoan(amount, rate);

    const planTitle = title || `สินเชื่อ 7 วัน ฿${amount.toLocaleString()}`;

    const saved = await SavedPlanModel.create({
      userId,
      title: planTitle,
      loanAmount: calculation.principal,
      interestPerDay: calculation.interest_per_day,
      totalInterest: calculation.total_interest,
      revenueFee: calculation.revenue_fee,
      totalAmount: calculation.total_amount,
      tenureDays: calculation.tenure_days,
      dueDate: calculation.due_date,
      annualInterestRate: calculation.annual_interest_rate,
      note: note || null,
    });

    return {
      id: saved.id.toString(),
      title: saved.title,
      loanAmount: saved.loan_amount,
      interestPerDay: saved.interest_per_day,
      totalInterest: saved.total_interest,
      revenueFee: saved.revenue_fee,
      totalAmount: saved.total_amount,
      tenureDays: saved.tenure_days,
      dueDate: saved.due_date,
      annualInterestRate: saved.annual_interest_rate,
      note: saved.note,
      createdAt: saved.created_at,
    };
  }

  /**
   * Delete a plan by ID belonging to the user
   * @param {number} userId
   * @param {string|number} planId
   */
  static async deletePlan(userId, planId) {
    const deleted = await SavedPlanModel.deleteByIdAndUserId(planId, userId);
    if (!deleted) {
      const error = new Error('ไม่พบรายการบันทึกนี้ หรือไม่มีสิทธิ์ในการลบ');
      error.statusCode = 404;
      throw error;
    }
    return true;
  }
}

module.exports = SavedPlanService;
