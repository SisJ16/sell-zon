const orderService = require("./order.service");

const createOrder = async (req, res) => {
  try {
    const {
      addressId,
      paymentMethod,
      paymentTransactionId = "",
      subtotal,
      tax = 0,
      deliveryCharge = 0,
      discount = 0,
      total,
    } = req.body;

    if (!addressId || !paymentMethod) {
      return res.status(400).json({ message: "addressId and paymentMethod are required" });
    }

    const nSubtotal = Number(subtotal || 0);
    const nTax = Number(tax || 0);
    const nDelivery = Number(deliveryCharge || 0);
    const nDiscount = Number(discount || 0);
    const nTotal = Number(total || 0);

    if ([nSubtotal, nTax, nDelivery, nDiscount, nTotal].some((value) => Number.isNaN(value) || value < 0)) {
      return res.status(400).json({ message: "Invalid amount values" });
    }

    const order = await orderService.createOrder({
      userId: req.user.id,
      addressId,
      paymentMethod,
      paymentTransactionId,
      subtotal: nSubtotal,
      tax: nTax,
      deliveryCharge: nDelivery,
      discount: nDiscount,
      total: nTotal,
    });

    res.status(201).json({ message: "Order created successfully", data: order });
  } catch (error) {
    const statusCode = error.message === "Address not found" || error.message === "Cart is empty" ? 400 : 500;
    res.status(statusCode).json({ message: error.message });
  }
};

const listMyOrders = async (req, res) => {
  try {
    const orders = await orderService.listMyOrders(req.user.id);
    res.status(200).json({ message: "Orders fetched successfully", data: orders });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getMyOrder = async (req, res) => {
  try {
    const order = await orderService.getOrderById(req.user.id, req.params.id);
    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }
    res.status(200).json({ message: "Order fetched successfully", data: order });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  createOrder,
  listMyOrders,
  getMyOrder,
};
