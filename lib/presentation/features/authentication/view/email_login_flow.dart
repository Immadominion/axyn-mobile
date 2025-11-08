import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pinput/pinput.dart';

import 'package:axyn_mobile/application/auth/email_login_controller.dart';
import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/core/services/privy_auth_service.dart';
import 'package:axyn_mobile/shared/widgets/app_button.dart';
import 'package:axyn_mobile/shared/widgets/app_card.dart';

/// Presents the email + OTP login flow as a modal bottom sheet.
Future<bool?> showEmailLoginFlow({
  required BuildContext context,
  required PrivyAuthService authService,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.35),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => _EmailLoginSheet(authService: authService),
  );
}

class _EmailLoginSheet extends StatefulWidget {
  const _EmailLoginSheet({required this.authService});

  final PrivyAuthService authService;

  @override
  State<_EmailLoginSheet> createState() => _EmailLoginSheetState();
}

class _EmailLoginSheetState extends State<_EmailLoginSheet> {
  late final EmailLoginController _controller;
  late final TextEditingController _emailTextController;
  late final TextEditingController _otpTextController;
  late final FocusNode _emailFocusNode;
  late final FocusNode _otpFocusNode;

  @override
  void initState() {
    super.initState();
    _controller = EmailLoginController(widget.authService);
    _emailTextController = TextEditingController();
    _otpTextController = TextEditingController();
    _emailFocusNode = FocusNode();
    _otpFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailTextController.dispose();
    _otpTextController.dispose();
    _emailFocusNode.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final viewInsets = mediaQuery.viewInsets;
    final bool keyboardVisible = viewInsets.bottom > 0;

    final double sheetMaxWidth = math.min<double>(520.w, size.width);
    final double handleHeight = 5.h;
    final double handleSpacing = AppSpacing.md.h;
    final double targetHeight = size.height * 0.57;

    final double safeHeight = size.height -
        viewInsets.bottom -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
    final double maxAllowedHeight = math.max<double>(
      0,
      safeHeight - AppSpacing.lg.h - handleHeight - handleSpacing,
    );
    final double cappedHeight = maxAllowedHeight == 0
        ? targetHeight
        : math.min(targetHeight, maxAllowedHeight);
    final double baseMinHeight = cappedHeight;

    Future<void> submitEmail() async {
      FocusScope.of(context).unfocus();
      await _controller.submitEmail();

      if (!mounted) return;

      if (_controller.state.isOtpStep) {
        _otpTextController.clear();
        await Future<void>.delayed(const Duration(milliseconds: 80));
        if (mounted) {
          _otpFocusNode.requestFocus();
        }
      }
    }

    Future<void> verifyCode(String code) async {
      FocusScope.of(context).unfocus();
      final result = await _controller.verifyCode(code);
      if (mounted && result?.success == true) {
        Navigator.of(context).pop(true);
      }
    }

    Future<void> resendCode() => _controller.resendCode();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final state = _controller.state;
        final bool otpWithKeyboard = keyboardVisible;

        final double otpKeyboardHeight = otpWithKeyboard && maxAllowedHeight > 0
            ? math.min(
                maxAllowedHeight,
                math.max(
                  baseMinHeight * 0.8,
                  maxAllowedHeight * 0.78,
                ),
              )
            : baseMinHeight;

        final double cardHeightLimit = maxAllowedHeight > 0
            ? (otpWithKeyboard ? otpKeyboardHeight : baseMinHeight)
            : double.infinity;

        if (state.isEmailStep) {
          if (_emailTextController.text != state.email) {
            _emailTextController.value = TextEditingValue(
              text: state.email,
              selection: TextSelection.collapsed(offset: state.email.length),
            );
          }

          if (_otpTextController.text.isNotEmpty) {
            _otpTextController.clear();
          }
        }

        final topSection = <Widget>[
          Text(
            'Email sign-in',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onBackground,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            state.isEmailStep
                ? 'Enter the email you use for Privy sign-in.'
                : 'Enter the 6-digit code we sent to ${state.email}.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onBackground.withOpacity(0.72),
            ),
          ),
          SizedBox(height: AppSpacing.xl.h),
          if (state.isEmailStep)
            _EmailEntryForm(
              controller: _controller,
              textController: _emailTextController,
              focusNode: _emailFocusNode,
              onSubmit: submitEmail,
            )
          else
            _OtpEntryForm(
              state: state,
              controller: _controller,
              textController: _otpTextController,
              focusNode: _otpFocusNode,
              onVerify: verifyCode,
              onResend: resendCode,
            ),
          SizedBox(height: AppSpacing.lg.h),
        ];

        if (state.errorMessage != null) {
          topSection.add(
            _InfoBanner(
              message: state.errorMessage!,
              isError: true,
            ),
          );
        }

        if (state.infoMessage != null) {
          topSection.add(
            Padding(
              padding: EdgeInsets.only(
                top: state.errorMessage != null ? AppSpacing.sm.h : 0,
              ),
              child: _InfoBanner(message: state.infoMessage!),
            ),
          );
        }

