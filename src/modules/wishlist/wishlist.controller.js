const wishlistService = require("./wishlist.service");

const listWishlist = async (req, res) => {
  try {
    const items = await wishlistService.getWishlistByUserId(req.user.id);
    res.status(200).json({ message: "Wishlist fetched successfully", data: items });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const addWishlistItem = async (req, res) => {
  try {
    const { productId } = req.body;
    if (!productId) {
      return res.status(400).json({ message: "productId is required" });
    }
    const items = await wishlistService.addToWishlist(req.user.id, productId);
    res.status(200).json({ message: "Product added to wishlist", data: items });
  } catch (error) {
    const statusCode = error.message === "Product not found" ? 404 : 500;
    res.status(statusCode).json({ message: error.message });
  }
};

const removeWishlistItem = async (req, res) => {
  try {
    const items = await wishlistService.removeFromWishlist(req.user.id, req.params.productId);
    res.status(200).json({ message: "Product removed from wishlist", data: items });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const clearWishlist = async (req, res) => {
  try {
    await wishlistService.clearWishlist(req.user.id);
    res.status(200).json({ message: "Wishlist cleared successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  listWishlist,
  addWishlistItem,
  removeWishlistItem,
  clearWishlist,
};
