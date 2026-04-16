const express = require("express");
const bannerController = require("./banner.controller");
const { requireAuth, requireRole } = require("../../middlewares/auth.middleware");

const router = express.Router();

router.use(requireAuth, requireRole("admin"));

router.get("/", bannerController.listBannersForAdmin);
router.post("/", bannerController.createBanner);
router.put("/:id", bannerController.updateBanner);
router.delete("/:id", bannerController.deleteBanner);

module.exports = router;
