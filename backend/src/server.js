const app = require('./app');
const { initDatabase } = require('./config/db');
require('dotenv').config();

const PORT = process.env.PORT || 5000;

// Initialize Database connection then start HTTP server
const startServer = async () => {
  try {
    await initDatabase();

    app.listen(PORT, () => {
      console.log(`🚀 [Finclub Backend] Server is running on http://localhost:${PORT}`);
      console.log(`📑 [API Endpoints]:`);
      console.log(`   - POST /api/auth/register (Email, Password, Re-password, Avatar)`);
      console.log(`   - POST /api/auth/login (Email, Password)`);
      console.log(`   - POST /api/auth/accept-terms (Accept Terms & Conditions)`);
      console.log(`   - GET  /api/auth/me (Get User Profile)`);
      console.log(`   - POST /api/loans/calculate (Calculate 7-Day Loan)`);
      console.log(`   - POST /api/loans/apply (Submit 7-Day Loan)`);
      console.log(`   - GET  /api/loans/my-loans (User Loan History)`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
