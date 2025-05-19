// FormUploadField(
//   name: 'profilePicture',
//   label: 'Profile Picture',
//   isRequired: true,
//   allowMultiple: false,
//   maxFileSizeInMB: 5,
//   mode: UploadMode.image,
//   allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
//   uploadButtonText: 'Upload Image',
//   helperText: 'Maximum size: 5MB. JPG, PNG or WebP only.',
//   validator: (files) {
//     if (files == null || files.isEmpty) {
//       return 'Please upload a profile picture';
//     }
//     return null;
//   },
// )
// FormUploadField(
//   name: 'documents',
//   label: 'Supporting Documents',
//   isRequired: true,
//   allowMultiple: true,
//   maxFiles: 5,
//   maxFileSizeInMB: 10,
//   mode: UploadMode.file,
//   allowedExtensions: ['pdf', 'doc', 'docx'],
//   uploadButtonText: 'Upload Documents',
//   helperText: 'Upload up to 5 PDF or Word documents (max 10MB each)',
//   validator: (files) {
//     if (files == null || files.isEmpty) {
//       return 'Please upload at least one document';
//     }
//     return null;
//   },
// )

import 'package:flutter/material.dart';
import 'form_base/form_field_base.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';

import 'label_text.dart';
import 'helper_text.dart';
import 'error_text.dart';

enum UploadMode { image, file }

class FormUploadField extends FormFieldBase<List<XFile>> {
  final String? label;
  final String? helperText;
  final bool isRequired;
  final bool allowMultiple;
  final int? maxFileSizeInMB;
  final int? maxFiles;
  final List<String> allowedExtensions;
  final BoxDecoration? decoration;
  final double uploadAreaHeight;
  final double? uploadAreaWidth;
  final String uploadButtonText;
  final String noFileText;
  final double previewSize;
  final double verticalSpacing;
  final void Function(List<XFile>)? onFileChanged;
  final UploadMode mode;

  const FormUploadField({
    super.key,
    required super.name,
    super.initialValue,
    super.validator,
    this.label,
    this.helperText,
    this.isRequired = false,
    this.allowMultiple = false,
    this.maxFileSizeInMB,
    this.maxFiles,
    this.allowedExtensions = const ['jpg', 'jpeg', 'png', 'webp'],
    this.decoration,
    this.uploadAreaHeight = 120,
    this.uploadAreaWidth,
    this.uploadButtonText = 'Upload File',
    this.noFileText = 'No file selected',
    this.previewSize = 80,
    this.verticalSpacing = 8.0,
    this.onFileChanged,
    this.mode = UploadMode.image,
  });

  @override
  State<FormUploadField> createState() => _FormUploadFieldState();
}

class _FormUploadFieldState
    extends FormFieldBaseState<List<XFile>, FormUploadField> {
  @override
  Widget build(BuildContext context) {
    return UploadWidget(
      label: widget.label,
      helperText: widget.helperText,
      errorText: error,
      isRequired: widget.isRequired,
      allowMultiple: widget.allowMultiple,
      maxFileSizeInMB: widget.maxFileSizeInMB,
      maxFiles: widget.maxFiles,
      allowedExtensions: widget.allowedExtensions,
      value: value ?? [],
      onChanged: (files) {
        updateValue(files);
        if (widget.onFileChanged != null) {
          widget.onFileChanged!(files);
        }
      },
      decoration: widget.decoration,
      uploadAreaHeight: widget.uploadAreaHeight,
      uploadAreaWidth: widget.uploadAreaWidth,
      uploadButtonText: widget.uploadButtonText,
      noFileText: widget.noFileText,
      previewSize: widget.previewSize,
      verticalSpacing: widget.verticalSpacing,
      mode: widget.mode,
    );
  }
}

class UploadWidget extends StatefulWidget {
  final String? label;
  final String? helperText;
  final String? errorText;
  final bool isRequired;
  final bool allowMultiple;
  final int? maxFileSizeInMB;
  final int? maxFiles;
  final List<String> allowedExtensions;
  final List<XFile>? value;
  final void Function(List<XFile>)? onChanged;
  final BoxDecoration? decoration;
  final double uploadAreaHeight;
  final double? uploadAreaWidth;
  final String uploadButtonText;
  final String noFileText;
  final double previewSize;
  final double verticalSpacing;
  final UploadMode mode;

