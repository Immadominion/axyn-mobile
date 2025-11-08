/// Solana network type for merchant operations
enum NetworkType {
  /// Devnet - sandbox environment for testing and QA
  devnet,

  /// Mainnet - live Solana network for production merchants
  mainnet,
}

extension NetworkTypeExtension on NetworkType {
  /// Display label for UI
  String get displayLabel => this == NetworkType.devnet ? 'Devnet' : 'Mainnet';

  /// Description text for UI
  String get description => this == NetworkType.devnet
      ? 'Sandbox environment for testing and QA.'
      : 'Live Solana network for production merchants.';

  /// Network parameter string for API calls
  String get networkParameter =>
      this == NetworkType.devnet ? 'devnet' : 'mainnet';
}
