const paymentService = require("./payment.service");

const getPaymentMethods = async (_req, res) => {
  try {
    const methods = paymentService.getMethods();
    res.status(200).json({ message: "Payment methods fetched successfully", data: methods });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const processPayment = async (req, res) => {
  try {
    const { method, amount, payload } = req.body;
    if (!method) {
      return res.status(400).json({ message: "method is required" });
    }
    const numericAmount = Number(amount || 0);
    if (Number.isNaN(numericAmount) || numericAmount <= 0) {
      return res.status(400).json({ message: "amount must be greater than 0" });
    }

    const result = paymentService.processPayment({
      method,
      amount: numericAmount,
      payload: payload || {},
    });

    res.status(200).json({
      message: "Payment processed successfully",
      data: result,
    });
  } catch (error) {
    const statusCode =
      error.message === "Invalid payment method" || error.message.endsWith("is required")
        ? 400
        : 500;
    res.status(statusCode).json({ message: error.message });
  }
};

module.exports = {
  getPaymentMethods,
  processPayment,
};
