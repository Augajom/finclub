const mysql = require('mysql2/promise');
require('dotenv').config();

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '3306', 10),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'finclub_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
};

let pool = null;
let isConnected = false;
let isMemoryFallback = false;

// In-memory mock database for fallback when MySQL server is not currently running
const memoryDb = {
  users: [],
  loans: [],
  saved_plans: [],
  terms_logs: [],
  userIdCounter: 1,
  loanIdCounter: 1,
  savedPlanIdCounter: 1,
  termsLogIdCounter: 1,
};

/**
 * Initializes database connection pool and creates tables if needed
 */
const initDatabase = async () => {
  try {
    // 1. Check/Create database first
    const rootConnection = await mysql.createConnection({
      host: dbConfig.host,
      port: dbConfig.port,
      user: dbConfig.user,
      password: dbConfig.password,
    });

    await rootConnection.query(
      `CREATE DATABASE IF NOT EXISTS \`${dbConfig.database}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`
    );
    await rootConnection.end();

    // 2. Create connection pool
    pool = mysql.createPool(dbConfig);

    // 3. Test connection
    const connection = await pool.getConnection();
    console.log(`✅ [MySQL] Connected to database: ${dbConfig.database} at ${dbConfig.host}:${dbConfig.port}`);
    isConnected = true;
    isMemoryFallback = false;

    // 4. Initialize tables
    await pool.query(`
      CREATE TABLE IF NOT EXISTS \`users\` (
        \`id\` INT AUTO_INCREMENT PRIMARY KEY,
        \`email\` VARCHAR(255) NOT NULL UNIQUE,
        \`password_hash\` VARCHAR(255) NOT NULL,
        \`avatar_url\` VARCHAR(500) DEFAULT NULL,
        \`has_accepted_terms\` BOOLEAN NOT NULL DEFAULT FALSE,
        \`created_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        \`updated_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX \`idx_users_email\` (\`email\`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS \`loans\` (
        \`id\` INT AUTO_INCREMENT PRIMARY KEY,
        \`user_id\` INT NOT NULL,
        \`principal\` DECIMAL(10, 2) NOT NULL,
        \`interest_per_day\` DECIMAL(10, 2) NOT NULL,
        \`total_interest\` DECIMAL(10, 2) NOT NULL,
        \`revenue_fee\` DECIMAL(10, 2) NOT NULL COMMENT 'ค่าดำเนินการหรือ enue',
        \`total_amount\` DECIMAL(10, 2) NOT NULL,
        \`tenure_days\` INT NOT NULL DEFAULT 7,
        \`status\` ENUM('pending', 'approved', 'paid', 'rejected') NOT NULL DEFAULT 'approved',
        \`due_date\` DATE NOT NULL,
        \`applied_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        \`created_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX \`idx_loans_user_id\` (\`user_id\`),
        CONSTRAINT \`fk_loans_users\` FOREIGN KEY (\`user_id\`) REFERENCES \`users\` (\`id\`) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS \`saved_plans\` (
        \`id\` INT AUTO_INCREMENT PRIMARY KEY,
        \`user_id\` INT NOT NULL,
        \`title\` VARCHAR(255) NOT NULL,
        \`loan_amount\` DECIMAL(10, 2) NOT NULL,
        \`interest_per_day\` DECIMAL(10, 2) NOT NULL,
        \`total_interest\` DECIMAL(10, 2) NOT NULL,
        \`revenue_fee\` DECIMAL(10, 2) NOT NULL,
        \`total_amount\` DECIMAL(10, 2) NOT NULL,
        \`tenure_days\` INT NOT NULL DEFAULT 7,
        \`due_date\` VARCHAR(100) NOT NULL,
        \`annual_interest_rate\` DECIMAL(5, 2) NOT NULL DEFAULT 35.80,
        \`note\` TEXT DEFAULT NULL,
        \`created_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX \`idx_saved_plans_user\` (\`user_id\`),
        CONSTRAINT \`fk_saved_plans_users\` FOREIGN KEY (\`user_id\`) REFERENCES \`users\` (\`id\`) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS \`terms_logs\` (
        \`id\` INT AUTO_INCREMENT PRIMARY KEY,
        \`user_id\` INT NOT NULL,
        \`accepted_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        \`ip_address\` VARCHAR(45) DEFAULT NULL,
        \`user_agent\` VARCHAR(255) DEFAULT NULL,
        CONSTRAINT \`fk_terms_users\` FOREIGN KEY (\`user_id\`) REFERENCES \`users\` (\`id\`) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);

    connection.release();
    console.log('✅ [MySQL] Tables (users, loans, saved_plans, terms_logs) initialized successfully');
  } catch (error) {
    console.warn(`⚠️ [MySQL] Could not connect to MySQL server (${error.message}).`);
    console.warn(`💡 [MySQL] Running with in-memory database fallback for active API development.`);
    isConnected = false;
    isMemoryFallback = true;
  }
};

/**
 * Execute query on MySQL pool or fallback memory DB
 */
const query = async (sql, params = []) => {
  if (isConnected && pool) {
    const [results] = await pool.query(sql, params);
    return results;
  }

  // Handle in-memory fallback
  return handleMemoryQuery(sql, params);
};

// Internal query simulator for in-memory fallback
const handleMemoryQuery = (sql, params = []) => {
  const normalizedSql = sql.trim().toLowerCase();

  // 1. Insert User
  if (normalizedSql.startsWith('insert into `users`') || normalizedSql.startsWith('insert into users')) {
    const id = memoryDb.userIdCounter++;
    const [email, password_hash, avatar_url, has_accepted_terms] = params;
    const user = {
      id,
      email,
      password_hash,
      avatar_url: avatar_url || null,
      has_accepted_terms: Boolean(has_accepted_terms),
      created_at: new Date(),
      updated_at: new Date(),
    };
    memoryDb.users.push(user);
    return { insertId: id, affectedRows: 1 };
  }

  // 2. Select User by Email
  if (normalizedSql.includes('from `users` where `email` = ?') || normalizedSql.includes('from users where email = ?')) {
    const email = params[0];
    return memoryDb.users.filter((u) => u.email.toLowerCase() === email.toLowerCase());
  }

  // 3. Select User by ID
  if (normalizedSql.includes('from `users` where `id` = ?') || normalizedSql.includes('from users where id = ?')) {
    const id = parseInt(params[0], 10);
    return memoryDb.users.filter((u) => u.id === id);
  }

  // 4. Update terms accepted
  if (normalizedSql.startsWith('update `users` set `has_accepted_terms` = ?') || normalizedSql.startsWith('update users set has_accepted_terms = ?')) {
    const [has_accepted, id] = params;
    const user = memoryDb.users.find((u) => u.id === parseInt(id, 10));
    if (user) {
      user.has_accepted_terms = Boolean(has_accepted);
      user.updated_at = new Date();
      return { affectedRows: 1 };
    }
    return { affectedRows: 0 };
  }

  // 5. Insert Saved Plan
  if (normalizedSql.startsWith('insert into `saved_plans`') || normalizedSql.startsWith('insert into saved_plans')) {
    const id = memoryDb.savedPlanIdCounter++;
    const [user_id, title, loan_amount, interest_per_day, total_interest, revenue_fee, total_amount, tenure_days, due_date, annual_interest_rate, note] = params;
    const plan = {
      id,
      user_id: parseInt(user_id, 10),
      title,
      loan_amount: parseFloat(loan_amount),
      interest_per_day: parseFloat(interest_per_day),
      total_interest: parseFloat(total_interest),
      revenue_fee: parseFloat(revenue_fee),
      total_amount: parseFloat(total_amount),
      tenure_days: parseInt(tenure_days, 10) || 7,
      due_date,
      annual_interest_rate: parseFloat(annual_interest_rate) || 35.80,
      note: note || null,
      created_at: new Date(),
    };
    memoryDb.saved_plans.push(plan);
    return { insertId: id, affectedRows: 1 };
  }

  // 6. Select Saved Plans by user_id
  if (normalizedSql.includes('from `saved_plans` where `user_id` = ?') || normalizedSql.includes('from saved_plans where user_id = ?')) {
    const userId = parseInt(params[0], 10);
    return memoryDb.saved_plans
      .filter((p) => p.user_id === userId)
      .sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
  }

  // 7. Delete Saved Plan by id and user_id
  if (normalizedSql.startsWith('delete from `saved_plans` where `id` = ? and `user_id` = ?') || normalizedSql.startsWith('delete from saved_plans where id = ? and user_id = ?')) {
    const [id, userId] = params;
    const initialLen = memoryDb.saved_plans.length;
    memoryDb.saved_plans = memoryDb.saved_plans.filter((p) => !(p.id === parseInt(id, 10) && p.user_id === parseInt(userId, 10)));
    return { affectedRows: initialLen - memoryDb.saved_plans.length };
  }

  // 8. Insert Loan
  if (normalizedSql.startsWith('insert into `loans`') || normalizedSql.startsWith('insert into loans')) {
    const id = memoryDb.loanIdCounter++;
    const [user_id, principal, interest_per_day, total_interest, revenue_fee, total_amount, tenure_days, status, due_date] = params;
    const loan = {
      id,
      user_id: parseInt(user_id, 10),
      principal: parseFloat(principal),
      interest_per_day: parseFloat(interest_per_day),
      total_interest: parseFloat(total_interest),
      revenue_fee: parseFloat(revenue_fee),
      total_amount: parseFloat(total_amount),
      tenure_days: parseInt(tenure_days, 10) || 7,
      status: status || 'approved',
      due_date,
      applied_at: new Date(),
      created_at: new Date(),
    };
    memoryDb.loans.push(loan);
    return { insertId: id, affectedRows: 1 };
  }

  // 9. Select Loans by user_id
  if (normalizedSql.includes('from `loans` where `user_id` = ?') || normalizedSql.includes('from loans where user_id = ?')) {
    const userId = parseInt(params[0], 10);
    return memoryDb.loans
      .filter((l) => l.user_id === userId)
      .sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
  }

  // 10. Insert Terms Log
  if (normalizedSql.startsWith('insert into `terms_logs`') || normalizedSql.startsWith('insert into terms_logs')) {
    const id = memoryDb.termsLogIdCounter++;
    const [user_id, ip_address, user_agent] = params;
    memoryDb.terms_logs.push({
      id,
      user_id: parseInt(user_id, 10),
      accepted_at: new Date(),
      ip_address,
      user_agent,
    });
    return { insertId: id, affectedRows: 1 };
  }

  return [];
};

module.exports = {
  initDatabase,
  query,
  isDatabaseConnected: () => isConnected,
  isMemoryFallbackMode: () => isMemoryFallback,
};
