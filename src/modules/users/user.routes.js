const express = require("express");
const userController = require("./user.controller");

const router = express.Router();

router.get("/test", (req, res) => {
  res.send("users route ok");
});

router.get("/", userController.getUsers);
router.get("/:id", userController.getUser);
router.put("/:id", userController.updateUser);
router.delete("/:id", userController.deleteUser);

module.exports = router;