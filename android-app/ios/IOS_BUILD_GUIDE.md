# iOS Build & Testing Guide for Jeffrey

This guide covers building, running, and testing the Jeffrey iOS application.

## Prerequisites

### macOS Requirements
- **macOS 13.0 (Ventura)** or later
- **Xcode 15.0** or later (download from [App Store](https://apps.apple.com/us/app/xcode/id497799835))
- **Command Line Tools**: `xcode-select --install`

### Flutter Requirements
- **Flutter SDK 3.x** or later
- Verify installation: `flutter doctor -v`

### CocoaPods
```bash
# Install CocoaPods (if not already installed)
sudo gem install cocoapods

# Update CocoaPods repo
pod repo update
```

## Project Setup

### 1. Clone and Navigate
```bash
git clone https://github.com/avaloki108/pocket-lawyer.git
cd pocket-lawyer/android-app
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Install iOS Dependencies (CocoaPods)
```bash
cd ios
pod install
cd ..
```

### 4. Environment Configuration
Create your `.env` file with required API keys:
```bash
cp .env.example .env
# Edit .env with your API keys
```

Required keys:
- `OPENROUTER_API_KEY` or configure Ollama for local AI
- `LEGISCAN_API_KEY` - Legislative data
- `CONGRESS_GOV_API_KEY` - Federal legislation

### 5. Firebase Configuration (Optional but Recommended)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project → Project Settings → Your Apps → iOS
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

If Firebase is not configured, the app will still run but analytics and crash reporting will be disabled.

## Building the App

### Debug Build (Development)
```bash
# From android-app directory
flutter build ios --debug

# Build without code signing (for testing)
flutter build ios --debug --no-codesign
```

### Release Build
```bash
# Requires valid code signing configuration
flutter build ios --release

# Without code signing (for CI/testing)
flutter build ios --release --no-codesign
```

### Build for Simulator
```bash
flutter build ios --simulator
```

## Running on Devices

### iPhone Simulator
```bash
# List available simulators
xcrun simctl list devices

# Run on default simulator
flutter run

# Run on specific simulator
flutter run -d "iPhone 15 Pro"

# Disable biometric for simulator testing
flutter run --dart-define=DISABLE_BIOMETRIC=true
```

### Physical iPhone/iPad
1. Connect your device via USB
2. Trust the computer on your device
3. Configure code signing in Xcode:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select the Runner target
   - Go to Signing & Capabilities
   - Select your development team
4. Run the app:
```bash
flutter run -d <device-id>

# List connected devices
flutter devices
```

## Testing

### Run All Tests
```bash
flutter test
```

### Run with Coverage
```bash
flutter test --coverage
# Generate HTML report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### iOS-Specific Tests (XCTest)
```bash
# Run from Xcode or command line
cd ios
xcodebuild test -workspace Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Xcode Configuration

### Opening in Xcode
Always open the workspace file, not the project file:
```bash
open ios/Runner.xcworkspace
```

### Build Settings
| Setting | Recommended Value |
|---------|-------------------|
| iOS Deployment Target | 13.0 |
| Swift Language Version | 5.0 |
| Enable Bitcode | NO |

### Required Capabilities
The app uses these iOS capabilities (already configured in Info.plist):
- **Face ID / Touch ID** - Biometric authentication
- **Background Fetch** - For Firebase and notifications
- **Push Notifications** - Firebase Cloud Messaging

## Troubleshooting

### Common Issues

#### Pod Install Fails
```bash
cd ios
pod deintegrate
pod cache clean --all
pod install --repo-update
```

#### Signing Issues
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner → Signing & Capabilities
3. Ensure "Automatically manage signing" is checked
4. Select a valid Team

#### Module Not Found Errors
```bash
cd ios
pod deintegrate
cd ..
flutter clean
flutter pub get
cd ios
pod install
```

#### Biometric Not Working on Simulator
Use the `--dart-define` flag:
```bash
flutter run --dart-define=DISABLE_BIOMETRIC=true
```

Or in Xcode simulator: Features → Touch ID / Face ID → Enrolled

#### Firebase Initialization Failed
- Ensure `GoogleService-Info.plist` is in `ios/Runner/`
- Verify bundle ID matches Firebase configuration
- Current bundle ID: `com.example.androidApp` (should be changed to a production identifier like `com.yourcompany.jeffrey` before App Store submission)

### Clean Build
```bash
flutter clean
cd ios
pod deintegrate
rm -rf Pods
rm Podfile.lock
cd ..
flutter pub get
cd ios
pod install
```

## CI/CD with GitHub Actions

The repository includes an iOS build workflow at `.github/workflows/ios_build.yml`.

### Required GitHub Secrets
| Secret | Description |
|--------|-------------|
| `GOOGLE_SERVICE_INFO_PLIST` | Contents of GoogleService-Info.plist |
| `GEMINI_API_KEY` | Google AI API key |
| `OPENAI_API_KEY` | OpenAI API key |
| `OPENROUTER_API_KEY` | OpenRouter API key |
| `LEGISCAN_API_KEY` | LegiScan API key |
| `CONGRESS_GOV_API_KEY` | Congress.gov API key |
| `PINECONE_API_KEY` | Pinecone vector DB key |

### For App Store Deployment (Optional)
Additional secrets needed for release signing:
| Secret | Description |
|--------|-------------|
| `BUILD_CERTIFICATE_BASE64` | Base64 encoded .p12 certificate |
| `P12_PASSWORD` | Certificate password |
| `BUILD_PROVISION_PROFILE_BASE64` | Base64 encoded provisioning profile |
| `KEYCHAIN_PASSWORD` | Temporary keychain password |

## App Store Submission Checklist

- [ ] Update bundle ID from `com.example.androidApp` to production ID (e.g., `com.yourcompany.jeffrey`)
  - Update in `ios/Runner.xcodeproj/project.pbxproj`
  - Update in Firebase Console and regenerate `GoogleService-Info.plist`
  - Update in `lib/firebase_options.dart` (iosBundleId field)
- [ ] Configure App Store Connect with app metadata
- [ ] Generate App Icons (already in Assets.xcassets)
- [ ] Set version and build number in pubspec.yaml
- [ ] Configure code signing for distribution
- [ ] Create provisioning profile for App Store
- [ ] Test on multiple device sizes
- [ ] Test on minimum iOS version (13.0)
- [ ] Complete App Privacy questionnaire
- [ ] Prepare screenshots for all required device sizes

## Device Compatibility

| Device | Minimum iOS | Status |
|--------|-------------|--------|
| iPhone 8 and later | iOS 13.0 | ✅ Supported |
| iPhone SE (2nd gen+) | iOS 13.0 | ✅ Supported |
| iPad Air (3rd gen+) | iOS 13.0 | ✅ Supported |
| iPad Pro (all) | iOS 13.0 | ✅ Supported |
| iPad mini (5th gen+) | iOS 13.0 | ✅ Supported |

## Privacy and Security

### Data Collection
Review and update the privacy manifest as needed:
- The app uses Face ID/Touch ID for authentication
- Firebase Analytics collects anonymous usage data
- No personal legal data is sent to third parties

### Encryption Compliance
The app uses standard iOS encryption. The `ITSAppUsesNonExemptEncryption` key is set to `NO` in Info.plist, indicating the app only uses standard iOS encryption.

## Support

For issues specific to iOS builds:
1. Check [Flutter iOS deployment documentation](https://docs.flutter.dev/deployment/ios)
2. Review [CocoaPods troubleshooting](https://guides.cocoapods.org/using/troubleshooting.html)
3. Open an issue on the repository with:
   - Flutter doctor output
   - Xcode version
   - macOS version
   - Full error logs
