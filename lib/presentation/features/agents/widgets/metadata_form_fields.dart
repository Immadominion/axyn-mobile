import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../domain/models/agent_type.dart';

/// Dynamic metadata form fields based on selected agent type
class MetadataFormFields extends StatefulWidget {
  const MetadataFormFields({
    required this.agentType,
    required this.metadata,
    required this.onMetadataChanged,
    super.key,
  });

  final AgentType? agentType;
  final Map<String, dynamic> metadata;
  final ValueChanged<Map<String, dynamic>> onMetadataChanged;

  @override
  State<MetadataFormFields> createState() => _MetadataFormFieldsState();
}

class _MetadataFormFieldsState extends State<MetadataFormFields> {
  late Map<String, dynamic> _metadata;

  @override
  void initState() {
    super.initState();
    _metadata = Map.from(widget.metadata);
  }

  @override
  void didUpdateWidget(MetadataFormFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.agentType != widget.agentType) {
      _metadata.clear();
      widget.onMetadataChanged(_metadata);
    }
  }

  void _updateMetadata(String key, dynamic value) {
    setState(() {
      _metadata[key] = value;
    });
    widget.onMetadataChanged(_metadata);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.agentType == null) {
      return const SizedBox.shrink();
    }

    switch (widget.agentType!) {
      case AgentType.chat:
        return _buildChatFields();
      case AgentType.audio:
        return _buildAudioFields();
      case AgentType.image:
        return _buildImageFields();
      case AgentType.video:
        return _buildVideoFields();
      case AgentType.data:
        return _buildDataFields();
    }
  }

  Widget _buildChatFields() {
    return Column(
      children: [
        TextFormField(
          initialValue: _metadata['model'] as String? ?? 'gpt-4',
          decoration: const InputDecoration(
            labelText: 'Model Name',
            hintText: 'e.g., gpt-4, claude-3-opus',
          ),
          onChanged: (value) => _updateMetadata('model', value),
        ),
        SizedBox(height: 16.h),
        TextFormField(
          initialValue: (_metadata['temperature'] as num?)?.toString() ?? '0.7',
          decoration: const InputDecoration(
            labelText: 'Temperature (0.0 - 2.0)',
            hintText: '0.7',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          onChanged: (value) {
            final temp = double.tryParse(value);
            if (temp != null) _updateMetadata('temperature', temp);
          },
        ),
        SizedBox(height: 16.h),
        TextFormField(
          initialValue: (_metadata['maxTokens'] as int?)?.toString() ?? '2000',
          decoration: const InputDecoration(
            labelText: 'Max Tokens',
            hintText: '2000',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            final tokens = int.tryParse(value);
            if (tokens != null) _updateMetadata('maxTokens', tokens);
          },
        ),
        SizedBox(height: 16.h),
        TextFormField(
          initialValue: _metadata['authToken'] as String?,
          decoration: const InputDecoration(
            labelText: 'API Auth Token (Optional)',
            hintText: 'Bearer token for API authentication',
          ),
          obscureText: true,
          onChanged: (value) => _updateMetadata('authToken', value),
        ),
      ],
    );
  }

  Widget _buildAudioFields() {
    return Column(
      children: [
        TextFormField(
          initialValue: _metadata['fileFieldName'] as String? ?? 'audio_file',
          decoration: const InputDecoration(
            labelText: 'File Field Name',
            hintText: 'audio_file',
          ),
          onChanged: (value) => _updateMetadata('fileFieldName', value),
        ),
        SizedBox(height: 16.h),
        TextFormField(
          initialValue: _metadata['supportedFormats'] != null
              ? (_metadata['supportedFormats'] as List).join(', ')
              : 'mp3, wav, m4a',
          decoration: const InputDecoration(
            labelText: 'Supported Formats (comma-separated)',
            hintText: 'mp3, wav, m4a',
          ),
          onChanged: (value) {
            final formats = value
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
            _updateMetadata('supportedFormats', formats);
          },
        ),
        SizedBox(height: 16.h),
        SwitchListTile(
          title: const Text('Accepts Audio Files'),
          value: _metadata['acceptsAudio'] as bool? ?? true,
          onChanged: (value) => _updateMetadata('acceptsAudio', value),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildImageFields() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _metadata['imageSize'] as String? ?? '1024x1024',
          decoration: const InputDecoration(labelText: 'Image Size'),
          items: const [
            DropdownMenuItem(value: '256x256', child: Text('256x256')),
            DropdownMenuItem(value: '512x512', child: Text('512x512')),
            DropdownMenuItem(value: '1024x1024', child: Text('1024x1024')),
            DropdownMenuItem(
                value: '1024x1792', child: Text('1024x1792 (Portrait)')),
            DropdownMenuItem(
                value: '1792x1024', child: Text('1792x1024 (Landscape)')),
          ],
          onChanged: (value) => _updateMetadata('imageSize', value),
        ),
        SizedBox(height: 16.h),
        DropdownButtonFormField<String>(
          value: _metadata['quality'] as String? ?? 'standard',
          decoration: const InputDecoration(labelText: 'Quality'),
          items: const [
            DropdownMenuItem(value: 'standard', child: Text('Standard')),
            DropdownMenuItem(value: 'hd', child: Text('HD')),
          ],
          onChanged: (value) => _updateMetadata('quality', value),
        ),
        SizedBox(height: 16.h),
        TextFormField(
          initialValue: _metadata['style'] as String? ?? 'vivid',
          decoration: const InputDecoration(
            labelText: 'Style',
            hintText: 'vivid, natural',
          ),
          onChanged: (value) => _updateMetadata('style', value),
        ),
        SizedBox(height: 16.h),
        SwitchListTile(
          title: const Text('Accepts Image Input'),
          value: _metadata['acceptsImage'] as bool? ?? false,
          onChanged: (value) => _updateMetadata('acceptsImage', value),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildVideoFields() {
    return Column(
      children: [
        TextFormField(
          initialValue: _metadata['provider'] as String? ?? 'custom',
          decoration: const InputDecoration(
            labelText: 'Video Provider',
            hintText: 'runway, pika, custom',
          ),
          onChanged: (value) => _updateMetadata('provider', value),
        ),
        SizedBox(height: 16.h),
        TextFormField(
          initialValue: _metadata['duration'] as String? ?? '5',
          decoration: const InputDecoration(
            labelText: 'Video Duration (seconds)',
            hintText: '5',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => _updateMetadata('duration', value),
        ),
        SizedBox(height: 16.h),
        TextFormField(
          initialValue: _metadata['resolution'] as String? ?? '1280x720',
          decoration: const InputDecoration(
            labelText: 'Resolution',
            hintText: '1280x720, 1920x1080',
          ),
          onChanged: (value) => _updateMetadata('resolution', value),
        ),
      ],
    );
  }

  Widget _buildDataFields() {
    return Column(
      children: [
        TextFormField(
          initialValue: _metadata['provider'] as String? ?? 'custom',
          decoration: const InputDecoration(
            labelText: 'Data Provider',
            hintText: 'custom, blockchain, api',
          ),
          onChanged: (value) => _updateMetadata('provider', value),
        ),
        SizedBox(height: 16.h),
        DropdownButtonFormField<String>(
          value: _metadata['httpMethod'] as String? ?? 'POST',
          decoration: const InputDecoration(labelText: 'HTTP Method'),
          items: const [
            DropdownMenuItem(value: 'GET', child: Text('GET')),
            DropdownMenuItem(value: 'POST', child: Text('POST')),
            DropdownMenuItem(value: 'PUT', child: Text('PUT')),
          ],
          onChanged: (value) => _updateMetadata('httpMethod', value),
        ),
        SizedBox(height: 16.h),
        TextFormField(
          initialValue: (_metadata['timeout'] as int?)?.toString() ?? '30000',
          decoration: const InputDecoration(
            labelText: 'Timeout (milliseconds)',
            hintText: '30000',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            final timeout = int.tryParse(value);
            if (timeout != null) _updateMetadata('timeout', timeout);
          },
        ),
      ],
    );
  }
}
