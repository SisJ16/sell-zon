const express = require("express");
const addressController = require("./address.controller");
const { requireAuth } = require("../../middlewares/auth.middleware");

const router = express.Router();

router.use(requireAuth);

router.get("/", addressController.listAddresses);
router.post("/", addressController.createAddress);
router.patch("/:id", addressController.updateAddress);
router.delete("/:id", addressController.deleteAddress);

module.exports = router;
