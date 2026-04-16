const express = require("express");
const wishlistController = require("./wishlist.controller");
const { requireAuth } = require("../../middlewares/auth.middleware");

const router = express.Router();

router.use(requireAuth);

router.get("/", wishlistController.listWishlist);
router.post("/", wishlistController.addWishlistItem);
router.delete("/:productId", wishlistController.removeWishlistItem);
router.delete("/", wishlistController.clearWishlist);

module.exports = router;
