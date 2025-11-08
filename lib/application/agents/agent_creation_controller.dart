import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging/app_logger.dart';
import '../../data/datasources/agent_remote_datasource.dart';
import '../../data/network/dio_client.dart';
import '../../domain/entities/agent_listing.dart';
import '../../domain/models/agent_type.dart';
import '../../domain/models/create_agent_request.dart';

/// State for agent creation flow
class AgentCreationState {
  const AgentCreationState({
    this.selectedType,
    this.name,
    this.description,
    this.category,
    this.pricePerRequest,
    this.apiEndpoint,
    this.walletAddress,
    this.interfaceType,
    this.iconFile,
    this.iconUrl,
    this.metadata = const {},
    this.validationErrors = const {},
    this.isSubmitting = false,
    this.currentStep = 0,
  });

  final AgentType? selectedType;
  final String? name;
  final String? description;
  final AgentCategory? category;
  final double? pricePerRequest;
  final String? apiEndpoint;
  final String? walletAddress;
  final InterfaceType? interfaceType;
  final File? iconFile;
  final String? iconUrl;
  final Map<String, dynamic> metadata;
  final Map<String, String> validationErrors;
  final bool isSubmitting;
  final int currentStep; // 0=basic, 1=pricing, 2=api, 3=metadata

  AgentCreationState copyWith({
    AgentType? selectedType,
    String? name,
    String? description,
    AgentCategory? category,
    double? pricePerRequest,
    String? apiEndpoint,
    String? walletAddress,
    InterfaceType? interfaceType,
    File? iconFile,
    String? iconUrl,
    Map<String, dynamic>? metadata,
    Map<String, String>? validationErrors,
    bool? isSubmitting,
    int? currentStep,
  }) =>
      AgentCreationState(
        selectedType: selectedType ?? this.selectedType,
        name: name ?? this.name,
        description: description ?? this.description,
        category: category ?? this.category,
        pricePerRequest: pricePerRequest ?? this.pricePerRequest,
        apiEndpoint: apiEndpoint ?? this.apiEndpoint,
        walletAddress: walletAddress ?? this.walletAddress,
        interfaceType: interfaceType ?? this.interfaceType,
        iconFile: iconFile ?? this.iconFile,
        iconUrl: iconUrl ?? this.iconUrl,
        metadata: metadata ?? this.metadata,
        validationErrors: validationErrors ?? this.validationErrors,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        currentStep: currentStep ?? this.currentStep,
      );

  bool get canSubmit =>
      name != null &&
      description != null &&
      category != null &&
      pricePerRequest != null &&
      apiEndpoint != null &&
      walletAddress != null &&
      interfaceType != null &&
      validationErrors.isEmpty;
}

/// Controller for agent creation
class AgentCreationController extends Notifier<AgentCreationState> {
  @override
  AgentCreationState build() => const AgentCreationState();

  AgentRemoteDatasource get _datasource =>
      ref.read(agentRemoteDatasourceProvider);

  void selectAgentType(AgentType type) {
    AppLogger.d('[AgentCreationController] Selected type: ${type.name}');

    // Update selected type
    state = state.copyWith(selectedType: type);

    // Auto-set request format based on agent type
    final metadata = Map<String, dynamic>.from(state.metadata);
    metadata['requestFormat'] = type.defaultRequestFormat;
    state = state.copyWith(metadata: metadata);
  }

  void updateField(String field, dynamic value) {
    AppLogger.d('[AgentCreationController] Update $field: $value');

    switch (field) {
      case 'name':
        state = state.copyWith(name: value as String?);
      case 'description':
        state = state.copyWith(description: value as String?);
      case 'category':
        state = state.copyWith(category: value as AgentCategory?);
      case 'pricePerRequest':
        state = state.copyWith(pricePerRequest: value as double?);
      case 'apiEndpoint':
        state = state.copyWith(apiEndpoint: value as String?);
      case 'walletAddress':
        state = state.copyWith(walletAddress: value as String?);
      case 'interfaceType':
        state = state.copyWith(interfaceType: value as InterfaceType?);
      default:
        AppLogger.e('[AgentCreationController] Unknown field: $field');
    }

    _validateField(field);
  }

  void updateMetadata(String key, dynamic value) {
    final newMetadata = Map<String, dynamic>.from(state.metadata);
    newMetadata[key] = value;
    state = state.copyWith(metadata: newMetadata);
  }

