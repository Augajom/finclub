const express = require('express');
const router = express.Router();
const LoanController = require('../controllers/loanController');
const { requireAuth } = require('../middlewares/authMiddleware');

// Public calculation route
router.post('/calculate', LoanController.calculate);

// Authenticated loan application & history
router.post('/apply', requireAuth, LoanController.apply);
router.get('/my-loans', requireAuth, LoanController.getMyLoans);

module.exports = router;
