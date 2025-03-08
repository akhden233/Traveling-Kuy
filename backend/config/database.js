// Cara 1
const { Sequelize } = require("sequelize");
require("dotenv").config();

const db = new Sequelize(process.env.DB_NAME, process.env.DB_PASS, process.env.DB_USER, {
    host: process.env.DB_HOST,
    dialect: "mysql",
    logging: false,
});

sequelize.authenticate()
    .then(() => console.log("Database Connected!"))
    .catch(err => console.error("Connection Failed", err));

module.exports = sequelize;


// Cara 2
// const mysql = require('mysql2');

// const db = mysql.createConnection({
//     host: 'localhost', // atau ip server db
//     user: 'root', // usrname MYSQL
//     password: '',
//     database: 'travelling_kuy', // db di .env
// });

// db.connect((err) => {
//     if (err) {
//         console.error('❌ Database connection failed: ' + err.stack);
//         return;
//     }
//     console.log('✅ Connected to MySQL database as id ' + db.threadId);
// });

// module.exports = db;