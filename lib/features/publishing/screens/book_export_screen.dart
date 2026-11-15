import 'package:flutter/material.dart';

import '../../books/models/book_model.dart';

import '../controllers/book_export_controller.dart';
import '../models/book_export_model.dart';
import '../models/export_history_model.dart';

import '../widgets/export_format_info_widget.dart';
import 'export_result_screen.dart';

class BookExportScreen extends StatefulWidget {
  const BookExportScreen({
    super.key,
    required this.book,
  });

  final BookModel book;

  @override
  State<BookExportScreen> createState() =>
      _BookExportScreenState();
}

class _BookExportScreenState extends State<BookExportScreen> {
  late final BookExportController _controller;

  @override
  void initState() {
    super.initState();

    _controller = BookExportController(book: widget.book);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startExport() async {
    final ExportHistoryModel? result =
        await _controller.exportBook();

    if (!mounted) return;

    if (result != null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ExportResultScreen(
            filePath: result.filePath,
            fileName: result.fileName,
            onDone: () => Navigator.of(context).pop(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.errorMessage ?? 'Export failed.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Export Book'),
          ),
          body: _controller.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBookHeader(colors),
                      const SizedBox(height: 28),

                      ExportFormatInfoWidget(
                        selectedFormat:
                            _controller.settings.format,
                        onChanged: (format) {
                          _controller.updateExportSettings(
                            _controller.settings.copyWith(
                              format: format,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 25),

                      _buildExportOptions(colors),

                      const SizedBox(height: 28),

                      if (_controller.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 16,
                          ),
                          child: Text(
                            _controller.errorMessage!,
                            style: TextStyle(
                              color: colors.error,
                            ),
                          ),
                        ),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _controller.isExporting
                              ? null
                              : _startExport,
                          icon: _controller.isExporting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.file_download),
                          label: Text(
                            _controller.isExporting
                                ? 'Preparing your book...'
                                : 'Export Book',
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Center(
                        child: Text(
                          'Your exported file will be saved on your device.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildBookHeader(ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.primary.withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_stories_rounded,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(height: 14),
          Text(
            widget.book.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.book.subtitle != null &&
              widget.book.subtitle!.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              widget.book.subtitle!,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'By ${widget.book.authorName}',
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.book.chapters.length} chapters',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOptions(ColorScheme colors) {
    final BookExportModel settings = _controller.settings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export options',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        _optionTile(
          title: 'Include cover page',
          subtitle: 'Add a title page to the exported book.',
          value: settings.includeCover,
          onChanged: (value) {
            _updateSettings(
              settings.copyWith(includeCover: value),
            );
          },
        ),

        _optionTile(
          title: 'Include table of contents',
          subtitle: 'Add a contents section.',
          value: settings.includeTableOfContents,
          onChanged: (value) {
            _updateSettings(
              settings.copyWith(
                includeTableOfContents: value,
              ),
            );
          },
        ),

        _optionTile(
          title: 'Include page numbers',
          subtitle: 'Display page numbers where supported.',
          value: settings.includePageNumbers,
          onChanged: (value) {
            _updateSettings(
              settings.copyWith(
                includePageNumbers: value,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _optionTile({
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
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  void _updateSettings(BookExportModel settings) {
    _controller.updateExportSettings(settings);
  }
}
