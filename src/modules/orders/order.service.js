const Order = require("./order.model");
const Cart = require("../cart/cart.model");
const Address = require("../addresses/address.model");

const createOrder = async ({
  userId,
  addressId,
  paymentMethod,
  paymentTransactionId = "",
  subtotal,
  tax,
  deliveryCharge,
  discount,
  total,
}) => {
  const [address, cart] = await Promise.all([
    Address.findOne({ _id: addressId, userId }),
    Cart.findOne({ userId }).populate("items.productId"),
  ]);

  if (!address) {
    throw new Error("Address not found");
  }
  if (!cart || !cart.items.length) {
    throw new Error("Cart is empty");
  }

  const items = cart.items.map((entry) => {
    const product = entry.productId;
    const price = Number(product?.price || 0);
    const quantity = Number(entry.quantity || 1);
    return {
      productId: product?._id,
      name: product?.name || "",
      image: product?.image || "",
      price,
      quantity,
      lineTotal: price * quantity,
    };
  });

  const order = await Order.create({
    userId,
    addressId,
    addressText: `[${address.label}] ${address.fullAddress}${address.note ? `, Note: ${address.note}` : ""}`,
    paymentMethod,
    paymentTransactionId,
    subtotal,
    tax,
    deliveryCharge,
    discount,
    total,
    items,
    tracking: [{ status: "placed", note: "Order placed successfully" }],
  });

  cart.items = [];
  await cart.save();

  return order;
};

const listMyOrders = (userId) => Order.find({ userId }).sort({ createdAt: -1 });

const getOrderById = (userId, orderId) => Order.findOne({ _id: orderId, userId });

module.exports = {
  createOrder,
  listMyOrders,
  getOrderById,
};