  const UploadWidget({
    super.key,
    this.label,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.allowMultiple = false,
    this.maxFileSizeInMB,
    this.maxFiles,
    this.allowedExtensions = const ['jpg', 'jpeg', 'png', 'webp'],
    this.value,
    this.onChanged,
    this.decoration,
    this.uploadAreaHeight = 120,
    this.uploadAreaWidth,
    this.uploadButtonText = 'Upload File',
    this.noFileText = 'No file selected',
    this.previewSize = 80,
    this.verticalSpacing = 8.0,
    this.mode = UploadMode.image,
  });

  @override
  State<UploadWidget> createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  List<XFile> _files = [];
  String? _internalError;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _files = widget.value ?? [];
  }

  @override
  void didUpdateWidget(UploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      setState(() {
        _files = widget.value ?? [];
      });
    }
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result;

      if (widget.mode == UploadMode.image) {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: widget.allowedExtensions,
          allowMultiple: widget.allowMultiple,
        );
      } else {
        result = await FilePicker.platform.pickFiles(
          type:
              widget.allowedExtensions.isEmpty ? FileType.any : FileType.custom,
          allowedExtensions: widget.allowedExtensions.isEmpty
              ? null
              : widget.allowedExtensions,
          allowMultiple: widget.allowMultiple,
        );
      }

      if (result != null && result.files.isNotEmpty) {
        final newFiles = result.files.map((file) => XFile(file.path!)).toList();

        final validationError = _validateFiles(newFiles);
        if (validationError != null) {
          setState(() {
            _internalError = validationError;
          });
          return;
        }

        List<XFile> updatedFiles;
        if (widget.allowMultiple) {
          updatedFiles = [..._files, ...newFiles];

          if (widget.maxFiles != null &&
              updatedFiles.length > widget.maxFiles!) {
            setState(() {
              _internalError = 'Maximum ${widget.maxFiles} files allowed';
            });
            return;
          }
        } else {
          updatedFiles = newFiles;
        }

        setState(() {
          _files = updatedFiles;
          _internalError = null;
        });

        if (widget.onChanged != null) {
          widget.onChanged!(updatedFiles);
        }
      }
    } catch (e) {
      setState(() {
        _internalError = 'Error picking files: $e';
      });
    }
  }

  String? _validateFiles(List<XFile> files) {
    if (files.isEmpty) return null;

    for (final file in files) {
      final extension =
          path.extension(file.path).toLowerCase().replaceFirst('.', '');

      if (widget.allowedExtensions.isNotEmpty &&
          !widget.allowedExtensions.contains(extension)) {
        return 'Invalid file type. Only ${widget.allowedExtensions.join(", ")} are allowed.';
      }

      if (widget.mode == UploadMode.image) {
        final mimeType = lookupMimeType(file.path);
        if (mimeType == null || !mimeType.startsWith('image/')) {
          return 'Selected file is not a valid image';
        }
      }
    }

    if (widget.maxFileSizeInMB != null) {
      final maxSizeInBytes = widget.maxFileSizeInMB! * 1024 * 1024;

      for (final file in files) {
        final fileSize = File(file.path).lengthSync();
        if (fileSize > maxSizeInBytes) {
          return 'File size exceeds the maximum allowed size (${widget.maxFileSizeInMB}MB)';
        }
      }
    }

    return null;
  }

  void _removeFile(int index) {
    if (index < 0 || index >= _files.length) return;

    final updatedFiles = List<XFile>.from(_files)..removeAt(index);

    setState(() {
      _files = updatedFiles;
      _internalError = null;
    });

    if (widget.onChanged != null) {
      widget.onChanged!(updatedFiles);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError =
        (widget.errorText != null && widget.errorText!.isNotEmpty) ||
            (_internalError != null && _internalError!.isNotEmpty);

    final effectiveError = _internalError ?? widget.errorText;

    final isImageMode = widget.mode == UploadMode.image;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          LabelText(
            widget.label!,
            isRequired: widget.isRequired,
          ),
          SizedBox(height: widget.verticalSpacing),
        ],
        if (_files.isEmpty || widget.allowMultiple) ...[
          InkWell(
            onTap: _pickFiles,
            child: DragTarget<List<String>>(
              onWillAcceptWithDetails: (_) {
                setState(() {
                  _isDragging = true;
                });
                return true;
              },
              onAcceptWithDetails: (_) {
                setState(() {
                  _isDragging = false;
                });
                _pickFiles();
              },
              onLeave: (_) {
                setState(() {
                  _isDragging = false;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: widget.uploadAreaWidth,
                  height: widget.uploadAreaHeight,
                  decoration: widget.decoration ??
                      BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isDragging
                              ? theme.colorScheme.primary
                              : hasError
                                  ? theme.colorScheme.error
                                  : theme.dividerColor,
                          width: _isDragging ? 2 : 1,
                          style: BorderStyle.solid,
                        ),
                        color: _isDragging
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : null,
                      ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isImageMode ? Icons.image : Icons.upload_file,
                          color: _isDragging
                              ? theme.colorScheme.primary
                              : theme.disabledColor,
                          size: 36,
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          icon: Icon(isImageMode
                              ? Icons.add_photo_alternate
                              : Icons.attach_file),
                          label: Text(widget.uploadButtonText),
                          onPressed: _pickFiles,
                        ),
                        if (_files.isEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.noFileText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        if (_files.isNotEmpty) ...[
          SizedBox(height: widget.verticalSpacing),
          widget.allowMultiple
              ? _buildMultipleFilesPreview(theme)
              : _buildSingleFilePreview(theme),
        ],
        if (widget.helperText != null &&
            widget.helperText!.isNotEmpty &&
            !hasError) ...[
          SizedBox(height: widget.verticalSpacing),
          HelperText(widget.helperText!),
        ],
        if (hasError) ...[
          SizedBox(height: widget.verticalSpacing),
          ErrorMessage(errorText: effectiveError),
        ],
      ],
    );
  }

  Widget _buildSingleFilePreview(ThemeData theme) {
    if (_files.isEmpty) return const SizedBox.shrink();

    final file = _files.first;
    final isImageFile = _isImageFile(file.path);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width:
              widget.mode == UploadMode.image ? widget.previewSize * 2 : null,
          constraints: widget.mode == UploadMode.file
              ? BoxConstraints(maxWidth: widget.uploadAreaWidth ?? 300)
              : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: widget.mode == UploadMode.image || isImageFile
              ? Image.file(
                  File(file.path),
                  fit: BoxFit.cover,
                  height: widget.previewSize * 2,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildGenericFilePreview(file, theme);
                  },
                )
              : _buildGenericFilePreview(file, theme),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: Material(
            color: theme.colorScheme.error,
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              onTap: () => _removeFile(0),
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: theme.colorScheme.onError,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleFilesPreview(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected files: ${_files.length}${widget.maxFiles != null ? ' / ${widget.maxFiles}' : ''}',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_files.length, (index) {
            final file = _files[index];
            final isImageFile = _isImageFile(file.path);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: widget.previewSize,
                  height: widget.previewSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: widget.mode == UploadMode.image || isImageFile
                      ? Image.file(
                          File(file.path),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildGenericFilePreviewThumbnail(
                                file, theme);
                          },
                        )
                      : _buildGenericFilePreviewThumbnail(file, theme),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: Material(
                    color: theme.colorScheme.error,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      onTap: () => _removeFile(index),
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close,
                          size: 12,
                          color: theme.colorScheme.onError,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildGenericFilePreview(XFile file, ThemeData theme) {
    final fileName = path.basename(file.path);
    final extension =
        path.extension(file.path).toLowerCase().replaceFirst('.', '');

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getFileIconColor(extension),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                extension.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fileName,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _getFileSize(file.path),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericFilePreviewThumbnail(XFile file, ThemeData theme) {
    final extension =
        path.extension(file.path).toLowerCase().replaceFirst('.', '');

    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _getFileIconColor(extension),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  extension.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              path.basename(file.path).length > 10
                  ? '${path.basename(file.path).substring(0, 8)}...'
                  : path.basename(file.path),
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getFileIconColor(String extension) {
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'zip':
      case 'rar':
        return Colors.purple;
      case 'txt':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getFileSize(String filePath) {
    final file = File(filePath);
    final bytes = file.lengthSync();

    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      final kb = (bytes / 1024).toStringAsFixed(1);
      return '$kb KB';
    } else {
      final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
      return '$mb MB';
    }
  }

  bool _isImageFile(String filePath) {
    final mimeType = lookupMimeType(filePath);
    return mimeType != null && mimeType.startsWith('image/');
  }
}
