const express = require("express");
const authController = require("./auth.controller");
const { requireAuth } = require("../../middlewares/auth.middleware");

const router = express.Router();

router.post("/register", authController.register);
router.post("/login", authController.login);
router.post("/refresh", authController.refresh);
router.post("/logout", authController.logout);
router.get("/me", requireAuth, (req, res) => {
  res.status(200).json({
    message: "Authorized",
    data: req.user,
  });
});

module.exports = router;
