import 'package:flutter/foundation.dart';

import 'package:axyn_mobile/core/services/privy_auth_service.dart';

const _otpLength = 6;
const _resendCooldown = Duration(seconds: 45);

enum EmailLoginStep { enterEmail, verifyCode }

/// Immutable view state for the email + OTP flow.
class EmailLoginState {
  const EmailLoginState({
    this.step = EmailLoginStep.enterEmail,
    this.email = '',
    this.isLoading = false,
    this.errorMessage,
    this.infoMessage,
    this.codeSentAt,
  });

  final EmailLoginStep step;
  final String email;
  final bool isLoading;
  final String? errorMessage;
  final String? infoMessage;
  final DateTime? codeSentAt;

  bool get isEmailStep => step == EmailLoginStep.enterEmail;
  bool get isOtpStep => step == EmailLoginStep.verifyCode;

  int get secondsUntilResend {
    if (codeSentAt == null) return 0;
    final elapsed = DateTime.now().difference(codeSentAt!);
    final remaining = _resendCooldown - elapsed;
    return remaining.isNegative ? 0 : remaining.inSeconds;
  }

  bool get canResend => secondsUntilResend == 0;

  EmailLoginState copyWith({
    EmailLoginStep? step,
    String? email,
    bool? isLoading,
    String? errorMessage,
    String? infoMessage,
    DateTime? codeSentAt,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return EmailLoginState(
      step: step ?? this.step,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      infoMessage: clearInfo ? null : infoMessage ?? this.infoMessage,
      codeSentAt: codeSentAt ?? this.codeSentAt,
    );
  }
}

/// Handles email OTP orchestration for Privy-backed authentication.
class EmailLoginController extends ChangeNotifier {
  EmailLoginController(this._authService);

  final PrivyAuthService _authService;
  EmailLoginState _state = const EmailLoginState();
  bool _disposed = false;

  static final _emailRegex =
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$', caseSensitive: false);

  EmailLoginState get state => _state;

  void updateEmail(String email) {
    _updateState(
      _state.copyWith(email: email, clearError: true, clearInfo: true),
    );
  }

  Future<void> submitEmail() async {
    final email = _state.email.trim();

    if (email.isEmpty || !_emailRegex.hasMatch(email)) {
      _updateState(
        _state.copyWith(
          errorMessage: 'Enter a valid email address',
          clearInfo: true,
        ),
      );
      return;
    }

    _updateState(
      _state.copyWith(isLoading: true, clearError: true, clearInfo: true),
    );

    final result = await _authService.sendEmailCode(email);

    if (_disposed) return;

    if (result.success) {
      _updateState(
        _state.copyWith(
          step: EmailLoginStep.verifyCode,
          isLoading: false,
          codeSentAt: DateTime.now(),
          infoMessage: 'We sent a 6-digit code to ${_maskEmail(email)}',
        ),
      );
    } else {
      _updateState(
        _state.copyWith(
          isLoading: false,
          errorMessage: result.error ?? 'Failed to send code. Try again.',
        ),
      );
    }
  }

  Future<void> resendCode() async {
    if (!_state.canResend || _state.email.isEmpty) {
      return;
    }

    _updateState(_state.copyWith(isLoading: true, clearError: true));

    final result = await _authService.sendEmailCode(_state.email);

    if (_disposed) return;

    if (result.success) {
      _updateState(
        _state.copyWith(
          isLoading: false,
          codeSentAt: DateTime.now(),
          infoMessage: 'Code resent to ${_maskEmail(_state.email)}',
        ),
      );
    } else {
      _updateState(
        _state.copyWith(
          isLoading: false,
          errorMessage: result.error ?? 'Unable to resend code right now.',
        ),
      );
    }
  }

  Future<PrivyAuthResult?> verifyCode(String code) async {
    final trimmed = code.trim();

    if (trimmed.length != _otpLength) {
      _updateState(
        _state.copyWith(
          errorMessage: 'Enter the ${_otpLength}-digit code',
        ),
      );
      return null;
    }

    _updateState(
      _state.copyWith(isLoading: true, clearError: true, clearInfo: true),
    );

    final result = await _authService.loginWithEmailCode(
      email: _state.email,
      code: trimmed,
    );

    if (_disposed) return null;

    if (result.success) {
      _updateState(_state.copyWith(isLoading: false));
      return result;
    }

    _updateState(
      _state.copyWith(
        isLoading: false,
        errorMessage: result.error ?? 'Invalid code. Try again.',
      ),
    );

    return null;
  }

  void reset() {
    _updateState(const EmailLoginState());
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _updateState(EmailLoginState value) {
    if (_disposed) return;
    _state = value;
    notifyListeners();
  }

  static String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) {
      return '${name[0]}***@$domain';
    }

    final visiblePrefix = name.substring(0, 2);
    return '$visiblePrefix***@$domain';
  }
}
