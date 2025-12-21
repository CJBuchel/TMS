import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tms_client/views/setup/common/setting_row.dart';

/// Reusable file upload setting with browse and upload buttons
class FileUploadSetting extends StatefulWidget {
  final String label;
  final String description;
  final List<String>? allowedExtensions;
  final Future<void> Function(PlatformFile file) onUpload;
  final bool enabled;
  final String? uploadButtonLabel;

  const FileUploadSetting({
    super.key,
    required this.label,
    required this.description,
    required this.onUpload,
    this.allowedExtensions,
    this.enabled = true,
    this.uploadButtonLabel,
  });

  @override
  State<FileUploadSetting> createState() => _FileUploadSettingState();
}

class _FileUploadSettingState extends State<FileUploadSetting> {
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: widget.allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: widget.allowedExtensions,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      await widget.onUpload(_selectedFile!);
      if (mounted) {
        setState(() {
          _selectedFile = null;
          _isUploading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingRow(
      label: widget.label,
      description: widget.description,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _selectedFile?.name ?? 'No file selected',
                style: TextStyle(
                  color: _selectedFile != null
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: widget.enabled && !_isUploading ? _pickFile : null,
            icon: const Icon(Icons.folder_open),
            label: const Text('Browse'),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: widget.enabled && _selectedFile != null && !_isUploading
                ? _uploadFile
                : null,
            icon: _isUploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.upload),
            label: Text(widget.uploadButtonLabel ?? 'Upload'),
          ),
        ],
      ),
    );
  }
}
