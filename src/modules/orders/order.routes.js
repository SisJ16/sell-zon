const express = require("express");
const orderController = require("./order.controller");
const { requireAuth } = require("../../middlewares/auth.middleware");

const router = express.Router();

router.use(requireAuth);
router.post("/", orderController.createOrder);
router.get("/", orderController.listMyOrders);
router.get("/:id", orderController.getMyOrder);

module.exports = router;
