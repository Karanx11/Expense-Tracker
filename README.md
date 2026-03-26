# 💰 Expense Tracker App

A modern, full-stack **Expense Tracker Application** built with Flutter, Node.js, and MongoDB.  
Track your expenses, manage budgets, and get smart insights in real-time.

---

## 🌐 Live Demo

🔗 Live Website: https://expense-tracker-website-9iy2.onrender.com/

---

## 🚀 Features

### 🔐 Authentication
- User Signup & Login
- JWT Authentication
- Secure Password Hashing
- Persistent Login (Secure Storage)

### 📊 Dashboard
- Total Expenses
- Current Balance
- Monthly Limit
- Remaining Budget
- Recent Transactions

### 💸 Expense Management
- Add Expense
- Delete Expense
- Category-based tracking
- Notes + Date support

### 📉 Smart Budgeting
- Set Monthly Limit
- Auto calculation of remaining budget
- Real-time updates

### 🤖 Smart Features
- 📩 SMS Expense Detection (UPI)
- 🧠 AI Category Detection (Food, Travel, Shopping, Bills)
- 🔔 Notifications after every transaction

### 📈 Analytics
- Category-wise breakdown
- Daily expense tracking
- Monthly insights

### 🎨 UI/UX
- Dark Theme (Premium Look)
- Smooth Animations
- Glassmorphism Design
- Clean typography (Poppins)

---

## 🛠️ Tech Stack

### 📱 Frontend
- Flutter
- Dart

### 🌐 Backend
- Node.js
- Express.js

### 🗄️ Database
- MongoDB Atlas

### 🔐 Auth & Storage
- JWT Authentication
- Flutter Secure Storage

---

## 📂 Project Structure


expense_tracker/
│
├── expense_frontend/ # Flutter App
├── expense_backend/ # Node.js API
│
├── models/
├── controllers/
├── routes/


---

## ⚙️ Installation & Setup

### 1️⃣ Clone Repo

```bash
git clone https://github.com/your-username/expense-tracker.git
cd expense-tracker
2️⃣ Backend Setup
cd expense_backend
npm install

Create .env:

MONGO_URI=your_mongodb_uri
JWT_SECRET=your_secret
PORT=5000

Run backend:

npm run dev
3️⃣ Frontend Setup
cd expense_frontend
flutter pub get
flutter run