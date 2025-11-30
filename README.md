# 🏛️ Jeffrey

_AI-powered legal research & assistance._

![Platform](https://img.shields.io/badge/platform-Android%20%7C%20Web-blueviolet)
![Flutter](https://img.shields.io/badge/flutter-3.x-blue)
![React](https://img.shields.io/badge/react-18.x-61dafb)
![License](https://img.shields.io/badge/license-MIT-green)

</div>

## Overview

Jeffrey is a cross‑platform legal AI assistant designed to accelerate statutory, case law, and legislative research while preserving user privacy. It integrates multiple model providers, structured legal data sources, and vector search for intelligent retrieval.

## Naming

Jeffrey is the current product name. The project was previously branded as **Pocket Lawyer** and the repository name may still reference the legacy identity for continuity. Historical folders (e.g. `previous/`) or identifiers may retain the old name until touched by related changes.

### Why the rebrand

- Distinct, humanized assistant persona
- Clear differentiation from generic legal tooling
- Extensible for multi-domain features beyond strictly “pocket” use cases

### Migration guidance

1. Keep repository slug until downstream integrations (CI, store listings) are updated.
2. Prefer “Jeffrey” in UI, docs, marketing copy.
3. Refactor internal identifiers only when modifying related code (avoid churn PRs).
4. Secret names and environment keys remain stable unless clarity requires renaming.

## Key Features

- 🔍 Multi-provider AI (Gemini, OpenAI, Groq, DeepSeek, OpenRouter, local Ollama)
- 📚 Legal data integrations (CourtListener, LegiScan, Congress.gov)
- 🧠 Vector search (Pinecone + optional local Qdrant storage)
- 📱 Flutter Android application (primary mobile client)
- 🌐 Vite + React web interface (in `src/`)
- 🔐 Secure local storage (Hive + `flutter_secure_storage`)
- 🕒 Notifications & scheduling foundation (local notifications + timezone)
- ⚙️ Typed domain layers (`core`, `data`, `domain`, `presentation`)
- 🚀 CI/CD Android build workflow (GitHub Actions)

## Architecture

```text
android-app/          # Flutter project (main application)
  lib/                # Application code organized by layers
src/                  # Web (Vite + React) client
dataconnect/          # DataConnect schema & seed examples
lib/dataconnect/      # Shared service integrations
play-store-ready/     # Release artifacts & guides
previous/             # Legacy / historical assets and data snapshots
```

Core concepts:

1. Separation of concerns: domain vs presentation vs infrastructure.
2. Environment-driven configuration via `.env` (never committed).
3. External AI and legal APIs abstracted behind service interfaces.
4. Optional hybrid vector search (remote Pinecone + local Qdrant).

## Tech Stack

- Flutter (Dart) for Android (and potential desktop targets)
- React + TypeScript (Vite) for web
- Pinecone / Qdrant for embeddings storage
- Hive + Secure Storage for encrypted user/app state
- Multiple AI inference providers (API-key gated)

## Getting Started

### Prerequisites

- Flutter SDK (`flutter --version` ≥ 3.x)
- Java 17 (for Android builds)
- Android SDK / Emulator
- Node.js 20+ (for web client)
- pnpm or npm/yarn (front-end dependencies)

### Clone

```bash
git clone https://github.com/avaloki108/pocket-lawyer.git
cd pocket-lawyer
```

### Install (Mobile)

```bash
cd android-app
flutter pub get
```

### Install (Web)

```bash
pnpm install   # or npm install
pnpm dev       # starts Vite dev server
```

## Environment Configuration

Environment secrets are NOT committed. Create your own `.env` locally (and in GitHub Actions via repo secrets). Suggested sample:

```bash
# AI Providers
GEMINI_API_KEY=your_key
OPENAI_API_KEY=your_key
GROQ_API_KEY=your_key
DEEPSEEK_API_KEY=your_key
OPENROUTER_API_KEY=your_key
OPENROUTER_MODEL=openai/gpt-4o-mini
OLLAMA_HOST=http://127.0.0.1:11434
OLLAMA_MODEL=gpt-oss:20b

# Legal Data APIs
COURTLISTENER_API_KEY=your_key
LEGISCAN_API_KEY=your_key
CONGRESS_GOV_API_KEY=your_key
PINECONE_API_KEY=your_key

# Optional future keys
FIREBASE_API_KEY=your_key
REVENUECAT_API_KEY=your_key
MIXPANEL_TOKEN=your_key
```

### GitHub Actions Secrets

Add corresponding secrets under: Settings → Secrets and variables → Actions

- `GOOGLE_SERVICES_JSON` (raw firebase json for Android)
- All API keys listed above

## Running the App

```bash
# Mobile (debug)
cd android-app
flutter run

# Build APK (debug)
flutter build apk --debug

# Web
pnpm dev
```

## CI/CD

Android build & artifact publishing handled by `.github/workflows/android_build.yml`:

- Installs Java + Flutter
- Injects secrets (`.env`, `google-services.json`)
- Builds debug APK
- Uploads artifact for download

Optional Qodana static analysis workflow present; enable by adding `QODANA_TOKEN` and uncommenting triggers if disabled.

## Security & Secrets

- `.gitignore` excludes keystores, API keys, local properties.
- Treat `.env` values as confidential; rotate compromised keys immediately.
- Avoid echoing secret contents in CI logs.

## Data & Storage

- Hive used for local persistence; secure layers wrap sensitive records.
- Vector DB: Pinecone primary; local Qdrant folders are ignored for safety.
- Historic data snapshots retained under `previous/` for reference.

## Contributing

1. Fork & branch: `feat/your-feature`
2. Keep changes focused, add tests (if applicable)
3. Run linters / formatters
4. Open PR with clear description & rationale

## Roadmap (High-Level)

- ✅ Multi-provider AI integration
- 🔄 Enhanced retrieval augmentation (expanding legal corpus)
- 🛡️ End-to-end encryption for sensitive queries
- 📱 iOS & desktop build stabilization
- 🧪 Automated test suite expansion
- 📊 Usage analytics (privacy-preserving)

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Missing Android SDK | Set `sdk.dir` in `local.properties` |
| Build fails (google-services) | Ensure `GOOGLE_SERVICES_JSON` secret exists |
| API auth errors | Confirm secret names & no stray quotes |
| Slow model responses | Try alternate provider or local Ollama |

## License

MIT © Jeffrey Contributors. See `LICENSE`.

---
_This README replaces the initial template and removes all GitHub Spark template references. Primary product name: Jeffrey (formerly Pocket Lawyer)._ 
