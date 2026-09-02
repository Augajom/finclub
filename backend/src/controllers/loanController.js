const LoanService = require('../services/loanService');

class LoanController {
  /**
   * POST /api/loans/calculate
   */
  static calculate(req, res, next) {
    try {
      const { principal, annual_rate } = req.body;
      const result = LoanService.calculate7DaysLoan(principal, annual_rate);

      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/loans/apply (Authenticated)
   */
  static async apply(req, res, next) {
    try {
      const userId = req.user.id;
      const { principal, annual_rate } = req.body;

      const result = await LoanService.applyLoan({
        userId,
        principal,
        annualRate: annual_rate,
      });

      res.status(201).json({
        success: true,
        message: 'ยื่นขอกู้สินเชื่อ 7 วันสำเร็จ สินเชื่อได้รับการอนุมัติแล้ว',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/loans/my-loans (Authenticated)
   */
  static async getMyLoans(req, res, next) {
    try {
      const userId = req.user.id;
      const loans = await LoanService.getUserLoans(userId);

      res.status(200).json({
        success: true,
        data: { loans },
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = LoanController;
