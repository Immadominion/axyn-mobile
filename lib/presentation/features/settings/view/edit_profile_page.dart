import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../application/account/user_profile_provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/jwt_storage_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/logging/app_logger.dart';

/// Edit profile page for updating user name, bio, and avatar
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  String? _uploadedAvatarUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();

    // Load current profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileAsync = ref.read(userProfileProvider);
      profileAsync.whenData((profile) {
        _nameController.text = profile.displayName;
        _bioController.text = profile.bio ?? '';
        setState(() {
          _uploadedAvatarUrl = profile.avatarUrl;
        });
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        await _uploadAvatar();
      }
    } catch (e) {
      AppLogger.e('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _uploadAvatar() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final config = ref.read(appConfigProvider);
      final jwtStorage = ref.read(jwtStorageServiceProvider);

      // Get JWT token from secure storage
      final token = await jwtStorage.getToken();

      if (token == null) {
        throw Exception('User not authenticated - no JWT token found');
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${config.apiBaseUrl}/user/avatar'),
      );

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          _selectedImage!.path,
        ),
      );

      // Add JWT token to request body (as per backend AuthGuard pattern)
      request.fields['token'] = token;

      AppLogger.d('Uploading avatar to ${config.apiBaseUrl}/user/avatar');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        setState(() {
          _uploadedAvatarUrl =
              '${config.apiBaseUrl}${jsonResponse['avatarUrl']}';
          _isUploading = false;
        });
        AppLogger.d('Avatar uploaded successfully: $_uploadedAvatarUrl');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Avatar uploaded successfully')),
          );
        }
      } else {
        throw Exception(
            'Upload failed: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      AppLogger.e('Error uploading avatar: $e');
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload avatar: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();

    await ref.read(userProfileProvider.notifier).updateProfile(
          name: name.isEmpty ? null : name,
          bio: bio.isEmpty ? null : bio,
          avatarUrl: _uploadedAvatarUrl,
        );

    if (mounted) {
      // Check if update was successful
      final profileAsync = ref.read(userProfileProvider);
      profileAsync.when(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          context.pop();
        },
        loading: () {
          // Still loading, wait
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $error')),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: profileAsync.when(
        data: (profile) => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar preview with upload button
                  Center(
                    child: Stack(
                      children: [
                        // Avatar display
                        if (_selectedImage != null)
                          CircleAvatar(
                            radius: 50.w,
                            backgroundImage: FileImage(_selectedImage!),
                          )
                        else if (_uploadedAvatarUrl != null &&
                            _uploadedAvatarUrl!.isNotEmpty)
                          CircleAvatar(
                            radius: 50.w,
                            backgroundImage: NetworkImage(_uploadedAvatarUrl!),
                            onBackgroundImageError: (_, __) {},
                          )
                        else
                          Container(
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  scheme.primary,
                                  scheme.secondary,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                profile.displayName
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        // Upload button overlay
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: scheme.surface,
                                width: 2,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                color: scheme.onPrimary,
                                size: 20.sp,
                              ),
                              onPressed: _isUploading ? null : _pickImage,
                            ),
                          ),
                        ),

                        // Upload progress indicator
                        if (_isUploading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpacing.xl.h),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      hintText: 'Enter your name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name cannot be empty';
                      }
                      if (value.trim().length > 100) {
                        return 'Name must be 100 characters or less';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: AppSpacing.lg.h),

                  // Bio field
                  TextFormField(
                    controller: _bioController,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell us about yourself',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    maxLength: 500,
                    validator: (value) {
                      if (value != null && value.trim().length > 500) {
                        return 'Bio must be 500 characters or less';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: AppSpacing.lg.h),

                  // Avatar upload hint
                  if (_uploadedAvatarUrl != null)
                    Center(
                      child: Text(
                        'Avatar uploaded successfully! ✅',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                    ),

                  SizedBox(height: AppSpacing.xl.h),

                  // Save button
                  AppButton.primary(
                    label: 'Save Changes',
                    onPressed: _saveProfile,
                    expanded: true,
                  ),
                ],
              ),
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Unable to load profile: $error'),
        ),
      ),
    );
  }
}
