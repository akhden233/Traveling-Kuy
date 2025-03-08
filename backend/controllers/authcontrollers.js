const user = require("../models/user");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

exports.register = async (req, res) => {
    try {
        const {name, email, password} = req.body;
        const hashedPassword = await bcrypt.hash(password, 10);

        const newUser = await user.create({
            name,
            email,
            password: hashedPassword,
        });

        res.status(201).json({message: "User Registered Succesfully", user});
    } catch (error) {
        res.status(500).json({error: error.message});
    }
};

exports.login = async (req, res) => {
    try{
        const {email, password} = req.body;
        const user = await user.findOne({where: {email} });

        if (!user || !(await bcrypt.compare(password, user.password))) {
            return res.status(401).json({message: "Invalid Credentials"});
        }

        const token = jwt.sign(
            { id: user.id},  
            process.env.SECRET_KEY || "defaultsecret", 
            {expiresIn: "1d"}
        );

        res.json({message: "Login Successful", token});
    } catch (error) {
        res.status(500).json({error: error.message});
    }
};