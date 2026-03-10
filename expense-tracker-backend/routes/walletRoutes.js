const express = require("express")
const router = express.Router()

const authMiddleware = require("../middleware/authMiddleware")

const {
  getWallet,
  addCash,
  deductCash,
  setLimit
} = require("../controllers/walletController")

router.get("/", authMiddleware, getWallet)

router.post("/add", authMiddleware, addCash)

router.post("/deduct", authMiddleware, deductCash)

router.post("/set-limit", authMiddleware, setLimit)

module.exports = router