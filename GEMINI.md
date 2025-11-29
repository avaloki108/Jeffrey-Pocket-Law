# Pocket Lawyer Project Context

## Project Overview

Pocket Lawyer is a comprehensive legal assistant application designed to provide state-specific legal information using AI and RAG (Retrieval-Augmented Generation). The project is currently transitioning from a web-based prototype to a production-ready **Flutter Android application**.

### Key Capabilities
*   **AI-Powered Legal Chat**: Uses models like GPT-4o-mini to answer user queries.
*   **RAG Pipeline**: Retrieves relevant legal documents (statutes, case law) to ground AI responses.
*   **State-Specific Context**: Filters legal data by US state (e.g., "California laws on tenant rights").
*   **Security**: Features AES-256 encryption, biometric authentication (fingerprint/face), and secure storage for API keys.
*   **Hybrid Architecture**: Combines a Flutter mobile frontend with Python-based data processing and query logic.

## Tech Stack

*   **Mobile Framework**: Flutter (Dart)
*   **State Management**: Riverpod
*   **Architecture**: MVVM with Clean Architecture (Presentation, Domain, Data, Infrastructure)
*   **Backend/Scripts**: Python (for RAG logic and data processing)
*   **APIs**:
    *   **AI**: OpenAI (or OpenRouter/Ollama)
    *   **Legal Data**: LegiScan, Congress.gov, CourtListener, Harvard CAP
    *   **Vector DB**: Pinecone (for similarity search)
*   **Local Storage**: Hive (encrypted), Flutter Secure Storage

## Directory Structure

### `android-app/` (Main Flutter Application)
The core mobile application resides here.

*   `lib/presentation/`: UI Screens (Chat, Settings, Prompts) and Riverpod providers.
*   `lib/domain/`: Business logic and use case definitions.
*   `lib/data/`: Repositories handling data flow.
*   `lib/infrastructure/`: External API clients (`openai_api_client.dart`, `legiscan_api_client.dart`, etc.).
*   `lib/core/`: Shared utilities (`biometric_service.dart`, `encryption_helper.dart`).
*   `test/`: Unit and widget tests.

### Root Directory (Backend/Data Scripts)
*   `pocket-lawyer-query.py`: Core logic for generating legal responses using RAG.
*   `data_inf.py`: Data inference or processing script.
*   `pocket-lawyer.html`: Legacy/Prototype web interface.
*   `android-app-architecture.md`: Detailed architectural documentation.

## Setup & Development

### 1. Environment Configuration
**Crucial**: The app relies on sensitive API keys. Do **NOT** commit them.

1.  Navigate to `android-app/`.
2.  Copy the example environment file:
    ```bash
    cp .env.example .env
    ```
3.  Fill in your keys in `.env`:
    *   `OPENROUTER_API_KEY` / `OPENAI_API_KEY`
    *   `LEGISCAN_API_KEY`
    *   `CONGRESS_GOV_API_KEY`
    *   `DISABLE_BIOMETRIC=true` (Optional: for emulators/testing)

### 2. Running the App
**Standard Debug Build:**
```bash
cd android-app
flutter pub get
flutter run
```

**With Runtime Overrides (Recommended for CI/Testing):**
```bash
flutter run --dart-define=DISABLE_BIOMETRIC=true --dart-define=OPENROUTER_API_KEY=your_key
```

### 3. Testing
```bash
cd android-app
flutter test
```

## Architecture & Conventions

*   **Clean Architecture**: Strictly separate concerns. UI (`presentation`) should talk to Use Cases (`domain`), which talk to Repositories (`data`), which use Data Sources (`infrastructure`).
*   **State Management**: Use Riverpod providers for dependency injection and state management. Avoid `setState` for complex logic.
*   **Security First**:
    *   Never log full API responses containing user data.
    *   Use `SecureStorage` for any sensitive tokens.
    *   Biometric auth is required for app entry (unless disabled via flag).
*   **Styling**: Follow Material Design 3 guidelines.

## Roadmap & Status

*   **Current Focus**: Migrating web features to the Android app.
*   **Implemented**: Basic chat UI, Settings, API integration framework, Biometric auth.
*   **TODO**:
    *   Full implementation of RAG pipeline within the mobile app (or connection to backend).
    *   Offline caching of legal statutes.
    *   Advanced prompt template library.
