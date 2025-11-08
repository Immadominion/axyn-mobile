/// Result of a merchant creation operation
class MerchantCreationResult {
  const MerchantCreationResult({
    required this.success,
    this.merchantPda,
    this.transactionSignature,
    this.message,
    this.error,
  });

  final bool success;
  final String? merchantPda;
  final String? transactionSignature;
  final String? message;
  final String? error;

  factory MerchantCreationResult.success({
    required String merchantPda,
    required String transactionSignature,
    required String message,
  }) {
    return MerchantCreationResult(
      success: true,
      merchantPda: merchantPda,
      transactionSignature: transactionSignature,
      message: message,
    );
  }

  factory MerchantCreationResult.failure(String error) {
    return MerchantCreationResult(
      success: false,
      error: error,
    );
  }
}
