const express = require("express");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const { requireAuth, requireRole } = require("../../middlewares/auth.middleware");

const router = express.Router();
const productUploadDir = path.join(process.cwd(), "uploads", "products");
const bannerUploadDir = path.join(process.cwd(), "uploads", "banners");

[productUploadDir, bannerUploadDir].forEach((dir) => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
});

const makeUploader = (destinationDir) =>
  multer({
    storage: multer.diskStorage({
      destination: (_req, _file, cb) => {
        cb(null, destinationDir);
      },
      filename: (_req, file, cb) => {
        const ext = path.extname(file.originalname || "");
        const base = path.basename(file.originalname || "image", ext).replace(/\s+/g, "-");
        cb(null, `${Date.now()}-${base}${ext}`);
      },
    }),
  });

const productImageUpload = makeUploader(productUploadDir);
const bannerImageUpload = makeUploader(bannerUploadDir);

const uploadHandler = (folder) => (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: "Image file is required" });
  }

  const filePath = `/uploads/${folder}/${req.file.filename}`;
  const url = `${req.protocol}://${req.get("host")}${filePath}`;

  res.status(201).json({
    message: "Image uploaded successfully",
    data: { url, path: filePath },
  });
};

router.post(
  "/product-image",
  requireAuth,
  requireRole("admin"),
  productImageUpload.single("image"),
  uploadHandler("products")
);

router.post(
  "/banner-image",
  requireAuth,
  requireRole("admin"),
  bannerImageUpload.single("image"),
  uploadHandler("banners")
);

module.exports = router;
