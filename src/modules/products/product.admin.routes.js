const express = require("express");
const productController = require("./product.controller");
const { requireAuth, requireRole } = require("../../middlewares/auth.middleware");

const router = express.Router();

router.use(requireAuth, requireRole("admin"));

router.get("/", productController.listProductsForAdmin);
router.post("/", productController.createProduct);
router.put("/:id", productController.updateProduct);
router.delete("/:id", productController.deleteProduct);

module.exports = router;
