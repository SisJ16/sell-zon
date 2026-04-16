const express = require("express");
const { userRoutes } = require("../modules/users");
const { authRoutes } = require("../modules/auth");
const { adminRoutes } = require("../modules/admin");
const { productRoutes, adminProductRoutes } = require("../modules/products");
const { uploadRoutes } = require("../modules/uploads");
const { bannerRoutes, adminBannerRoutes } = require("../modules/banners");
const { statsRoutes } = require("../modules/stats");
const { wishlistRoutes } = require("../modules/wishlist");
const { cartRoutes } = require("../modules/cart");
const { addressRoutes } = require("../modules/addresses");
const { paymentRoutes } = require("../modules/payments");
const { orderRoutes } = require("../modules/orders");

const router = express.Router();

router.use("/users", userRoutes);
router.use("/auth", authRoutes);
router.use("/products", productRoutes);
router.use("/admin/products", adminProductRoutes);
router.use("/banners", bannerRoutes);
router.use("/admin/banners", adminBannerRoutes);
router.use("/admin/stats", statsRoutes);
router.use("/wishlist", wishlistRoutes);
router.use("/cart", cartRoutes);
router.use("/addresses", addressRoutes);
router.use("/payments", paymentRoutes);
router.use("/orders", orderRoutes);
router.use("/admin", adminRoutes);
router.use("/uploads", uploadRoutes);

module.exports = router;
