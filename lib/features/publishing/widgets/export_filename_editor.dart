import 'package:flutter/material.dart';

import '../models/book_export_model.dart';

class ExportFilenameEditor extends StatefulWidget {
  const ExportFilenameEditor({
    super.key,
    required this.filename,
    required this.format,
    required this.onChanged,
  });

  final String filename;
  final BookExportFormat format;
  final ValueChanged<String> onChanged;

  @override
  State<ExportFilenameEditor> createState() =>
      _ExportFilenameEditorState();
}

class _ExportFilenameEditorState
    extends State<ExportFilenameEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.filename,
    );
  }

  @override
  void didUpdateWidget(covariant ExportFilenameEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.filename != widget.filename &&
        _controller.text != widget.filename) {
      _controller.text = widget.filename;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _extension {
    switch (widget.format) {
      case BookExportFormat.digitalPdf:
      case BookExportFormat.printReadyPdf:
        return '.pdf';
      case BookExportFormat.epub:
        return '.epub';
      case BookExportFormat.word:
        return '.docx';
    }
  }

  String _cleanFilename(String value) {
    return value
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Export File Name',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _controller,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.drive_file_rename_outline),
            suffixText: _extension,
            hintText: 'Enter book filename',
            helperText: 'Special characters will be removed.',
            errorText: _controller.text.trim().isEmpty
                ? 'Filename cannot be empty.'
                : null,
          ),
          onChanged: (value) {
            widget.onChanged(_cleanFilename(value));
            setState(() {});
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Final file: ${_cleanFilename(_controller.text)}$_extension',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
