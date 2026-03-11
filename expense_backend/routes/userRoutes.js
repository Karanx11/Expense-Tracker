const express = require("express");
const router = express.Router();

const {
  getProfile,
  deleteAccount
} = require("../controllers/userController");

const authMiddleware = require("../middleware/authMiddleware");

router.get("/profile", authMiddleware, getProfile);
router.delete("/delete", authMiddleware, deleteAccount);

module.exports = router;