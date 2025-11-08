/// Represents an AI agent listing in the marketplace.
class AgentListing {
  const AgentListing({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.pricePerRequest,
    required this.iconUrl,
    required this.rating,
    required this.totalJobs,
    required this.uptime,
    required this.isOnline,
    required this.walletAddress,
    required this.tags,
    required this.apiEndpoint,
    required this.interfaceType,
    this.shortDescription,
    this.exampleInput,
    this.exampleOutput,
  });

  final String id;
  final String name;
  final String description;
  final String? shortDescription;
  final String category;
  final double pricePerRequest;
  final String iconUrl;
  final double rating;
  final int totalJobs;
  final double uptime;
  final bool isOnline;
  final String walletAddress;
  final List<String> tags;

  // x402 agent endpoints
  final String apiEndpoint;
  final String interfaceType; // 'chat', 'single-query', 'data'

  // Example usage
  final String? exampleInput;
  final String? exampleOutput;

  String get priceDisplay {
    // Format micro-payments properly
    if (pricePerRequest < 0.01) {
      // Show more decimal places for micro-payments
      if (pricePerRequest < 0.001) {
        return '\$${pricePerRequest.toStringAsFixed(4)}/call';
      }
      return '\$${pricePerRequest.toStringAsFixed(3)}/call';
    }
    return '\$${pricePerRequest.toStringAsFixed(2)}/query';
  }

  String get ratingDisplay => rating.toStringAsFixed(1);

  // Backend stores uptime as decimal percentage (100.00 = 100%)
  String get uptimeDisplay => '${uptime.toStringAsFixed(0)}%';

  String get jobsDisplay {
    if (totalJobs >= 1000000) {
      return '${(totalJobs / 1000000).toStringAsFixed(1)}M';
    } else if (totalJobs >= 1000) {
      return '${(totalJobs / 1000).toStringAsFixed(1)}K';
    }
    return totalJobs.toString();
  }

  /// Parse double that may come as string (PostgreSQL decimals) or number
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Parse int that may come as string or number
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  /// Create AgentListing from JSON response
  factory AgentListing.fromJson(Map<String, dynamic> json) {
    return AgentListing(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      shortDescription: json['shortDescription'] as String?,
      category: json['category'] as String? ?? 'other',
      pricePerRequest: _parseDouble(json['pricePerRequest']),
      iconUrl: json['iconUrl'] as String? ?? '',
      rating: _parseDouble(json['rating']),
      totalJobs: _parseInt(json['totalJobs']),
      uptime: _parseDouble(json['uptime']),
      isOnline: json['isOnline'] as bool? ?? true,
      walletAddress: json['walletAddress'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              [],
      apiEndpoint: json['apiEndpoint'] as String? ?? '',
      interfaceType: json['interfaceType'] as String? ?? 'chat',
      exampleInput: json['exampleInput'] as String?,
      exampleOutput: json['exampleOutput'] as String?,
    );
  }

  /// Convert AgentListing to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      if (shortDescription != null) 'shortDescription': shortDescription,
      'category': category,
      'pricePerRequest': pricePerRequest,
      'iconUrl': iconUrl,
      'rating': rating,
      'totalJobs': totalJobs,
      'uptime': uptime,
      'isOnline': isOnline,
      'walletAddress': walletAddress,
      'tags': tags,
      'apiEndpoint': apiEndpoint,
      'interfaceType': interfaceType,
      if (exampleInput != null) 'exampleInput': exampleInput,
      if (exampleOutput != null) 'exampleOutput': exampleOutput,
    };
  }
}
