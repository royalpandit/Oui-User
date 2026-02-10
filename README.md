# OUI – Flutter Multivendor User App

OUI is a **Flutter-based multivendor eCommerce user application** built with a scalable, feature-based architecture.  
This app is designed to work with a Laravel backend and supports authentication, product browsing, cart & checkout, payments, orders, profile management, and more.

---

## ✨ Features

- User Authentication (Login, Signup, Forgot Password, OTP)
- Product Browsing (Categories, Flash Deals, Search)
- Cart & Checkout Flow
- Multiple Payment Methods (Stripe, Razorpay, PayPal, COD, etc.)
- Order Management
- User Profile & Address Management
- Wishlist
- Notifications
- Multivendor Support
- Clean UI with reusable widgets

---

## 🧠 Architecture Overview

This project follows a **Feature-based Clean Architecture (Clean-inspired)** approach with **BLoC & Cubit** for state management.

### Key Principles:
- Feature-first folder structure
- Separation of concerns (UI, State, Data)
- Repository pattern
- Scalable & maintainable codebase

### Architecture Stack:
- **State Management:** BLoC & Cubit
- **Dependency Injection:** Centralized injector
- **API Handling:** Remote & Local Data Sources
- **Error Handling:** Failure & Exception layers

---

## 📁 Project Structure

```text
lib/
├── core/                 # Core utilities, error handling, data sources
├── modules/              # Feature-based modules (auth, cart, home, etc.)
│   ├── authentication/
│   ├── cart/
│   ├── category/
│   ├── home/
│   ├── product_details/
│   ├── profile/
│   ├── order/
│   └── setting/
├── utils/                # Constants, extensions, themes
├── widgets/              # Reusable UI components
├── state_injector.dart   # Dependency injection
└── main.dart             # App entry point



Getting Started
Prerequisites

Flutter SDK (latest stable)

Android Studio / VS Code

Dart SDK

Setup Steps
flutter clean
flutter pub get
flutter run



Android Configuration

Application ID: com.oui.app

Minimum SDK: 21

Target SDK: Latest stable

Gradle: Compatible with Flutter stable channel

🌐 Backend

This app is designed to work with a Laravel Multivendor eCommerce Backend.

Make sure to configure:

API base URLs

Payment keys

Firebase / notification settings (if enabled)


State Management

Cubit for simple UI states

BLoC for complex business flows

Separate state & event files for maintainability

📦 Dependencies

Some commonly used packages:

flutter_bloc

http

cached_network_image

flutter_stripe

shared_preferences

carousel_slider

(See pubspec.yaml for the full list)


Development Notes

Feature-based structure for easy scalability

Easy to add new modules

Suitable for large production apps

Clean & readable code