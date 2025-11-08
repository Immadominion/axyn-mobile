<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>AxyN Mobile</title>
  <style>
    body {
      font-family: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
      color: #e0e0e0;
      background-color: #0e0e0e;
      line-height: 1.7;
      margin: 0;
      padding: 40px;
    }
    h1, h2, h3, h4 {
      color: #ffffff;
    }
    h1 {
      font-size: 2.2em;
      margin-top: 0;
    }
    code, pre {
      background-color: #1a1a1a;
      color: #00e0a4;
      padding: 6px 10px;
      border-radius: 6px;
      font-size: 0.9em;
      font-family: monospace;
    }
    pre {
      overflow-x: auto;
      padding: 15px;
    }
    a {
      color: #00bfff;
      text-decoration: none;
    }
    a:hover {
      text-decoration: underline;
    }
    ul, ol {
      padding-left: 20px;
    }
    section {
      margin-bottom: 50px;
    }
    img {
      border-radius: 12px;
      margin: 10px;
      box-shadow: 0 2px 10px rgba(255, 255, 255, 0.05);
    }
    .screenshot-row {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: 10px;
    }
    .screenshot-row img {
      width: 240px;
    }
    hr {
      border: 0;
      border-top: 1px solid #333;
      margin: 40px 0;
    }
  </style>
</head>
<body>

  <h1>AxyN Mobile</h1>

  <p><strong>Discover and interact with AI agents through micropayments on Solana.</strong></p>

  <p>
    AxyN is a decentralized mobile marketplace where users browse, hire, and interact with AI agents created by envoys (agent creators). 
    Users pay per interaction using USDC through Solana’s x402 protocol — with seamless embedded wallet integration via Privy, 
    meaning no seed phrases or wallet setup friction.
  </p>

  <hr />

  <section>
    <h2>Architecture</h2>
    <p>
      The app follows a clean, layered architecture inspired by the latest 
      <a href="https://docs.flutter.dev/app-architecture">Flutter guidance</a>, with domain separation and feature-driven organization.
    </p>
  </section>

  <section>
    <h2>Features</h2>
    <ul>
      <li><strong>Agent Marketplace:</strong> Browse and hire AI agents across productivity, data, and creative categories.</li>
      <li><strong>Micropayments:</strong> Pay per interaction using USDC on Solana with transparent 7–10% platform fees.</li>
      <li><strong>Agent Interactions:</strong> Chat, query, or upload data to AI agents with real-time streaming responses.</li>
      <li><strong>Profile Management:</strong> Track spending, view hired agents, and manage memberships.</li>
      <li><strong>Activity Tracking:</strong> Review transaction history, categorize activities, and verify on Solana Explorer.</li>
    </ul>
  </section>

  <section>
    <h2>Tech Stack</h2>
    <ul>
      <li><strong>Frontend:</strong> Flutter (iOS & Android)</li>
      <li><strong>State Management:</strong> Riverpod</li>
      <li><strong>Routing:</strong> go_router</li>
      <li><strong>Network:</strong> Dio (with interceptors & retry)</li>
      <li><strong>Authentication:</strong> Privy Flutter SDK (OAuth + Email OTP)</li>
      <li><strong>Payments:</strong> Phantom Wallet + x402 protocol</li>
      <li><strong>Blockchain:</strong> Solana packages (<code>coral_xyz</code>, <code>solana</code>)</li>
      <li><strong>Theming:</strong> FlexColorScheme + Google Fonts</li>
    </ul>
  </section>

  <section>
    <h2>Screenshots</h2>
    <div class="screenshot-row">
      <img src="screenshots/onboarding1.png" alt="Welcome Screen" />
      <img src="screenshots/onboarding2.png" alt="Features Screen" />
      <img src="screenshots/onboarding3.png" alt="Get Started" />
      <img src="screenshots/home.png" alt="Marketplace" />
      <img src="screenshots/interact-with-model1.png" alt="Chat Interface" />
      <img src="screenshots/interact-with-model2.png" alt="Response View" />
      <img src="screenshots/create-agents.png" alt="Create Agent" />
      <img src="screenshots/my-agents.png" alt="My Agents" />
    </div>
  </section>

  <section>
    <h2>Authentication</h2>
    <ul>
      <li>OAuth sign-in via Google, X, or Discord handled by <code>PrivyAuthService.authenticate</code>.</li>
      <li>Email + OTP via <code>EmailLoginController</code> and <code>EmailLoginFlow</code>.</li>
      <li>Session persistence with <code>flutter_secure_storage</code>.</li>
      <li>Auto-refresh via Privy tokens (≈30 days).</li>
    </ul>
  </section>

  <section>
    <h2>Payment Flow</h2>
    <ol>
      <li>User selects an agent and submits a query.</li>
      <li>Backend returns a <code>402 Payment Required</code> response.</li>
      <li>App opens Phantom for transaction approval.</li>
      <li>Transaction signature is verified by backend via Corbits x402.</li>
      <li>Access to the AI agent is unlocked after confirmation.</li>
    </ol>
  </section>

  <section>
    <h2>Architecture Overview</h2>
    <pre><code>
lib/
  presentation/    # UI components and pages
  application/     # Controllers, providers, business logic
  domain/          # Entities, value objects, repository interfaces
  data/            # APIs, datasources, repository implementations
  core/            # Config, routing, services, theming
  shared/          # Reusable widgets and components
    </code></pre>
  </section>

  <section>
    <h2>Setup & Run</h2>

    <h3>Clone & Install</h3>
    <pre><code>git clone https://github.com/yourusername/axyn-mobile.git
cd mobile
flutter pub get
    </code></pre>

    <h3>Environment Setup</h3>
    <pre><code>cp .env.example .env
    </code></pre>

    <p>Edit your <code>.env</code> file:</p>
    <pre><code># Privy Authentication
PRIVY_APP_ID=your_privy_app_id
PRIVY_CLIENT_ID=your_privy_client_id

# AxyN Backend
API_BASE_URL=https://api.axyn.ai

# Solana
SOLANA_NETWORK=mainnet-beta
HELIUS_RPC_URL=your_helius_rpc_url
USDC_MINT_ADDRESS=EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v
    </code></pre>

    <h3>Run App</h3>
    <pre><code># Development (devnet)
flutter run

# Production (mainnet-beta)
flutter run --release
    </code></pre>
  </section>

  <section>
    <h2>Development Commands</h2>
    <pre><code>flutter analyze
flutter test
dart format lib/ test/
    </code></pre>
  </section>

  <section>
    <h2>Environment Switching</h2>
    <pre><code>SOLANA_NETWORK=devnet flutter run
SOLANA_NETWORK=mainnet-beta flutter run --release
    </code></pre>
  </section>

  <section>
    <h2>Contributors</h2>
    <ul>
      <li><strong>Joel (Heisjoel0x):</strong> Flutter Developer & Project Lead</li>
      <li><strong>Ubadineke:</strong> Protocol Engineer (Solana)</li>
      <li><strong>Zion:</strong> AI Model Developer (Zurri AI)</li>
    </ul>
  </section>

  <section>
    <h2>Contact</h2>
    <p><strong>Developer:</strong> Joel</p>
    <p><strong>Twitter:</strong> <a href="https://twitter.com/Heisjoel0x">@Heisjoel0x</a></p>
    <p><strong>Email:</strong> <a href="mailto:immadominion@gmail.com">immadominion@gmail.com</a></p>
  </section>

  <section>
    <h2>License</h2>
    <p>MIT License — See <code>LICENSE</code> file for details.</p>
  </section>

</body>
</html>
