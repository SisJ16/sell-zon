const Product = require("./product.model");

const getPublicProducts = () => Product.find({ isActive: true }).sort({ createdAt: -1 });

const getProductById = (id) => Product.findById(id);

const getAllProductsForAdmin = () => Product.find().sort({ createdAt: -1 });

const createProduct = (payload) => Product.create(payload);

const updateProductById = (id, payload) =>
  Product.findByIdAndUpdate(id, payload, {
    new: true,
    runValidators: true,
  });

const deleteProductById = (id) => Product.findByIdAndDelete(id);

module.exports = {
  getPublicProducts,
  getProductById,
  getAllProductsForAdmin,
  createProduct,
  updateProductById,
  deleteProductById,
};
