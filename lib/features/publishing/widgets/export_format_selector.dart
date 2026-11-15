import 'package:flutter/material.dart';

import '../models/book_export_model.dart';

class ExportFormatSelector extends StatelessWidget {
  const ExportFormatSelector({
    super.key,
    required this.selectedFormat,
    required this.onChanged,
  });

  final BookExportFormat selectedFormat;
  final ValueChanged<BookExportFormat> onChanged;

  static const Map<BookExportFormat, _FormatInfo> _formats = {
    BookExportFormat.digitalPdf: _FormatInfo(
      title: 'Digital PDF',
      description: 'Optimized for reading on phones, tablets, and computers.',
      icon: Icons.picture_as_pdf_outlined,
      extension: '.pdf',
    ),
    BookExportFormat.printReadyPdf: _FormatInfo(
      title: 'Print-Ready PDF',
      description: 'Prepared for professional book printing.',
      icon: Icons.print_outlined,
      extension: '.pdf',
    ),
    BookExportFormat.epub: _FormatInfo(
      title: 'EPUB',
      description: 'Reflowable digital book format for e-readers.',
      icon: Icons.auto_stories_outlined,
      extension: '.epub',
    ),
    BookExportFormat.word: _FormatInfo(
      title: 'Editable Word',
      description: 'An editable Microsoft Word document.',
      icon: Icons.description_outlined,
      extension: '.docx',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Export Format',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...BookExportFormat.values.map((format) {
          final info = _formats[format]!;

          final isSelected = selectedFormat == format;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onChanged(format),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF315B87).withValues(alpha: 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF315B87)
                        : Colors.grey.shade300,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      info.icon,
                      size: 27,
                      color: isSelected
                          ? const Color(0xFF315B87)
                          : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            info.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            info.extension,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF315B87),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Radio<BookExportFormat>(
                      value: format,
                      groupValue: selectedFormat,
                      onChanged: (value) {
                        if (value != null) {
                          onChanged(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _FormatInfo {
  const _FormatInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.extension,
  });

  final String title;
  final String description;
  final IconData icon;
  final String extension;
}
