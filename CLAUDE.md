# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pocket Lawyer is a legal assistant mobile application built with Flutter that provides AI-powered legal information with state-specific context. It features secure API key storage, biometric authentication, and integration with multiple legal data sources.

## Development Commands

### Setup and Installation
```bash
# Navigate to the Flutter app directory
cd android-app

# Install dependencies
flutter pub get

# Set up environment variables (required)
copy .env.example .env  # Windows
cp .env.example .env    # macOS/Linux
# Then edit .env with your API keys
```

### Running the Application
```bash
# Run in debug mode
flutter run

# Run with disabled biometric (for development/testing)
flutter run --dart-define=DISABLE_BIOMETRIC=true

# Run with API keys via command line (alternative to .env)
flutter run --dart-define=OPENAI_API_KEY=your-key --dart-define=LEGISCAN_API_KEY=your-key --dart-define=CONGRESS_GOV_API_KEY=your-key
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Building
```bash
# Build APK for Android
flutter build apk

# Build app bundle for Play Store
flutter build appbundle

# Build for iOS (requires macOS)
cd ios && pod install && cd ..
flutter build ios

# Build iOS without codesign (for CI/testing)
flutter build ios --debug --no-codesign
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/
```

## Architecture

### Clean Architecture Layers
- **Presentation Layer** (`lib/presentation/`): UI screens, widgets, and state providers
- **Domain Layer** (`lib/domain/`): Business logic and use cases
- **Data Layer** (`lib/data/`): Repository implementations and data sources
- **Infrastructure Layer** (`lib/infrastructure/`): External API clients and services
- **Core Layer** (`lib/core/`): Shared utilities, constants, themes, and services

### State Management
Uses Riverpod for reactive state management. Providers are defined in `lib/presentation/providers.dart`.

### API Integration Points
The app integrates with multiple APIs through dedicated clients in `lib/infrastructure/`:
- OpenAI API (`openai_api_client.dart`) - AI chat responses
- LegiScan API (`legiscan_api_client.dart`) - State legislation data
- Congress.gov API (`congress_api_client.dart`) - Federal legislation
- Pinecone API (`pinecone_api_client.dart`) - Vector search for RAG
- CourtListener API (`courtlistener_api_client.dart`) - Case law and court opinions data
- State Statute APIs (`state_statute_api_client.dart`) - State-specific laws

### Security Implementation
- **Biometric Authentication**: Implemented in `lib/core/biometric_service.dart`
- **Secure Storage**: Uses Flutter Secure Storage in `lib/data/secure_storage_repository.dart`
- **Encryption**: AES-256 encryption helper in `lib/core/encryption_helper.dart`
- **Encrypted Database**: Local encrypted storage in `lib/infrastructure/encrypted_local_db.dart`

## Configuration

### Environment Variables
API keys are configured via `.env` file or `--dart-define` build arguments. Required keys:
- `OPENAI_API_KEY` - OpenAI API access
- `LEGISCAN_API_KEY` - Legislative data access
- `CONGRESS_GOV_API_KEY` - Congress.gov API access

Optional keys for future features:
- `PINECONE_API_KEY` - Vector database for RAG
- `COURTLISTENER_API_KEY` - CourtListener API for case law and court opinions

### Build Configuration
- **Minimum Android SDK**: API 23 (Android 6.0)
- **Target SDK**: Latest Flutter SDK version
- **Application ID**: `com.example.android_app` (should be changed for production)
- **Flutter SDK**: ^3.9.2

## Key Files and Their Purpose

### Core Application Files
- `lib/main.dart` - App entry point and route configuration
- `lib/core/constants.dart` - API endpoints, storage keys, and app constants
- `lib/core/themes.dart` - Light/dark theme definitions

### Screen Files
- `lib/presentation/splash_screen.dart` - Initial screen with biometric auth
- `lib/presentation/home_screen.dart` - Main navigation hub
- `lib/presentation/chat_screen.dart` - AI chat interface
- `lib/presentation/prompts_screen.dart` - Legal prompt templates
- `lib/presentation/settings_screen.dart` - API key and preference management

### Repository Pattern
- `lib/data/api_client_repository.dart` - Abstract API client interface
- `lib/data/rag_repository.dart` - RAG (Retrieval-Augmented Generation) logic
- `lib/data/local_cache_repository.dart` - Local caching implementation
- `lib/data/secure_storage_repository.dart` - Secure credential storage

## Testing Strategy

Tests should cover:
1. **Widget Tests** - UI component behavior
2. **Unit Tests** - Business logic in use cases
3. **Integration Tests** - API client functionality
4. **Security Tests** - Encryption and secure storage

Test files are located in `test/` directory.

## Development Workflow

1. **Feature Development**: Create feature branches from `master`
2. **Testing**: Run tests locally before committing
3. **API Keys**: Never commit real API keys; use `.env` or build arguments
4. **Code Style**: Follow Flutter/Dart conventions enforced by `analysis_options.yaml`

## Troubleshooting

### Common Issues
- **Missing API Keys**: Check `.env` file or provide via `--dart-define`
- **Biometric Issues on Emulator**: Use `DISABLE_BIOMETRIC=true`
- **Build Failures**: Run `flutter clean` then `flutter pub get`
- **Android Build Issues**: Ensure Android SDK and build tools are updated

### Debug Commands
```bash
# Check Flutter environment
flutter doctor

# Clean build artifacts
flutter clean

# Update dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated
```

## RAG Pipeline Architecture

The app implements a Retrieval-Augmented Generation system:
1. User query → Vector embedding generation
2. Similarity search in Pinecone with state filter
3. Document retrieval from legal databases
4. Context assembly with citations
5. AI response generation with OpenAI
6. Citation validation and confidence scoring
7. Encrypted response storage

## Mobile-Specific Features

- **Offline Mode**: Local caching of frequently accessed legal information
- **Biometric Security**: Device-level authentication
- **Responsive UI**: Adaptive layouts for different screen sizes
- **Performance Optimization**: Lazy loading and background sync
- **Accessibility**: Screen reader support via `accessibility_service.dart`