import 'package:axyn_mobile/presentation/features/home/providers/payment_flow_providers.dart';

/// Optional data passed to the receive payment flow to pre-populate fields.
class ReceivePaymentPrefill {
  const ReceivePaymentPrefill({
    this.amountCents,
    this.memo,
    this.paymentType,
    this.tokenType,
  });

  final int? amountCents;
  final String? memo;
  final PaymentType? paymentType;
  final TokenType? tokenType;
}
