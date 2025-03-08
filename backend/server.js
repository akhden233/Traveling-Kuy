const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const sequlize = require("./config/database");
const authRoutes = require("./routes/auth_routes");

const  app = express();

app.use(cors());
app.use(bodyParser.json());
app.use("/api/auth", authRoutes);

// sync Database
sequlize.sync()
    .then (() => console.log("Database Synced"))
    .catch(err => console.log("Database Sync Failed:", err));

app.listen(3000, () => console.log("Server Succesfully run on http://localhost:3000"));