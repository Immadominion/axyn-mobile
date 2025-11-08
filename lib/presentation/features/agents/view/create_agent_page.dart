import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../application/agents/agent_creation_controller.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../domain/models/agent_type.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/app_button.dart';
import '../widgets/agent_type_selector.dart';
import '../widgets/metadata_form_fields.dart';

/// Create Agent Page - Multi-step form for envoys to list their AI agents
class CreateAgentPage extends ConsumerStatefulWidget {
  const CreateAgentPage({super.key});

  @override
  ConsumerState<CreateAgentPage> createState() => _CreateAgentPageState();
}

class _CreateAgentPageState extends ConsumerState<CreateAgentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _apiEndpointController = TextEditingController();
  final _walletAddressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _apiEndpointController.dispose();
    _walletAddressController.dispose();
    super.dispose();
  }

  Future<void> _pickIcon() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      ref.read(agentCreationControllerProvider.notifier).setIcon(file);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = ref.read(agentCreationControllerProvider.notifier);

    try {
      final agent = await controller.submit();

      if (agent != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agent created successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = ref.watch(agentCreationControllerProvider);
    final controller = ref.read(agentCreationControllerProvider.notifier);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg.w,
                  vertical: AppSpacing.md.h,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        PhosphorIconsRegular.arrowLeft,
                        color: scheme.onSurface,
                        size: 24.sp,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Agent',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                              fontSize: 20.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Earn 90-93% revenue from interactions',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.7),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg.w,
                      AppSpacing.xs.h,
                      AppSpacing.lg.w,
                      AppSpacing.lg.h + bottomInset,
                    ),
                    children: [
                      // Agent Type Selector
                      AgentTypeSelector(
                        selectedType: state.selectedType,
                        onTypeSelected: controller.selectAgentType,
                      ),
                      SizedBox(height: AppSpacing.lg.h),

                      // Basic Information
                      _buildSection(
                        title: 'Basic Information',
                        icon: PhosphorIconsRegular.info,
                        theme: theme,
                        scheme: scheme,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _nameController,
                              label: 'Agent Name',
                              hint: 'e.g., Crypto Analyst Pro',
                              errorText: state.validationErrors['name'],
                              onChanged: (value) =>
                                  controller.updateField('name', value),
                              theme: theme,
                              scheme: scheme,
                            ),
                            SizedBox(height: AppSpacing.md.h),
                            _buildTextField(
                              controller: _descriptionController,
                              label: 'Description',
                              hint: 'What does your agent do?',
                              maxLines: 3,
                              maxLength: 2000,
                              errorText: state.validationErrors['description'],
                              onChanged: (value) =>
                                  controller.updateField('description', value),
                              theme: theme,
                              scheme: scheme,
                            ),
                            SizedBox(height: AppSpacing.md.h),
                            _buildDropdown<AgentCategory>(
                              label: 'Category',
                              value: state.category,
                              items: AgentCategory.values
                                  .map((cat) => DropdownMenuItem(
                                        value: cat,
                                        child: Text(cat.label),
                                      ))
                                  .toList(),
                              onChanged: (value) =>
                                  controller.updateField('category', value),
                              theme: theme,
                              scheme: scheme,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg.h),

                      // Pricing & Icon
                      _buildSection(
                        title: 'Pricing & Icon',
                        icon: PhosphorIconsRegular.currencyDollar,
                        theme: theme,
                        scheme: scheme,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _priceController,
                              label: 'Price per Request (USD)',
                              hint: '0.01',
                              prefixText: '\$ ',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,4}'),
                                ),
                              ],
                              errorText:
                                  state.validationErrors['pricePerRequest'],
                              onChanged: (value) {
                                final price = double.tryParse(value);
                                controller.updateField(
                                    'pricePerRequest', price);
                              },
                              theme: theme,
                              scheme: scheme,
                            ),
                            SizedBox(height: AppSpacing.md.h),
                            _buildIconPicker(state, scheme, theme),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg.h),

                      // API Configuration
                      _buildSection(
                        title: 'API Configuration',
                        icon: PhosphorIconsRegular.cloud,
                        theme: theme,
                        scheme: scheme,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _apiEndpointController,
                              label: 'API Endpoint',
                              hint: 'https://your-agent.com/api',
                              errorText: state.validationErrors['apiEndpoint'],
                              onChanged: (value) =>
                                  controller.updateField('apiEndpoint', value),
                              theme: theme,
                              scheme: scheme,
                            ),
                            SizedBox(height: AppSpacing.md.h),
                            _buildTextField(
                              controller: _walletAddressController,
                              label: 'Solana Wallet Address',
                              hint: 'Your wallet to receive payments',
                              errorText:
                                  state.validationErrors['walletAddress'],
                              onChanged: (value) => controller.updateField(
                                  'walletAddress', value),
                              theme: theme,
                              scheme: scheme,
                            ),
                            SizedBox(height: AppSpacing.md.h),
                            _buildDropdown<InterfaceType>(
                              label: 'Interface Type',
                              value: state.interfaceType,
                              items: InterfaceType.values
                                  .map((type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type.label),
                                      ))
                                  .toList(),
                              onChanged: (value) => controller.updateField(
                                  'interfaceType', value),
                              theme: theme,
                              scheme: scheme,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg.h),

                      // Dynamic Metadata based on agent type
                      if (state.selectedType != null)
                        _buildSection(
                          title: 'Agent-Specific Configuration',
                          icon: PhosphorIconsRegular.gear,
                          theme: theme,
                          scheme: scheme,
                          child: MetadataFormFields(
                            agentType: state.selectedType,
                            metadata: state.metadata,
                            onMetadataChanged: (metadata) {
                              for (final entry in metadata.entries) {
                                controller.updateMetadata(
                                    entry.key, entry.value);
                              }
                            },
                          ),
                        ),
                      SizedBox(height: AppSpacing.xxl.h),

                      // Submit Button
                      AppButton.primary(
                        label:
                            state.isSubmitting ? 'Creating...' : 'Create Agent',
                        onPressed: state.canSubmit && !state.isSubmitting
                            ? _submit
                            : null,
                        expanded: true,
                      ),
                      SizedBox(height: AppSpacing.md.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required ThemeData theme,
    required ColorScheme scheme,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.1),
          width: 1.5.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  size: 18.sp,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ThemeData theme,
    required ColorScheme scheme,
    String? errorText,
    String? prefixText,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface,
            fontSize: 14.sp,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
              fontSize: 14.sp,
            ),
            filled: true,
            fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: scheme.outline.withValues(alpha: 0.1),
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: scheme.primary,
                width: 2.w,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: scheme.error,
                width: 1.w,
              ),
            ),
            errorText: errorText,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md.w,
              vertical: AppSpacing.sm.h,
            ),
          ),
          onChanged: onChanged,
          validator: (value) => errorText,
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required ThemeData theme,
    required ColorScheme scheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface,
            fontSize: 14.sp,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: scheme.outline.withValues(alpha: 0.1),
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: scheme.primary,
                width: 2.w,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md.w,
              vertical: AppSpacing.sm.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconPicker(
    AgentCreationState state,
    ColorScheme scheme,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agent Icon (Optional)',
          style: theme.textTheme.labelLarge?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: scheme.outline.withValues(alpha: 0.1),
                  width: 1.w,
                ),
              ),
              child: state.iconFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.file(
                        state.iconFile!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      PhosphorIconsRegular.image,
                      size: 32.sp,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
            ),
            SizedBox(width: AppSpacing.md.w),
            Expanded(
              child: AppButton.secondary(
                label: state.iconFile != null ? 'Change Icon' : 'Upload Icon',
                icon: PhosphorIconsRegular.upload,
                onPressed: _pickIcon,
                expanded: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
