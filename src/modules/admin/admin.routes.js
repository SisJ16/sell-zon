const express = require("express");
const adminController = require("./admin.controller");
const { requireAuth, requireRole } = require("../../middlewares/auth.middleware");

const router = express.Router();

router.use(requireAuth, requireRole("admin"));

router.get("/users", adminController.listUsers);
router.get("/users/:id", adminController.getUser);
router.patch("/users/:id/role", adminController.updateRole);
router.delete("/users/:id", adminController.deleteUser);

module.exports = router;
