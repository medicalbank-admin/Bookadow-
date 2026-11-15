import 'package:flutter/material.dart';

import '../models/book_export_model.dart';

class ExportQualitySettings extends StatelessWidget {
  const ExportQualitySettings({
    super.key,
    required this.export,
    required this.onChanged,
  });

  final BookExportModel export;
  final ValueChanged<BookExportModel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Export Quality & Options',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<PdfQuality>(
          initialValue: export.pdfQuality,
          decoration: const InputDecoration(
            labelText: 'PDF Quality',
            prefixIcon: Icon(Icons.high_quality_outlined),
          ),
          items: const [
            DropdownMenuItem(
              value: PdfQuality.standard,
              child: Text('Standard'),
            ),
            DropdownMenuItem(
              value: PdfQuality.high,
              child: Text('High Quality'),
            ),
            DropdownMenuItem(
              value: PdfQuality.print,
              child: Text('Professional Print'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(export.copyWith(pdfQuality: value));
            }
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<PaperType>(
          initialValue: export.paperType,
          decoration: const InputDecoration(
            labelText: 'Paper Type',
            prefixIcon: Icon(Icons.description_outlined),
          ),
          items: const [
            DropdownMenuItem(
              value: PaperType.cream,
              child: Text('Cream Paper'),
            ),
            DropdownMenuItem(
              value: PaperType.white,
              child: Text('White Paper'),
            ),
            DropdownMenuItem(
              value: PaperType.standard,
              child: Text('Standard'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(export.copyWith(paperType: value));
            }
          },
        ),
        const SizedBox(height: 12),
        const Divider(),
        _buildSwitch(
          title: 'Embed Fonts',
          subtitle: 'Include supported fonts in the PDF.',
          value: export.embedFonts,
          onChanged: (value) {
            onChanged(export.copyWith(embedFonts: value));
          },
        ),
        _buildSwitch(
          title: 'Clickable Table of Contents',
          subtitle: 'Make table of contents entries clickable.',
          value: export.clickableTableOfContents,
          onChanged: (value) {
            onChanged(
              export.copyWith(clickableTableOfContents: value),
            );
          },
        ),
        _buildSwitch(
          title: 'PDF Bookmarks',
          subtitle: 'Add navigation bookmarks for chapters.',
          value: export.includeBookmarks,
          onChanged: (value) {
            onChanged(export.copyWith(includeBookmarks: value));
          },
        ),
        _buildSwitch(
          title: 'Grayscale Output',
          subtitle: 'Prepare a black-and-white document.',
          value: export.grayscale,
          onChanged: (value) {
            onChanged(export.copyWith(grayscale: value));
          },
        ),
      ],
    );
  }

  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
