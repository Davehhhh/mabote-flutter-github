# MaBote.ph Flutter Mobile App

This is the Flutter mobile application for the MaBote.ph smart recycling system - a Capstone 2 project focused on environmental sustainability through smart recycling technology.

## 📱 Features

- **User Registration & Login** - Secure authentication system
- **QR Code Scanning** - Scan QR codes at smart recycling bins
- **Real-time Wallet** - Track points and balance with 2-second updates
- **Transaction History** - View all bottle deposits and redemptions
- **Rewards System** - Claim rewards using earned points
- **Analytics Dashboard** - Environmental impact tracking
- **Leaderboard** - Community competition features
- **Notifications** - Real-time updates and alerts
- **Profile Management** - Update user information and settings
- **Machine Finder** - Locate nearby smart recycling bins

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/mabote-flutter-app.git
   cd mabote-flutter-app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint:**
   - Update the API base URL in your environment
   - Default: `http://192.168.254.128/mabote_api`
   - Replace with your server's IP address

4. **Run the app:**
   ```bash
   flutter run --dart-define=API_BASE_URL=http://YOUR_SERVER_IP/mabote_api
   ```

## 🔧 Configuration

### API Configuration
The app connects to the MaBote.ph API server. Update the API base URL:

```bash
# For local development
flutter run --dart-define=API_BASE_URL=http://localhost/mabote_api

# For network testing
flutter run --dart-define=API_BASE_URL=http://192.168.1.100/mabote_api
```

### Database Setup
The app requires the MaBote.ph database with the following tables:
- `users` - User accounts
- `wallet` - User balances
- `transactions` - Bottle deposits
- `redemption` - Reward claims
- `machines` - Smart bin locations
- `notifications` - User notifications
- And more...

## 📱 App Structure

```
lib/
├── main.dart                 # App entry point
├── screens/                  # UI screens
│   ├── login_screen.dart     # Authentication
│   ├── home_screen.dart      # Main dashboard
│   ├── wallet_screen.dart    # Points & balance
│   ├── transactions_screen.dart # Transaction history
│   ├── rewards_screen.dart   # Rewards system
│   ├── analytics_screen.dart # Environmental impact
│   └── ...
├── services/                 # Business logic
│   ├── auth_service.dart     # Authentication
│   ├── notification_service.dart # Notifications
│   └── ...
└── widgets/                  # Reusable components
    ├── modern_loading.dart   # Loading animations
    └── ...
```

## 🔄 Real-time Features

The app includes real-time updates:
- **2-second polling** for wallet balance
- **2-second polling** for notifications
- **Pull-to-refresh** on all screens
- **Live transaction updates**

## 🎨 UI/UX Features

- **Modern Material Design** - Clean, intuitive interface
- **Dark/Light Theme** - User preference support
- **Responsive Design** - Works on all screen sizes
- **Smooth Animations** - Premium loading effects
- **Accessibility** - Screen reader support

## 📊 Analytics & Reporting

- **Environmental Impact** - CO₂ saved, plastic recycled
- **Personal Statistics** - Bottles deposited, points earned
- **Achievement System** - Eco Warrior, Planet Saver badges
- **Community Leaderboard** - Top recyclers

## 🔐 Security Features

- **Secure Authentication** - Password hashing
- **Session Management** - Automatic token refresh
- **Data Validation** - Input sanitization
- **HTTPS Support** - Encrypted communication

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

## 📦 Dependencies

Key packages used:
- `http` - API communication
- `shared_preferences` - Local storage
- `fluttertoast` - Toast notifications
- `image_picker` - Profile image upload
- `url_launcher` - External links

## 🚀 Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS (requires macOS)
```bash
flutter build ios --release
```

## 🔗 Related Projects

- **Admin Panels**: [mabote-admin-panels](https://github.com/YOUR_USERNAME/mabote-admin-panels)
- **API Server**: [mabote-api](https://github.com/YOUR_USERNAME/mabote-api)
- **Smart Bin Hardware**: ESP32 Arduino code included

## 📞 Support

For issues or questions:
- Create an issue in this repository
- Contact the development team
- Check the documentation in related repositories

## 📄 License

This project is part of the MaBote.ph Capstone 2 project for environmental sustainability.

## 🌱 Environmental Impact

MaBote.ph promotes:
- **Waste Reduction** - Smart recycling incentives
- **Community Engagement** - Gamified recycling
- **Data-Driven Insights** - Environmental impact tracking
- **Sustainable Technology** - IoT-powered solutions

---

**MaBote.ph** - Smart Recycling System for Environmental Sustainability