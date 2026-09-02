const express = require('express');
const router = express.Router();
const SavedPlanController = require('../controllers/savedPlanController');
const { requireAuth } = require('../middlewares/authMiddleware');

// All saved plans routes require active user authentication token
router.use(requireAuth);

router.get('/', SavedPlanController.getSavedPlans);
router.post('/', SavedPlanController.createSavedPlan);
router.delete('/:id', SavedPlanController.deleteSavedPlan);

module.exports = router;
