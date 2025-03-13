const {sequelize, DataTypes} = require("sequelize");
const sequelize = require("../config/database");

const user = sequelize.define("user",{
    id:{
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    name: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    email: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
    },
    password:{
        type: DataTypes.STRING,
        allowNull: false,
    },
}, {
    timestamp: true, // add createdAt & updatedAt automatically
});

// const db = require ("../config/database");

// const user = {
//     create : (name, email, password, callback) => {
//         const query = "Insert INTO users (name, email, password ) VALUES (?, ?, ?)";
//         db.query(query[name, password, email], callback);
//     },

//     findByEmail : (email, callback) => {
//         const query = "SELECT * FROM users WHERE email = ?";
//         db.query(query[email], callback);
//     }
// };

// module.exports = user;