import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:axyn_mobile/application/account/user_profile_provider.dart';

/// Provides the current user's USDC balance.
///
/// This provider watches the user profile and exposes just the balance field,
/// making it easy to use balance across multiple screens without coupling to
/// the full UserProfile entity.
final balanceProvider = Provider<double>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.maybeWhen(
    data: (profile) => profile.balance,
    orElse: () => 0.0,
  );
});
