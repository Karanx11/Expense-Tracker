# 📊 Expense Tracker App

A smart full-stack expense tracking application built with Flutter + Node.js + MongoDB that helps users manage their spending, track transactions, analyze expenses, and stay within their monthly budget.

The app can automatically detect transactions from SMS, calculate remaining budget, and send smart notifications to control spending.

## 🚀 Features

## 💰 Expense Management

    Add expenses manually

    Auto detect expenses from bank SMS

    Categorize spending

    Track payment type (Cash / Online)

## 📊 Analytics

    Category-wise pie chart

    Monthly spending visualization

    Real-time analytics dashboard

## 🔔 Smart Notifications

    Alert when monthly budget is exceeded

    Notify remaining budget after each transaction

    Motivational saving reminders

## 📅 History Tracking

    Complete transaction history

    Grouped by month & year

    View date and time of each expense

    Delete expenses

## 🔐 Authentication System

    User signup/login

    JWT authentication

    OTP verification via email

    Forgot password support

## 📱 Real Time Updates

    Uses WebSocket (Socket.IO)

    Dashboard updates instantly when expense is added

## 📊 Budget Control

    Set monthly budget

    Track remaining budget

    Monthly reset system

## 🛠 Tech Stack

### Frontend

    Flutter

    Dart

    FL Chart (analytics graphs)

    Socket.IO client

    SMS reading plugin

    Local Notifications

### Backend

    Node.js

    Express.js

    MongoDB

    JWT Authentication

    Nodemailer (OTP system)

    Socket.IO (real time updates)

### Database

    MongoDB Atlas

## 📂 Project Structure

    expense_tracker/
    │
    ├── lib/
    │   ├── models/
    │   │     expense.dart
    │   │
    │   ├── screens/
    │   │     dashboard_screen.dart
    │   │     add_expense_screen.dart
    │   │     analytics_screen.dart
    │   │     history_screen.dart
    │   │     profile_screen.dart
    │   │
    │   ├── services/
    │   │     api_service.dart
    │   │     socket_service.dart
    │   │     sms_service.dart
    │   │     notification_service.dart
    │   │
    │   └── main.dart
    │
    └── backend/
        ├── controllers/
        │      authController.js
        │      expenseController.js
        │
        ├── models/
        │      User.js
        │      Expense.js
        │
        ├── routes/
        │      authRoutes.js
        │      expenseRoutes.js
        │
        └── server.js

## ⚙️ Installation

1️⃣ Clone Repository
git clone https://github.com/yourusername/expense-tracker.git

### 🖥 Backend Setup

Navigate to backend folder:

cd expense_backend

Install dependencies:

npm install

Create .env file:

    PORT=5000
    MONGO_URI=your_mongodb_connection
    JWT_SECRET=your_secret_key
    EMAIL_USER=your_email
    EMAIL_PASS=your_app_password

    Start server:

    node server.js

### 📱 Flutter Setup

    Navigate to Flutter project:

    cd expense_tracker

    Install packages:

    flutter pub get

    Run the app:

    flutter run

## 🌐 Deployment

    Backend deployed on:

     Render

    Database hosted on:

     MongoDB Atlas

    Update API base URL inside:

     api_service.dart


## 👨‍💻 Author

    Karan Sharma
    Full Stack Developer
    Flutter Developer | IoT Engineer

### GitHub:
 https://github.com/karanx11

## ⭐ Support

    If you like this project:

    ⭐ Star the repository
    📜 License

This project is licensed under the MIT License