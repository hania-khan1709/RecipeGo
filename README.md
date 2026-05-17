
# RecipeGO 🍽️

### The Ultimate Sustainable Kitchen Companion & Smart Meal Planner

RecipeGO is a beautifully designed full-stack Flutter application that transforms how users discover, organize, and plan meals.

Built with Flutter and Firebase, RecipeGO combines:
- Smart recipe discovery
- Weekly meal planning
- Grocery list generation
- Community recipe sharing
- Real-time cloud synchronization

with a calm, eco-inspired UI designed for a distraction-free cooking experience.

Instead of endless scrolling through cluttered recipes, RecipeGO focuses on intent-driven cooking:
> What can I cook right now?  
> How can I plan my meals efficiently?  
> What ingredients do I already have?

---

# ✨ Features

## 🔐 Authentication & Onboarding
- Firebase Email/Password Authentication
- Guest Mode for instant access
- Password recovery system
- Smooth onboarding experience

---

# 🍲 Recipe Discovery

- Modern recipe feed UI
- Browse recipes by:
  - Popularity
  - Rating
  - Cook time
  - Cuisine
  - Category
- Real-time Firestore synchronization

---

# 📖 Recipe Details

Each recipe includes:
- Step-by-step cooking instructions
- Structured ingredient lists
- Cooking duration
- User ratings & comments
- Related recipe suggestions

Users can:
- Save recipes to favorites
- Add recipes to meal planner
- Share recipes with the community

---

# 🧠 Smart Search System

Search recipes using:
- Ingredients
- Dietary preferences
- Calories
- Preparation time

Supports filters like:
- Vegan
- Keto
- Vegetarian
- High-protein

---

# 📅 Weekly Meal Planner

Interactive calendar-style planner featuring:
- Breakfast / Lunch / Dinner scheduling
- Drag-and-assign meal organization
- Smart meal suggestions
- Structured weekly planning

---

# 🛒 Grocery List Generator

Automatically generates grocery lists based on:
- Planned meals
- Recipe ingredients
- Weekly schedules

Helps users:
- Reduce food waste
- Shop efficiently
- Stay organized

---

# ❤️ Favorites & Collections

Users can:
- Save favorite recipes
- Organize personal collections
- Revisit previously planned meals

---

# 👨‍🍳 Creator Studio

RecipeGO allows users to:
- Create custom recipes
- Upload recipe images
- Add ingredients & cooking steps
- Publish recipes to the community

Images are stored securely using Firebase Storage.

---

# 👥 Community Features

- Recipe sharing
- Ratings & reviews
- Community-driven discovery
- Interactive feedback system

---

# 👤 User Profile

Each user has:
- Personal dashboard
- Saved recipes
- Created recipes
- Meal planning history
- Preferences & activity tracking

---

# 🛠 Tech Stack

## Frontend
- Flutter
- Dart
- Material Design UI

## Backend
- Firebase Authentication
- Cloud Firestore
- Firebase Storage

---

# 🏗 Architecture

RecipeGO follows a **feature-first modular architecture** focused on scalability and maintainability.

## Core Collections

| Collection | Purpose |
|------------|---------|
| users | User profiles & preferences |
| recipes | Global recipe database |
| mealPlans | Weekly meal schedules |
| comments | Ratings & feedback |

---

# 🔄 Application Flow

```text
App Launch
   ↓
Splash Screen
   ↓
Authentication Check
   ↓
Login / Sign Up / Guest
   ↓
Home Feed
   ↓
Recipe Details
   ↓
Save / Comment / Add to Planner
   ↓
Meal Planner & Grocery List
   ↓
User Profile
   ↓
Logout
```

---

# 📱 Screens Included

- Splash Screen
- Authentication Screens
- Home Feed
- Recipe Detail Screen
- Search & Filter Screen
- Meal Planner
- Grocery List Screen
- Favorites Screen
- User Profile
- Creator Studio

---

# ⚙️ Installation

## Prerequisites

- Flutter SDK
- Firebase Project
- Android Studio / VS Code

---

# ▶️ Run Locally

```bash
git clone https://github.com/yourusername/RecipeGO.git

cd RecipeGO

flutter pub get

flutter run
```

---

# 🔥 Firebase Setup

1. Create a Firebase project
2. Enable:
   - Authentication
   - Firestore Database
   - Firebase Storage
3. Add:
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)

---

# 🎯 Project Goals

RecipeGO was designed to:
- Simplify meal planning
- Reduce cooking stress
- Encourage organized eating habits
- Improve grocery management
- Promote sustainable cooking practices

---

# 🎓 Learning Outcomes

This project demonstrates:
- Firebase CRUD operations
- Real-time reactive UI
- NoSQL database design
- Cross-screen state management
- Scalable Flutter architecture
- User-centered mobile UI/UX design

---

# Future Improvements

Planned upgrades include:
- Offline mode & local caching
- AI-generated recipe suggestions
- Nutritional analysis APIs
- Social feed & chef following
- Barcode ingredient scanning
- Dark mode support
- Voice-assisted cooking

---

# Design Philosophy

RecipeGO embraces a calm “green-scene” design language focused on:
- Simplicity
- Sustainability
- Focused cooking experiences
- Minimal distractions
- Intuitive navigation

---

# 👨‍💻 Author

Developed as a Full-Stack Flutter & Firebase Mobile Application Project.

---
