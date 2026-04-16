const cartService = require("./cart.service");

const getCart = async (req, res) => {
  try {
    const cart = await cartService.getCartByUserId(req.user.id);
    res.status(200).json({ message: "Cart fetched successfully", data: cart });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const addItem = async (req, res) => {
  try {
    const { productId, quantity } = req.body;
    if (!productId) {
      return res.status(400).json({ message: "productId is required" });
    }
    const qty = Number(quantity || 1);
    if (Number.isNaN(qty) || qty <= 0) {
      return res.status(400).json({ message: "quantity must be a positive number" });
    }
    const cart = await cartService.addCartItem(req.user.id, productId, qty);
    res.status(200).json({ message: "Item added to cart", data: cart });
  } catch (error) {
    const statusCode = error.message === "Product not found" ? 404 : 500;
    res.status(statusCode).json({ message: error.message });
  }
};

const updateItemQuantity = async (req, res) => {
  try {
    const quantity = Number(req.body.quantity);
    if (Number.isNaN(quantity)) {
      return res.status(400).json({ message: "quantity must be a number" });
    }
    const cart = await cartService.updateCartItemQuantity(req.user.id, req.params.productId, quantity);
    res.status(200).json({ message: "Cart updated successfully", data: cart });
  } catch (error) {
    const statusCode = error.message === "Cart item not found" ? 404 : 500;
    res.status(statusCode).json({ message: error.message });
  }
};

const removeItem = async (req, res) => {
  try {
    const cart = await cartService.removeCartItem(req.user.id, req.params.productId);
    res.status(200).json({ message: "Item removed from cart", data: cart });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const clearCart = async (req, res) => {
  try {
    const cart = await cartService.clearCart(req.user.id);
    res.status(200).json({ message: "Cart cleared successfully", data: cart });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getCart,
  addItem,
  updateItemQuantity,
  removeItem,
  clearCart,
};
