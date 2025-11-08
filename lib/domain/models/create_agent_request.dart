import 'agent_type.dart';

/// Request DTO for creating an agent
class CreateAgentRequest {
  const CreateAgentRequest({
    required this.name,
    required this.description,
    required this.category,
    required this.pricePerRequest,
    required this.apiEndpoint,
    required this.walletAddress,
    required this.interfaceType,
    this.iconUrl,
    this.metadata,
  });

  final String name;
  final String description;
  final AgentCategory category;
  final double pricePerRequest;
  final String apiEndpoint;
  final String walletAddress;
  final InterfaceType interfaceType;
  final String? iconUrl;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'category': category.value,
        'pricePerRequest': pricePerRequest,
        'apiEndpoint': apiEndpoint,
        'walletAddress': walletAddress,
        'interfaceType': interfaceType.value,
        if (iconUrl != null) 'iconUrl': iconUrl,
        if (metadata != null) 'metadata': metadata,
      };
}

/// Agent metadata configuration
class AgentMetadata {
  AgentMetadata({
    this.requestFormat,
    this.responseFormat,
    this.httpMethod = 'POST',
    this.timeout = 30000,
    // Chat fields
    this.model,
    this.temperature,
    this.maxTokens,
    this.authToken,
    // Audio fields
    this.acceptsAudio,
    this.supportedFormats,
    this.fileFieldName,
    this.endpointParams,
    // Image fields
    this.acceptsImage,
    this.imageSize,
    this.quality,
    this.style,
    // Custom fields
    this.customHeaders,
    this.requestBodyTemplate,
    this.provider,
  });

  // General
  final String? requestFormat;
  final String? responseFormat;
  final String httpMethod;
  final int timeout;

  // Chat agent fields
  final String? model;
  final double? temperature;
  final int? maxTokens;
  final String? authToken;

  // Audio agent fields
  final bool? acceptsAudio;
  final List<String>? supportedFormats;
  final String? fileFieldName;
  final List<EndpointParam>? endpointParams;

  // Image agent fields
  final bool? acceptsImage;
  final String? imageSize;
  final String? quality;
  final String? style;

  // Custom agent fields
  final Map<String, String>? customHeaders;
  final Map<String, dynamic>? requestBodyTemplate;
  final String? provider;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'httpMethod': httpMethod,
      'timeout': timeout,
    };

    // Add only non-null fields
    if (requestFormat != null) json['requestFormat'] = requestFormat;
    if (responseFormat != null) json['responseFormat'] = responseFormat;
    if (model != null) json['model'] = model;
    if (temperature != null) json['temperature'] = temperature;
    if (maxTokens != null) json['maxTokens'] = maxTokens;
    if (authToken != null) json['authToken'] = authToken;
    if (acceptsAudio != null) json['acceptsAudio'] = acceptsAudio;
    if (supportedFormats != null) json['supportedFormats'] = supportedFormats;
    if (fileFieldName != null) json['fileFieldName'] = fileFieldName;
    if (endpointParams != null) {
      json['endpointParams'] = endpointParams!.map((p) => p.toJson()).toList();
    }
    if (acceptsImage != null) json['acceptsImage'] = acceptsImage;
    if (imageSize != null) json['imageSize'] = imageSize;
    if (quality != null) json['quality'] = quality;
    if (style != null) json['style'] = style;
    if (customHeaders != null) json['customHeaders'] = customHeaders;
    if (requestBodyTemplate != null) {
      json['requestBodyTemplate'] = requestBodyTemplate;
    }
    if (provider != null) json['provider'] = provider;

    return json;
  }
}

/// Endpoint parameter definition for dynamic forms
class EndpointParam {
  const EndpointParam({
    required this.name,
    required this.type,
    required this.label,
    this.defaultValue,
    this.options,
    this.required = false,
  });

  final String name;
  final String type; // 'text', 'number', 'select', 'boolean'
  final String label;
  final dynamic defaultValue;
  final List<String>? options; // For select type
  final bool required;

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'label': label,
        if (defaultValue != null) 'default': defaultValue,
        if (options != null) 'options': options,
        'required': required,
      };

  factory EndpointParam.fromJson(Map<String, dynamic> json) => EndpointParam(
        name: json['name'] as String,
        type: json['type'] as String,
        label: json['label'] as String,
        defaultValue: json['default'],
        options: (json['options'] as List<dynamic>?)?.cast<String>(),
        required: json['required'] as bool? ?? false,
      );
}
