const SavedPlanService = require('../services/savedPlanService');

class SavedPlanController {
  /**
   * GET /api/saved-plans
   */
  static async getSavedPlans(req, res, next) {
    try {
      const userId = req.user.id;
      const plans = await SavedPlanService.getPlansByUser(userId);
      res.status(200).json({
        success: true,
        data: { plans },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/saved-plans
   */
  static async createSavedPlan(req, res, next) {
    try {
      const userId = req.user.id;
      const { title, loan_amount, loanAmount, annual_rate, annualRate, note } = req.body;

      const plan = await SavedPlanService.createPlan(userId, {
        title,
        loanAmount: loanAmount || loan_amount,
        annualRate: annualRate || annual_rate,
        note,
      });

      res.status(201).json({
        success: true,
        message: 'บันทึกแผนคำนวณเรียบร้อยแล้ว',
        data: { plan },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * DELETE /api/saved-plans/:id
   */
  static async deleteSavedPlan(req, res, next) {
    try {
      const userId = req.user.id;
      const planId = req.params.id;

      await SavedPlanService.deletePlan(userId, planId);

      res.status(200).json({
        success: true,
        message: 'ลบรายการบันทึกเรียบร้อยแล้ว',
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = SavedPlanController;
