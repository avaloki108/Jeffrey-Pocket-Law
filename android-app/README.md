# Jeffrey (Flutter)

A cross-platform Flutter application providing a legal assistant interface with secure storage, biometric authentication (Face ID/Touch ID on iOS, biometric auth on Android), and integration points for legislative and AI APIs.

## Supported Platforms
- **Android** - API 23+ (Android 6.0+)
- **iOS** - iOS 13.0+ (see [ios/IOS_BUILD_GUIDE.md](ios/IOS_BUILD_GUIDE.md) for detailed setup)

## Features (Current State)
- Splash screen with (optional) biometric authentication
- Home navigation to Chat, Prompts, Settings (placeholders for expansion)
- Riverpod for state management
- Secure storage abstraction
- Pluggable API client repository with AI (OpenRouter primary, Ollama local fallback)
- .env + `--dart-define` hybrid configuration for secrets

## Environment Configuration
Secrets are NOT committed. You configure API keys via either:
1. A local `.env` file (development convenience)
2. `--dart-define` at build/run time (recommended for CI / production)

### 1. Create your local `.env`
Copy the example file and fill in values:
```
cd android-app
copy .env.example .env  (Windows)
# OR
cp .env.example .env    (macOS/Linux)
```
Edit `.env` (minimal example):
```
LEGISCAN_API_KEY=your-legiscan-key
CONGRESS_GOV_API_KEY=your-congress-key
OPENROUTER_API_KEY=your-openrouter-key   # Leave blank to force local Ollama
OPENROUTER_MODEL=openai/gpt-4o-mini      # Optional override
OLLAMA_HOST=http://127.0.0.1:11434       # Local default
OLLAMA_MODEL=gpt-oss:latest              # Model you pulled via Ollama
DISABLE_BIOMETRIC=false
```
If `OPENROUTER_API_KEY` is blank, the app automatically falls back to calling your local Ollama server using `OLLAMA_MODEL`.

`DISABLE_BIOMETRIC=true` can be set for simulators/emulators or automated tests.

### 2. Using `--dart-define`
You can override (or replace) `.env` values at runtime:
```
flutter run ^
  --dart-define=LEGISCAN_API_KEY=your-legiscan-key ^
  --dart-define=CONGRESS_GOV_API_KEY=your-congress-key ^
  --dart-define=OPENROUTER_API_KEY=sk-or-key
```
Precedence: dart-define > .env file > empty.

### AI Model Resolution Logic
1. If `OPENROUTER_API_KEY` is set: uses OpenRouter Chat Completions with `OPENROUTER_MODEL` (default internal fallback if blank).
2. Else: attempts local Ollama at `OLLAMA_HOST` using `OLLAMA_MODEL` (default `gpt-oss:latest`).
3. Errors bubble up with a friendly fallback message if both fail.

### Setting Up Local Ollama (Windows)
1. Install Ollama (https://ollama.com/) and launch: `ollama serve`
2. Pull model: `ollama pull gpt-oss:latest` (or whichever you want, e.g. `llama3`)
3. Confirm running: `ollama list`
4. Leave `OPENROUTER_API_KEY` blank in `.env` to force local usage.

### Security Notes
- Never commit a real `.env` (already ignored in root `.gitignore`).
- Treat anything inside a distributed mobile binary as recoverable by users; do not ship production secrets inside `.env` for release builds—prefer server-side proxying or ephemeral tokens.
- Consider routing OpenRouter/OpenAI access through your own backend to apply policy controls, logging, and rate limiting.

## Running the App (Windows cmd.exe)
From repository root:
```
cd android-app
flutter pub get
flutter run
```
Force local Ollama (ensure OPENROUTER_API_KEY is blank in `.env`):
```
flutter run --dart-define=DISABLE_BIOMETRIC=true
```
Explicitly test OpenRouter (overrides blank in `.env`):
```
flutter run ^
  --dart-define=OPENROUTER_API_KEY=sk-or-key ^
  --dart-define=DISABLE_BIOMETRIC=true
```

## Running the App (macOS / iOS)
From repository root:
```bash
cd android-app
flutter pub get

# Install iOS dependencies
cd ios && pod install && cd ..

# Run on iOS simulator
flutter run

# Run with biometric disabled (for simulator testing)
flutter run --dart-define=DISABLE_BIOMETRIC=true
```
For detailed iOS build and deployment instructions, see [ios/IOS_BUILD_GUIDE.md](ios/IOS_BUILD_GUIDE.md).

## Running Tests
```
cd android-app
flutter test
```
The provided widget test:
- Loads a test env (disables biometric, supplies dummy keys)
- Pumps the app and asserts Splash -> Home navigation

## Adding New API Integrations
1. Add any new keys to `.env.example` and constants resolution if needed.
2. Access keys via `AppConstants.someApiKey` (auto-resolves dart-define or .env).
3. Avoid hardcoding secrets directly in source.

## Troubleshooting
| Issue | Resolution |
|-------|------------|
| Missing API key warning | Add to `.env` or pass via `--dart-define` |
| Local Ollama not responding | Ensure `ollama serve` is running and `OLLAMA_HOST` matches |
| Model not found (Ollama) | Run `ollama pull <model>` |
| Biometric dialog blocks tests | Set `DISABLE_BIOMETRIC=true` |
| Keys not updating after change | `flutter clean` then restart, or ensure not overridden by dart-define |
| AI summary missing | Check network (OpenRouter) or local model availability (Ollama) |
| iOS pod install fails | `cd ios && pod deintegrate && pod install --repo-update` |
| iOS signing issues | Open `ios/Runner.xcworkspace` in Xcode and configure signing |
| iOS module not found | `flutter clean && cd ios && pod install && cd .. && flutter pub get` |

## Future Enhancements (Suggested)
- Implement vector search (Pinecone) to augment prompts (RAG)
- Case law integration (CourtListener / Harvard CAP) with proper citation extraction
- Caching & offline persistence (Hive)
- Structured logging + error reporting
- Backend mediator service for policy enforcement
- Streaming token UI updates for chat

## License
(Define your license here – currently unspecified.)
