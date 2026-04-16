const Wishlist = require("./wishlist.model");
const Product = require("../products/product.model");

const getWishlistByUserId = (userId) =>
  Wishlist.find({ userId })
    .populate("productId")
    .sort({ createdAt: -1 });

const addToWishlist = async (userId, productId) => {
  const product = await Product.findById(productId);
  if (!product || !product.isActive) {
    throw new Error("Product not found");
  }

  await Wishlist.updateOne({ userId, productId }, { $setOnInsert: { userId, productId } }, { upsert: true });
  return getWishlistByUserId(userId);
};

const removeFromWishlist = async (userId, productId) => {
  await Wishlist.deleteOne({ userId, productId });
  return getWishlistByUserId(userId);
};

const clearWishlist = async (userId) => {
  await Wishlist.deleteMany({ userId });
};

module.exports = {
  getWishlistByUserId,
  addToWishlist,
  removeFromWishlist,
  clearWishlist,
};
