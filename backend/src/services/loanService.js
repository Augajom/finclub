const LoanModel = require('../models/loanModel');

class LoanService {
  /**
   * Fixed 7-day loan calculation
   * Displays:
   * 1. เงินต้นที่ยืม (Principal)
   * 2. ดอกเบี้ยต่อวัน (Interest per day) & ดอกเบี้ย 7 วัน
   * 3. ค่าดำเนินการหรือธรรมเนียมบริการ (Revenue / Platform / Processing Fee)
   * 4. ยอด Total รวม (Total Repayment)
   */
  static calculate7DaysLoan(principalOrParams, annualRateParam = 35.80) {
    let loanPrincipal;
    let annualRate = annualRateParam;

    if (typeof principalOrParams === 'object' && principalOrParams !== null) {
      loanPrincipal = parseFloat(principalOrParams.principal || principalOrParams.loanAmount || principalOrParams.loan_amount) || 0.0;
      annualRate = parseFloat(principalOrParams.annualRate || principalOrParams.annual_rate) || 35.80;
    } else {
      loanPrincipal = parseFloat(principalOrParams) || 0.0;
    }

    const clampedPrincipal = Math.max(1000.0, Math.min(50000.0, loanPrincipal));

    // Daily interest formula based on 35.80% annual rate: Principal * (AnnualRate / 100) / 365
    const dailyInterestRaw = (clampedPrincipal * (annualRate / 100.0)) / 365.0;
    const interestPerDay = Math.round(dailyInterestRaw * 100) / 100.0;

    // Total 7-day interest
    const totalInterest = Math.round(interestPerDay * 7 * 100) / 100.0;

    // Revenue / Platform / Processing fee - Standard 50.00 THB flat (or 1% if higher)
    const revenueFee = Math.max(50.0, Math.round(clampedPrincipal * 0.01 * 100) / 100.0);

    // Total repayment amount (เงินต้น + ดอกเบี้ย 7 วัน + ค่าดำเนินการ)
    const totalAmount = Math.round((clampedPrincipal + totalInterest + revenueFee) * 100) / 100.0;

    // Calculate due date (7 days from now)
    const dueDate = new Date();
    dueDate.setDate(dueDate.getDate() + 7);
    const formattedDueDate = dueDate.toISOString().split('T')[0];

    return {
      principal: clampedPrincipal,
      tenure_days: 7,
      annual_interest_rate: annualRate,
      interest_per_day: interestPerDay,
      total_interest: totalInterest,
      revenue_fee: revenueFee,
      total_amount: totalAmount,
      due_date: formattedDueDate,
    };
  }

  /**
   * Submit and apply for a 7-day loan
   * @param {Object} params - { userId, principal, annualRate }
   */
  static async applyLoan({ userId, principal, annualRate = 35.80 }) {
    if (!userId) {
      const error = new Error('ไม่พบข้อมูลผู้กู้');
      error.statusCode = 400;
      throw error;
    }

    const calc = this.calculate7DaysLoan(principal, annualRate);

    const createdLoan = await LoanModel.create({
      userId,
      principal: calc.principal,
      interestPerDay: calc.interest_per_day,
      totalInterest: calc.total_interest,
      revenueFee: calc.revenue_fee,
      totalAmount: calc.total_amount,
      tenureDays: 7,
      status: 'approved',
      dueDate: calc.due_date,
    });

    return {
      ...createdLoan,
      ...calc,
    };
  }

  /**
   * Get all loans of a user
   * @param {number} userId
   */
  static async getUserLoans(userId) {
    return LoanModel.findByUserId(userId);
  }
}

module.exports = LoanService;
