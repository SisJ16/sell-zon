const Cart = require("./cart.model");
const Product = require("../products/product.model");

const ensureProduct = async (productId) => {
  const product = await Product.findById(productId);
  if (!product || !product.isActive) {
    throw new Error("Product not found");
  }
  return product;
};

const getOrCreateCart = async (userId) => {
  let cart = await Cart.findOne({ userId }).populate("items.productId");
  if (!cart) {
    cart = await Cart.create({ userId, items: [] });
    cart = await Cart.findOne({ userId }).populate("items.productId");
  }
  return cart;
};

const toCartResponse = (cart) => {
  const items = cart.items.map((item) => {
    const unitPrice = item.productId?.price || 0;
    const lineTotal = unitPrice * item.quantity;
    return {
      product: item.productId,
      quantity: item.quantity,
      lineTotal,
    };
  });

  const totalItems = items.reduce((sum, item) => sum + item.quantity, 0);
  const subtotal = items.reduce((sum, item) => sum + item.lineTotal, 0);

  return {
    _id: cart._id,
    userId: cart.userId,
    items,
    totalItems,
    subtotal,
    updatedAt: cart.updatedAt,
  };
};

const getCartByUserId = async (userId) => {
  const cart = await getOrCreateCart(userId);
  return toCartResponse(cart);
};

const addCartItem = async (userId, productId, quantity = 1) => {
  await ensureProduct(productId);
  const cart = await getOrCreateCart(userId);
  const item = cart.items.find((entry) => String(entry.productId?._id || entry.productId) === String(productId));
  if (item) {
    item.quantity += quantity;
  } else {
    cart.items.push({ productId, quantity });
  }
  await cart.save();
  const updated = await Cart.findOne({ userId }).populate("items.productId");
  return toCartResponse(updated);
};

const updateCartItemQuantity = async (userId, productId, quantity) => {
  const cart = await getOrCreateCart(userId);
  const item = cart.items.find((entry) => String(entry.productId?._id || entry.productId) === String(productId));
  if (!item) {
    throw new Error("Cart item not found");
  }
  if (quantity <= 0) {
    cart.items = cart.items.filter(
      (entry) => String(entry.productId?._id || entry.productId) !== String(productId)
    );
  } else {
    item.quantity = quantity;
  }
  await cart.save();
  const updated = await Cart.findOne({ userId }).populate("items.productId");
  return toCartResponse(updated);
};

const removeCartItem = async (userId, productId) => {
  const cart = await getOrCreateCart(userId);
  cart.items = cart.items.filter(
    (entry) => String(entry.productId?._id || entry.productId) !== String(productId)
  );
  await cart.save();
  const updated = await Cart.findOne({ userId }).populate("items.productId");
  return toCartResponse(updated);
};

const clearCart = async (userId) => {
  const cart = await getOrCreateCart(userId);
  cart.items = [];
  await cart.save();
  return toCartResponse(cart);
};

module.exports = {
  getCartByUserId,
  addCartItem,
  updateCartItemQuantity,
  removeCartItem,
  clearCart,
};
