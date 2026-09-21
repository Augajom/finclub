const express = require('express');
const router = express.Router();
const AuthController = require('../controllers/authController');
const { requireAuth } = require('../middlewares/authMiddleware');
const upload = require('../middlewares/uploadMiddleware');

// Public routes
router.post('/register', upload.single('avatar'), AuthController.register);
router.post('/login', AuthController.login);

// Authenticated routes
router.post('/accept-terms', requireAuth, upload.single('evidence'), AuthController.acceptTerms);
router.get('/me', requireAuth, AuthController.getMe);
router.delete('/account', requireAuth, AuthController.deleteAccount);

module.exports = router;
