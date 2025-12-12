FlashFocus – Micro-Learning Flashcards App

FlashFocus is a simple, modern micro-learning app built with Flutter and Firebase.
It helps users learn faster through short, focused review sessions using personalized flashcards, daily reminders, and a clean, customizable interface.

The goal of the project is to provide a distraction-free learning experience that works across devices and keeps progress synced in real time.

Features
Core Learning Experience

Create decks for any topic

Add flashcards with front/back text

Review cards using a smooth 3D flip animation

Swipe left/right to mark “Again” or “Got it”

Automatic tracking of:

lastReviewedAt

timesReviewed

Simple review stats:

Total cards

Cards reviewed today

User Accounts

Email/password authentication using Firebase Auth

Sessions persist across restarts

All data stored securely under each user’s Firestore path

Customizable UI

Choose from multiple background images

Pick a tile style:

Glassmorphism

Neumorphism

Gradient

Classic elevated card

Settings saved locally with shared_preferences

Notifications

Optional daily reminder to review flashcards

Uses local notifications (no internet required)

Tech Stack

Frontend:

Flutter (Material 3, animations, custom widgets)

Provider for lightweight state management

Backend:

Firebase Authentication

Cloud Firestore (real-time sync)

Firebase Storage (optional for future media cards)

Other:

Shared Preferences

flutter_local_notifications

Custom theming + reusable UI components

Project Structure

lib/
 ├─ models/            # Data models (Deck, CardItem, UI settings)
 ├─ services/          # Firebase & local storage services
 ├─ providers/         # App-wide UI settings provider
 ├─ screens/           # App pages (auth, home, deck detail, review, settings)
 ├─ widgets/           # Reusable UI components (decorated scaffold, tiles)
 └─ main.dart          # App entry, Firebase init, provider setup

How to Run

Clone the repository

Install Flutter (latest stable)

Run Firebase setup:

flutterfire configure
flutter pub get

Add your background images to /assets/images

Run the app:

flutter run

