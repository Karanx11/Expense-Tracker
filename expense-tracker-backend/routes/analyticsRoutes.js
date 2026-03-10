const express = require("express")
const router = express.Router()

const authMiddleware = require("../middleware/authMiddleware")

const {
  monthlyExpenses,
  categoryExpenses,
  weeklyExpenses
} = require("../controllers/analyticsController")


router.get("/monthly", authMiddleware, monthlyExpenses)

router.get("/category", authMiddleware, categoryExpenses)

router.get("/weekly", authMiddleware, weeklyExpenses)

module.exports = router