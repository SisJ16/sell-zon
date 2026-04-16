const express = require("express");
const bannerController = require("./banner.controller");

const router = express.Router();

router.get("/", bannerController.listBanners);

module.exports = router;
