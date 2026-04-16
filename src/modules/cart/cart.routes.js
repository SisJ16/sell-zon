const express = require("express");
const cartController = require("./cart.controller");
const { requireAuth } = require("../../middlewares/auth.middleware");

const router = express.Router();

router.use(requireAuth);

router.get("/", cartController.getCart);
router.post("/items", cartController.addItem);
router.patch("/items/:productId", cartController.updateItemQuantity);
router.delete("/items/:productId", cartController.removeItem);
router.delete("/clear", cartController.clearCart);

module.exports = router;
