const express = require("express");
const User = require("./user.model");

console.log("user.routes loaded");

const router = express.Router();

router.get("/test", (req, res) => {
  res.send("users route ok");
});

router.post("/register", async (req, res) => {
  try {
    const { name, email, password, role } = req.body;

    const existingUser = await User.findOne({ email });

    if (existingUser) {
      return res.status(400).json({
        message: "User already exists",
      });
    }

    const newUser = await User.create({
      name,
      email,
      password,
      role,
    });

    res.status(201).json({
      message: "User created successfully",
      data: newUser,
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
});

module.exports = router;