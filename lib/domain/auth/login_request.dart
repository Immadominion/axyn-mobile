class LoginRequest {
  const LoginRequest({required this.authToken, this.walletAddress});

  final String authToken;
  final String? walletAddress;

  Map<String, dynamic> toJson() => {
        'authToken': authToken,
        if (walletAddress != null) 'walletAddress': walletAddress,
      };
}
