const express = require("express");
const statsController = require("./stats.controller");
const { requireAuth, requireRole } = require("../../middlewares/auth.middleware");

const router = express.Router();

router.use(requireAuth, requireRole("admin"));

router.get("/overview", statsController.getOverview);
router.get("/orders-trend", statsController.getOrdersTrend);

module.exports = router;
