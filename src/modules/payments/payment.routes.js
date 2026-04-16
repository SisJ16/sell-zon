const express = require("express");
const paymentController = require("./payment.controller");
const { requireAuth } = require("../../middlewares/auth.middleware");

const router = express.Router();

router.use(requireAuth);
router.get("/methods", paymentController.getPaymentMethods);
router.post("/process", paymentController.processPayment);

module.exports = router;
