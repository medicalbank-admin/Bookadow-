import 'package:flutter/material.dart';

import '../models/book_export_model.dart';

class ExportFormatInfoWidget extends StatelessWidget {
  const ExportFormatInfoWidget({
    super.key,
    required this.selectedFormat,
    required this.onChanged,
  });

  final BookExportFormat selectedFormat;
  final ValueChanged<BookExportFormat> onChanged;

  static const List<_FormatInfo> _formats = [
    _FormatInfo(
      format: BookExportFormat.digitalPdf,
      title: 'Digital PDF',
      subtitle: 'For reading and sharing',
      description:
          'Create a convenient digital book with a fixed page layout.',
      icon: Icons.picture_as_pdf_rounded,
    ),
    _FormatInfo(
      format: BookExportFormat.printReadyPdf,
      title: 'Print-Ready PDF',
      subtitle: 'For professional printing',
      description:
          'Prepare a PDF intended for printing and publishing workflows.',
      icon: Icons.print_rounded,
    ),
    _FormatInfo(
      format: BookExportFormat.epub,
      title: 'EPUB',
      subtitle: 'For digital bookstores',
      description:
          'Create an ebook format suitable for compatible reading apps.',
      icon: Icons.menu_book_rounded,
    ),
    _FormatInfo(
      format: BookExportFormat.word,
      title: 'Word Document',
      subtitle: 'For further editing',
      description:
          'Create an editable DOCX document.',
      icon: Icons.description_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose export format',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ..._formats.map((format) {
          final bool isSelected =
              selectedFormat == format.format;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onChanged(format.format),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primaryContainer.withValues(alpha: 0.45)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? colors.primary
                        : colors.outlineVariant,
                    width: isSelected ? 1.6 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        format.icon,
                        color: colors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            format.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            format.subtitle,
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            format.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected
                          ? colors.primary
                          : colors.outline,
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
    required this.format,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });

  final BookExportFormat format;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
}
