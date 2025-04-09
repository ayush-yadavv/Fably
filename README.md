# Fably - AI Virtual Try-On Application

![image](https://github.com/user-attachments/assets/83a96b4f-e64a-4ddf-a8f5-04972839020d)


Fably is an innovative Flutter-based fashion application that leverages AI image generation to revolutionize the way users visualize and choose clothing. Using FASHN AI Virtual Try-On API, the app creates personalized virtual models for accurate clothing visualization.

## 🎯 Core Features

- **Virtual Try-On**
  - Realistic clothing visualization using user-uploaded images
  - Accurate fit and style representation
  - Ability to Try-On a wide variety clothing, from individual clothing items like T-shirts, to Dresses and Suits.

- **Style Recommendations** (Upcoming features)
  - Personalized clothing suggestions based on body type
  - Color palette recommendations
  - Couple matching suggestions (upcoming feature)

## Prerequisites

Before running the application, ensure you have the following installed:

- Flutter SDK (version ^3.6.0)
- Dart SDK 
- Android Studio / Xcode (for iOS development)
- Camera-enabled device/emulator (min SDK 23 for Android)

## Environment Setup

### 1. Flutter Setup
```bash
# Install Flutter following official documentation
# https://flutter.dev/docs/get-started/install

# Verify installation
flutter doctor
```

## Project Setup

1. Clone and setup the repository:
```bash
# Clone repository
git clone [repository-url]
cd fably

# Install dependencies
flutter pub get
```

## Required Permissions

### Android
Add to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS
Add to `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for body scanning and measurements</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app requires access to photo library for saving your fashion choices</string>
```

## Project Structure
```
fably/
├── lib/                                 # Main source code directory
│   ├── screens/                         # UI screens and views
│   │   ├── auth/                        # Authentication related screens
│   │   │   ├── auth_widget.dart         # Reusable auth UI components
│   │   │   ├── login.dart               # Login screen implementation
│   │   │   └── register.dart            # Registration screen implementation
│   │   ├── home/                        # Main app screens
│   │   │   ├── home.dart                # Home screen implementation
│   │   |   └── widgets/
|   |   |       ├── bottom_nav_bar.dart  # Reusable nav bar widget
|   |   |       ├── common_appbar.dart   # Reusable App bar widget
|   |   |       └── common_drawer.dart   # Reusable drawer menu widget
│   │   ├── profile/
│   │   |   └── profile_page.dart        # User profile page
│   │   ├── scanner/
│   │   |   ├── add_images.dart          # Page to upload image for virtual try-on
│   │   |   ├── individual_try_on.dart   # Page to show individual result in 
|   |   |   |                              try-on history
│   │   |   ├── select_product.dart      # Page to select the product for try-on
│   │   |   ├── tryon_result.dart        # Page to view the try-on result
│   │   |   └── vton_history.dart        # Page to view Previous Try-Ons
│   │   └── shop/
│   │       ├── components/              # Small components reused in other pages
│   │       |   └── product_rating.dart  # Product rating widget in product page
│   │       ├── cart.dart                # Cart Page
│   │       ├── checkout_screen.dart     # Checkout Screen
│   │       ├── order_page.dart          # Order Page
│   │       ├── product.dart             # Individual Product Page
│   │       ├── review_page.dart         # Review Page
│   │       ├── shopping_history.dart    # Shopping History
│   │       ├── success_page.dart        # Purchase Success Page
│   │       └── wishlist.dart            # Wishlist Page
│   ├── utils/                           # Utility functions and helpers
│   │   ├── globals.darts                # Sets global variables for the app
│   │   ├── prefs.dart                   # Simplifies preferences
│   │   ├── requests.dart                # Simplifies HTTP requests management
│   │   └── user_preferences.dart        # User preferences management
│   └── main.dart                        # Application entry point
├── assets/                              # Static assets directory
│   └── Gif_fably.gif                    # Loading/intro animation
├── fonts/                               # Custom fonts
│   ├── Italiana-Regular.ttf             # Italiana font for headings
│   └── Jura-Regular.ttf                 # Jura font for body text
├── android/                             # Android platform code
│   └── app/
│       └── src/
│           └── main/
│               └── AndroidManifest.xml # Android configuration
├── ios/                                # iOS platform code
├── test/                               # Test files directory
├── pubspec.yaml                        # Project dependencies and config
└── README.md                           # Project documentation
```
<!--
## Features

### Core Functionality

- Style Assistant
  - Body-type based recommendations
  - Occasion-based outfit suggestions
  - Color coordination advice

### Technical Features
- Local data persistence
- Camera integration
-->
## Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  google_sign_in: ^5.2.1
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.2.2
  camera: ^0.10.5+9
  image_picker: ^1.0.7
  http: ^1.1.0
  liquid_pull_to_refresh: ^3.0.0
  flutter_slidable: ^4.0.0
```

## Troubleshooting

### Camera and Image Capture Issues
- Ensure all camera permissions are granted
- Verify adequate lighting conditions
- Check device compatibility (minimum SDK 23 for Android)
- Ensure sufficient device storage

## Development Guidelines

### Code Style
- Follow Flutter's official style guide
- Use meaningful variable and function names
- Comment complex AR and measurement algorithms
- Document API endpoints and models

### Performance Considerations
- Cache frequently used assets
- Implement lazy loading for clothing catalog
- Minimize network requests

## Future Updates
- Couple matching feature
- Social sharing capabilities
- Advanced style recommendations
- Wardrobe organization tools
- Shopping integration

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License


## Contact
Project Link: https://fably.pro

## Acknowledgments
- Flutter team for the framework
