const mongoose = require("mongoose");

const orderItemSchema = new mongoose.Schema(
  {
    productId: { type: mongoose.Schema.Types.ObjectId, ref: "Product", required: true },
    name: { type: String, required: true },
    image: { type: String, required: true },
    price: { type: Number, required: true, min: 0 },
    quantity: { type: Number, required: true, min: 1 },
    lineTotal: { type: Number, required: true, min: 0 },
  },
  { _id: false }
);

const trackingEventSchema = new mongoose.Schema(
  {
    status: {
      type: String,
      enum: ["placed", "confirmed", "packed", "shipped", "out_for_delivery", "delivered", "cancelled"],
      required: true,
    },
    note: { type: String, default: "" },
    at: { type: Date, default: Date.now },
  },
  { _id: false }
);

const orderSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true, index: true },
    addressId: { type: mongoose.Schema.Types.ObjectId, ref: "Address", required: true },
    addressText: { type: String, required: true },
    paymentMethod: { type: String, required: true },
    paymentTransactionId: { type: String, default: "" },
    status: {
      type: String,
      enum: ["placed", "confirmed", "packed", "shipped", "out_for_delivery", "delivered", "cancelled"],
      default: "placed",
      index: true,
    },
    subtotal: { type: Number, required: true, min: 0 },
    tax: { type: Number, required: true, min: 0, default: 0 },
    deliveryCharge: { type: Number, required: true, min: 0, default: 0 },
    discount: { type: Number, required: true, min: 0, default: 0 },
    total: { type: Number, required: true, min: 0 },
    items: { type: [orderItemSchema], default: [] },
    tracking: { type: [trackingEventSchema], default: [] },
  },
  { timestamps: true }
);

const Order = mongoose.model("Order", orderSchema);

module.exports = Order;
