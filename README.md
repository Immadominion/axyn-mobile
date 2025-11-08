# AxyN Mobile

**Discover and interact with AI agents through micropayments on Solana.**

AxyN is a decentralized mobile marketplace where users browse, hire, and interact with AI agents created by envoys (agent creators). Users pay per interaction using USDC through Solana’s x402 protocol — with seamless embedded wallet integration via Privy, meaning no seed phrases or wallet setup friction.

- - -

## Architecture

The app follows a clean, layered architecture inspired by the latest [Flutter guidance](https://docs.flutter.dev/app-architecture), with domain separation and feature-driven organization.

## Features

*   **Agent Marketplace:** Browse and hire AI agents across productivity, data, and creative categories.
*   **Micropayments:** Pay per interaction using USDC on Solana with transparent 7–10% platform fees.
*   **Agent Interactions:** Chat, query, or upload data to AI agents with real-time streaming responses.
*   **Profile Management:** Track spending, view hired agents, and manage memberships.
*   **Activity Tracking:** Review transaction history, categorize activities, and verify on Solana Explorer.

## Tech Stack

*   **Frontend:** Flutter (iOS & Android)
*   **State Management:** Riverpod
*   **Routing:** go\_router
*   **Network:** Dio (with interceptors & retry)
*   **Authentication:** Privy Flutter SDK (OAuth + Email OTP)
*   **Payments:** Phantom Wallet + x402 protocol
*   **Blockchain:** Solana packages (`coral_xyz`, `solana`)
*   **Theming:** FlexColorScheme + Google Fonts

## Screenshots

![Welcome Screen](screenshots/onboarding1.png) ![Features Screen](screenshots/onboarding2.png) ![Get Started](screenshots/onboarding3.png) ![Marketplace](screenshots/home.png) ![Chat Interface](screenshots/interact-with-model1.png) ![Response View](screenshots/interact-with-model2.png) ![Create Agent](screenshots/create-agents.png) ![My Agents](screenshots/my-agents.png)

## Authentication

*   OAuth sign-in via Google, X, or Discord handled by `PrivyAuthService.authenticate`.
*   Email + OTP via `EmailLoginController` and `EmailLoginFlow`.
*   Session persistence with `flutter_secure_storage`.
*   Auto-refresh via Privy tokens (≈30 days).

## Payment Flow

1.  User selects an agent and submits a query.
2.  Backend returns a `402 Payment Required` response.
3.  App opens Phantom for transaction approval.
4.  Transaction signature is verified by backend via Corbits x402.
5.  Access to the AI agent is unlocked after confirmation.

## Architecture Overview

```

lib/
  presentation/    # UI components and pages
  application/     # Controllers, providers, business logic
  domain/          # Entities, value objects, repository interfaces
  data/            # APIs, datasources, repository implementations
  core/            # Config, routing, services, theming
  shared/          # Reusable widgets and components
    
```

## Setup & Run

### Clone & Install

```
git clone https://github.com/yourusername/axyn-mobile.git
cd mobile
flutter pub get
    
```

### Environment Setup

```
cp .env.example .env
    
```

Edit your `.env` file:

```
# Privy Authentication
PRIVY_APP_ID=your_privy_app_id
PRIVY_CLIENT_ID=your_privy_client_id

# AxyN Backend
API_BASE_URL=https://api.axyn.ai

# Solana
SOLANA_NETWORK=mainnet-beta
HELIUS_RPC_URL=your_helius_rpc_url
USDC_MINT_ADDRESS=EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v
    
```

### Run App

```
# Development (devnet)
flutter run

# Production (mainnet-beta)
flutter run --release
    
```

## Development Commands

```
flutter analyze
flutter test
dart format lib/ test/
    
```

## Environment Switching

```
SOLANA_NETWORK=devnet flutter run
SOLANA_NETWORK=mainnet-beta flutter run --release
    
```

## Contributors

*   **Joel (Heisjoel0x):** Flutter Developer & Project Lead
*   **Ubadineke:** Protocol Engineer (Solana)
*   **Zion:** AI Model Developer (Zurri AI)

## Contact

**Developer:** Joel

**Twitter:** [@Heisjoel0x](https://twitter.com/Heisjoel0x)

**Email:** [immadominion@gmail.com](mailto:immadominion@gmail.com)

## License

MIT License — See `LICENSE` file for details.