# PillTime 💊

A comprehensive medication reminder app built with Flutter, designed specifically for people with chronic illnesses to help them manage their medications effectively and never miss a dose.


# ✨ Key Features

- 🛡️ User registration and login
- 📅 Add and view medication schedules
- ⏰ Smart reminders
- 🔐 Forgot password and authentication recovery
- 🎉 Onboarding screen for first-time users
- 📈 Track medication history

# User Experience
- **Clean, Accessible UI** - Designed with chronic illness patients in mind
- **Color-coded Medications** - Easy visual identification of different medications
- **Offline Support** - Works without internet connection using local storage
- **Cross-platform** - Available for both iOS and Android

# Folder Structure & Tech Stack

lib/
├── models/                 # Data models (e.g., medication, user)
├── screens/                # All UI screens
│   ├── onboarding_screen.dart
│   ├── login_screen.dart
│   └── ...
├── services/              # Logic and APIs (auth, notifications)
│   ├── auth_service.dart
│   ├── medication_service.dart
│   └── notification_service.dart
└── main.dart              # App entry point

🧰 Tech Stack
Flutter – Cross-platform UI toolkit

Dart – Programming language

Flutter Local Notifications – For reminders

VS Code – Main IDE used


# Prerequisites
Make sure you have the following installed:

Flutter SDK

Dart SDK (included with Flutter)

Android Studio or VS Code with Flutter & Dart extensions

Git

### Installation

1. **Clone the repository**
   git clone https://github.com/Vicks-aj/PIllTime.git
cd PIllTime


2. **Install dependencies**
   flutter pub get


3. **Run the app**
  flutter run

# Features
The PillTime app helps users manage and track their medication schedules. Below are the main features:

👤 Authentication
User sign-up and login

Forgot password/reset functionality

💊 Medication Management
Add a new medication with name, time, and dosage

View a list of scheduled medications

View detailed medication information

🛎️ Notifications
Timely reminders to take medications (Notification service integrated)

📱 Onboarding Screens
Introductory screens to guide first-time users through the app's purpose and usage

# 🌐 Live Demo
You can view the live project hosted on Netlify here:
👉 https://pilltimee.netlify.app/


