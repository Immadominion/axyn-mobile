import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Payment methods available when generating POS transactions.
enum PaymentType { crypto, cash, card }

final paymentTypeProvider =
    NotifierProvider<PaymentTypeController, PaymentType>(
  PaymentTypeController.new,
);

class PaymentTypeController extends Notifier<PaymentType> {
  @override
  PaymentType build() => PaymentType.crypto;

  void setType(PaymentType type) {
    state = type;
  }
}

/// Stablecoins supported for crypto settlements.
enum TokenType { usdc, usdt }

final selectedTokenProvider =
    NotifierProvider<SelectedTokenController, TokenType>(
  SelectedTokenController.new,
);

class SelectedTokenController extends Notifier<TokenType> {
  @override
  TokenType build() => TokenType.usdc;

  void setToken(TokenType token) {
    state = token;
  }
}