        topSection.add(SizedBox(height: AppSpacing.lg.h));

        final bottomSection = <Widget>[
          AppButton.primary(
            label: state.isLoading
                ? (state.isEmailStep ? 'Sending...' : 'Verifying...')
                : (state.isEmailStep ? 'Continue' : 'Verify code'),
            onPressed: state.isLoading
                ? null
                : state.isEmailStep
                    ? submitEmail
                    : () => verifyCode(_otpTextController.text),
            expanded: true,
          ),
        ];

        if (!state.isEmailStep) {
          bottomSection.addAll([
            SizedBox(height: AppSpacing.sm.h),
            TextButton(
              onPressed: state.isLoading
                  ? null
                  : () {
                      _controller.reset();
                      _otpTextController.clear();
                      _emailTextController.clear();
                      _emailFocusNode.requestFocus();
                    },
              child: const Text('Use a different email'),
            ),
          ]);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(
              left: AppSpacing.md.w,
              right: AppSpacing.md.w,
              bottom: viewInsets.bottom + AppSpacing.lg.h,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: sheetMaxWidth,
                  maxHeight: maxAllowedHeight > 0
                      ? maxAllowedHeight + handleHeight + handleSpacing
                      : size.height,
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48.w,
                          height: handleHeight,
                          decoration: BoxDecoration(
                            color: scheme.onSurface.withOpacity(0.24),
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        SizedBox(height: handleSpacing),
                        Flexible(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: cardHeightLimit,
                                ),
                                child: AppCard(
                                  borderRadius: AppRadius.lg,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md.w,
                                    vertical: AppSpacing.xl.h,
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, cardConstraints) {
                                      final bool hasFiniteHeight =
                                          cardConstraints.maxHeight.isFinite &&
                                              cardConstraints.maxHeight <
                                                  double.infinity &&
                                              cardConstraints.maxHeight > 0;

                                      if (hasFiniteHeight) {
                                        return SizedBox(
                                          height: cardConstraints.maxHeight,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  physics:
                                                      const BouncingScrollPhysics(),
                                                  child: ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      minHeight: math.min(
                                                        baseMinHeight,
                                                        cardConstraints
                                                            .maxHeight,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: topSection,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              ...bottomSection,
                                            ],
                                          ),
                                        );
                                      }

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              minHeight: baseMinHeight,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: topSection,
                                            ),
                                          ),
                                          ...bottomSection,
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                              if (state.isLoading)
                                _LoadingOverlay(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmailEntryForm extends StatelessWidget {
  const _EmailEntryForm({
    required this.controller,
    required this.textController,
    required this.focusNode,
    required this.onSubmit,
  });

  final EmailLoginController controller;
  final TextEditingController textController;
  final FocusNode focusNode;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: textController,
          focusNode: focusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onChanged: controller.updateEmail,
          onSubmitted: (_) => onSubmit(),
          decoration: InputDecoration(
            labelText: 'Email address',
            hintText: 'name@example.com',
            filled: true,
            fillColor: scheme.surfaceVariant.withOpacity(0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.sm.h),
        Row(
          children: [
            Icon(Icons.lock_outline, size: 18.sp, color: scheme.primary),
            SizedBox(width: AppSpacing.xs.w),
            Expanded(
              child: Text(
                'Powered by Privy',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OtpEntryForm extends StatelessWidget {
  const _OtpEntryForm({
    required this.state,
    required this.controller,
    required this.textController,
    required this.focusNode,
    required this.onVerify,
    required this.onResend,
  });

  final EmailLoginState state;
  final EmailLoginController controller;
  final TextEditingController textController;
  final FocusNode focusNode;
  final Future<void> Function(String code) onVerify;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final defaultPinTheme = PinTheme(
      width: 50.w,
      height: 60.h,
      textStyle: theme.textTheme.headlineSmall?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 24.sp,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.5)),
      ),
    );

    final focusedTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: scheme.primary),
      color: scheme.primary.withOpacity(0.12),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Pinput(
          length: 6,
          controller: textController,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          animationCurve: Curves.easeOutCubic,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedTheme,
          submittedPinTheme: defaultPinTheme,
          onCompleted: onVerify,
        ),
        SizedBox(height: AppSpacing.sm.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              onPressed: state.canResend && !state.isLoading ? onResend : null,
              label: Text(
                state.canResend
                    ? 'Resend code'
                    : 'Resend in ${state.secondsUntilResend}s',
              ),
            ),
            TextButton(
              onPressed: controller.reset,
              child: const Text('Edit email'),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          isError ? PhosphorIcons.warning() : PhosphorIcons.info(),
          color: isError ? scheme.error : scheme.primary,
          size: 16.sp,
        ),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isError ? scheme.error : scheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({this.borderRadius});

  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.12),
            borderRadius: borderRadius,
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
