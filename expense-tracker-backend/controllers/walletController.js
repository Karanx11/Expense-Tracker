const Wallet = require("../models/Wallet")

// Get wallet balance
exports.getWallet = async (req, res) => {

  try {

    let wallet = await Wallet.findOne({ user: req.user.id })

    if (!wallet) {
      wallet = await Wallet.create({ user: req.user.id })
    }

    res.json(wallet)

  } catch (error) {

    res.status(500).json({ error: error.message })

  }

}


// Add money
exports.addCash = async (req, res) => {

  try {

    const { amount } = req.body

    let wallet = await Wallet.findOne({ user: req.user.id })

    if (!wallet) {
      wallet = await Wallet.create({ user: req.user.id, balance: amount })
    } else {
      wallet.balance += amount
      await wallet.save()
    }

    res.json(wallet)

  } catch (error) {

    res.status(500).json({ error: error.message })

  }

}


// Deduct money
exports.deductCash = async (req, res) => {

  try {

    const { amount } = req.body

    const wallet = await Wallet.findOne({ user: req.user.id })

    if (!wallet) {
      return res.status(404).json({ message: "Wallet not found" })
    }

    wallet.balance -= amount

    if (wallet.balance < 0) wallet.balance = 0

    await wallet.save()

    res.json(wallet)

  } catch (error) {

    res.status(500).json({ error: error.message })

  }
  
}
//set limit

exports.setLimit = async (req, res) => {

  try {

    const { limit } = req.body

    const wallet = await Wallet.findOne({ user: req.user.id })

    wallet.monthlyLimit = limit

    await wallet.save()

    res.json({
      message: "Limit updated",
      wallet
    })

  } catch (error) {

    res.status(500).json({ error: error.message })

  }

}