  void setIcon(File file) {
    AppLogger.d('[AgentCreationController] Icon selected: ${file.path}');
    state = state.copyWith(iconFile: file);
  }

  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void _validateField(String field) {
    final errors = Map<String, String>.from(state.validationErrors);

    switch (field) {
      case 'name':
        if (state.name == null || state.name!.isEmpty) {
          errors['name'] = 'Name is required';
        } else if (state.name!.length < 3) {
          errors['name'] = 'Name must be at least 3 characters';
        } else if (state.name!.length > 255) {
          errors['name'] = 'Name must be less than 255 characters';
        } else {
          errors.remove('name');
        }
      case 'description':
        if (state.description == null || state.description!.isEmpty) {
          errors['description'] = 'Description is required';
        } else if (state.description!.length < 10) {
          errors['description'] = 'Description must be at least 10 characters';
        } else if (state.description!.length > 2000) {
          errors['description'] =
              'Description must be less than 2000 characters';
        } else {
          errors.remove('description');
        }
      case 'pricePerRequest':
        if (state.pricePerRequest == null) {
          errors['pricePerRequest'] = 'Price is required';
        } else if (state.pricePerRequest! < 0.0001) {
          errors['pricePerRequest'] = 'Minimum price is \$0.0001';
        } else if (state.pricePerRequest! > 1000) {
          errors['pricePerRequest'] = 'Maximum price is \$1000';
        } else {
          errors.remove('pricePerRequest');
        }
      case 'apiEndpoint':
        if (state.apiEndpoint == null || state.apiEndpoint!.isEmpty) {
          errors['apiEndpoint'] = 'API endpoint is required';
        } else {
          final uri = Uri.tryParse(state.apiEndpoint!);
          if (uri == null || !uri.hasAbsolutePath) {
            errors['apiEndpoint'] = 'Must be a valid URL';
          } else {
            errors.remove('apiEndpoint');
          }
        }
      case 'walletAddress':
        if (state.walletAddress == null || state.walletAddress!.isEmpty) {
          errors['walletAddress'] = 'Wallet address is required';
        } else if (!RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$')
            .hasMatch(state.walletAddress!)) {
          errors['walletAddress'] = 'Invalid Solana wallet address';
        } else {
          errors.remove('walletAddress');
        }
    }

    state = state.copyWith(validationErrors: errors);
  }

  Future<AgentListing?> submit() async {
    AppLogger.d('[AgentCreationController] Submitting agent...');

    // Validate all fields
    _validateField('name');
    _validateField('description');
    _validateField('pricePerRequest');
    _validateField('apiEndpoint');
    _validateField('walletAddress');

    if (!state.canSubmit) {
      AppLogger.e(
          '[AgentCreationController] Validation failed: ${state.validationErrors}');
      return null;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      // Upload icon if selected
      String? iconUrl = state.iconUrl;
      if (state.iconFile != null && iconUrl == null) {
        AppLogger.d('[AgentCreationController] Uploading icon...');
        iconUrl = await _datasource.uploadIcon(state.iconFile!);
        state = state.copyWith(iconUrl: iconUrl);
      }

      // Build request
      final request = CreateAgentRequest(
        name: state.name!,
        description: state.description!,
        category: state.category!,
        pricePerRequest: state.pricePerRequest!,
        apiEndpoint: state.apiEndpoint!,
        walletAddress: state.walletAddress!,
        interfaceType: state.interfaceType!,
        iconUrl: iconUrl,
        metadata: state.metadata.isNotEmpty ? state.metadata : null,
      );

      // Submit
      final agent = await _datasource.createAgent(request);
      AppLogger.d('[AgentCreationController] Agent created: ${agent.id}');

      // Reset state
      state = const AgentCreationState();

      return agent;
    } catch (e, stack) {
      AppLogger.e('[AgentCreationController] Error creating agent: $e');
      AppLogger.e('[AgentCreationController] Stack trace: $stack');
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }

  void reset() {
    state = const AgentCreationState();
  }
}

/// Provider for agent creation controller
final agentCreationControllerProvider =
    NotifierProvider<AgentCreationController, AgentCreationState>(
  AgentCreationController.new,
);

// Datasource provider (imported from agent_list_controller.dart)
final agentRemoteDatasourceProvider = Provider<AgentRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return AgentRemoteDatasource(dio);
});
