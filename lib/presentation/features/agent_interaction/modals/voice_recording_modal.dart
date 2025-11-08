import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:record/record.dart';

import 'package:axyn_mobile/core/constants/app_sizes.dart';
import 'package:axyn_mobile/core/logging/app_logger.dart';
import 'package:axyn_mobile/shared/widgets/app_modal_sheet.dart';

/// Modal for recording voice messages
///
/// Handles microphone permissions, recording, and returns the audio file
Future<File?> showVoiceRecordingModal({
  required BuildContext context,
}) async {
  return showAppModalSheet<File?>(
    context: context,
    enableDrag: false,
    builder: (context) => const _VoiceRecordingContent(),
  );
}

class _VoiceRecordingContent extends StatefulWidget {
  const _VoiceRecordingContent();

  @override
  State<_VoiceRecordingContent> createState() => _VoiceRecordingContentState();
}

class _VoiceRecordingContentState extends State<_VoiceRecordingContent> {
  final AudioRecorder _recorder = AudioRecorder();
  RecordingState _state = RecordingState.initial;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndRecord();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _checkPermissionAndRecord() async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      await _startRecording();
    } else if (status.isDenied) {
      final result = await Permission.microphone.request();
      if (result.isGranted) {
        await _startRecording();
      } else {
        setState(() {
          _state = RecordingState.permissionDenied;
        });
      }
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _state = RecordingState.permissionDenied;
      });
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        // Get temporary directory
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = '${tempDir.path}/voice_message_$timestamp.m4a';

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );

        setState(() {
          _state = RecordingState.recording;
        });

        // Start duration timer
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingDuration = Duration(seconds: timer.tick);
          });
        });

        AppLogger.d('[VoiceRecording] Started recording to: $path');
      }
    } catch (e, stack) {
      AppLogger.e('[VoiceRecording] Failed to start recording', e, stack);
      setState(() {
        _state = RecordingState.error;
      });
    }
  }

  Future<void> _stopRecording({required bool save}) async {
    try {
      _timer?.cancel();

      final path = await _recorder.stop();

      if (save && path != null) {
        final file = File(path);
        if (await file.exists()) {
          AppLogger.d(
              '[VoiceRecording] Recording saved: $path (${_recordingDuration.inSeconds}s)');
          if (mounted) {
            Navigator.of(context).pop(file);
          }
        }
      } else {
        // Delete the file if not saving
        if (path != null) {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
            AppLogger.d('[VoiceRecording] Recording cancelled and deleted');
          }
        }
        if (mounted) {
          Navigator.of(context).pop(null);
        }
      }
    } catch (e, stack) {
      AppLogger.e('[VoiceRecording] Error stopping recording', e, stack);
      if (mounted) {
        Navigator.of(context).pop(null);
      }
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            _state == RecordingState.permissionDenied
                ? 'Microphone Permission Required'
                : _state == RecordingState.error
                    ? 'Recording Failed'
                    : 'Recording Voice Message',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Content based on state
          if (_state == RecordingState.permissionDenied) ...[
            Text(
              'Please enable microphone access in Settings to record voice messages.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => openAppSettings(),
                child: const Text('Open Settings'),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancel'),
              ),
            ),
          ] else if (_state == RecordingState.error) ...[
            PhosphorIcon(
              PhosphorIconsRegular.warning,
              size: 48.sp,
              color: scheme.error,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Failed to start recording. Please try again.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Close'),
              ),
            ),
          ] else if (_state == RecordingState.recording) ...[
            // Recording animation
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.errorContainer,
              ),
              child: Center(
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.error,
                  ),
                  child: Center(
                    child: PhosphorIcon(
                      PhosphorIconsRegular.microphoneSlash,
                      size: 40.sp,
                      color: scheme.onError,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Duration
            Text(
              _formatDuration(_recordingDuration),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontFeatures: [const FontFeature.tabularFigures()],
                color: scheme.onSurface,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Recording...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: AppSpacing.xl),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _stopRecording(save: false),
                    icon: const PhosphorIcon(PhosphorIconsRegular.x),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _stopRecording(save: true),
                    icon: const PhosphorIcon(PhosphorIconsRegular.check),
                    label: const Text('Send'),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Initial/loading state
            const CircularProgressIndicator(),
            SizedBox(height: AppSpacing.md),
            Text(
              'Preparing...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],

          SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

enum RecordingState {
  initial,
  recording,
  permissionDenied,
  error,
}
