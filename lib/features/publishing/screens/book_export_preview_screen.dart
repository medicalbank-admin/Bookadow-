import 'package:flutter/material.dart';

import '../../books/models/book_model.dart';
import '../models/book_export_model.dart';
import '../models/book_layout_model.dart';

class BookExportPreviewScreen extends StatelessWidget {
  const BookExportPreviewScreen({
    super.key,
    required this.book,
    required this.settings,
    required this.layout,
    required this.onConfirmExport,
  });

  final BookModel book;
  final BookExportModel settings;
  final BookLayoutModel layout;
  final VoidCallback onConfirmExport;

  String _formatName(BookExportFormat format) {
    switch (format) {
      case BookExportFormat.digitalPdf:
        return 'Digital PDF';
      case BookExportFormat.printReadyPdf:
        return 'Print-Ready PDF';
      case BookExportFormat.epub:
        return 'EPUB';
      case BookExportFormat.word:
        return 'Microsoft Word';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Your Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 150,
                height: 205,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                      size: 35,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      book.title,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      book.authorName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              'Book information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 14),

            _infoRow('Title', book.title),
            _infoRow('Author', book.authorName),
            if (book.subtitle != null && book.subtitle!.isNotEmpty)
              _infoRow('Subtitle', book.subtitle!),
            _infoRow('Chapters', '${book.chapters.length}'),

            const SizedBox(height: 25),

            Text(
              'Export settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 14),

            _infoRow('Format', _formatName(settings.format)),
            _infoRow('Page size', layout.format.name.toUpperCase()),
            _infoRow('Font', layout.fontFamily),
            _infoRow('Font size', '${layout.fontSize} pt'),

            const SizedBox(height: 25),

            Text(
              'Included options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 10),

            _optionRow(
              'Cover page',
              settings.includeCover,
            ),
            _optionRow(
              'Table of contents',
              settings.includeTableOfContents,
            ),
            _optionRow(
              'Page numbers',
              settings.includePageNumbers,
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onConfirmExport,
                icon: const Icon(Icons.file_download_rounded),
                label: const Text('Confirm and Export'),
              ),
            ),

            const SizedBox(height: 12),

            const Center(
              child: Text(
                'You can return and change your settings before exporting.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionRow(String title, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel_outlined,
            color: enabled ? Colors.green : Colors.grey,
            size: 19,
          ),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
    );
  }
}
