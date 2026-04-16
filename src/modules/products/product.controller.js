const productService = require("./product.service");

const listProducts = async (req, res) => {
  try {
    const products = await productService.getPublicProducts();
    res.status(200).json({ message: "Products fetched successfully", data: products });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getProduct = async (req, res) => {
  try {
    const product = await productService.getProductById(req.params.id);
    if (!product || !product.isActive) {
      return res.status(404).json({ message: "Product not found" });
    }
    res.status(200).json({ message: "Product fetched successfully", data: product });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const listProductsForAdmin = async (req, res) => {
  try {
    const products = await productService.getAllProductsForAdmin();
    res.status(200).json({ message: "Products fetched successfully", data: products });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createProduct = async (req, res) => {
  try {
    const { name, price, stock, category, image, description, isActive } = req.body;
    if (!name || price === undefined || stock === undefined || !category || !image || !description) {
      return res.status(400).json({ message: "Missing required product fields" });
    }

    const product = await productService.createProduct({
      name,
      price,
      stock,
      category,
      image,
      description,
      isActive,
    });

    res.status(201).json({ message: "Product created successfully", data: product });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const updateProduct = async (req, res) => {
  try {
    const product = await productService.updateProductById(req.params.id, req.body);
    if (!product) {
      return res.status(404).json({ message: "Product not found" });
    }
    res.status(200).json({ message: "Product updated successfully", data: product });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const deleteProduct = async (req, res) => {
  try {
    const product = await productService.deleteProductById(req.params.id);
    if (!product) {
      return res.status(404).json({ message: "Product not found" });
    }
    res.status(200).json({ message: "Product deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  listProducts,
  getProduct,
  listProductsForAdmin,
  createProduct,
  updateProduct,
  deleteProduct,
};
