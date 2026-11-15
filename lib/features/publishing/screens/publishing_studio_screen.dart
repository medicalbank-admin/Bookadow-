
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../controllers/publishing_controller.dart';
import '../models/book_layout_model.dart';
import '../models/book_export_model.dart';
import 'cover_designer_screen.dart';

class PublishingStudioScreen extends StatefulWidget {
  const PublishingStudioScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
  });

  final String bookId;
  final String bookTitle;

  @override
  State<PublishingStudioScreen> createState() =>
      _PublishingStudioScreenState();
}

class _PublishingStudioScreenState
    extends State<PublishingStudioScreen> {
  late final PublishingController _controller;

  int _selectedSection = 0;

  @override
  void initState() {
    super.initState();

    _controller = PublishingController();
    _controller.initialize(widget.bookId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await _controller.saveSettings();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Publishing settings saved.'
              : _controller.errorMessage ?? 'Could not save settings.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Publishing Studio'),
            actions: [
              IconButton(
                onPressed: _controller.isSaving ? null : _save,
                tooltip: 'Save settings',
                icon: const Icon(Icons.save_outlined),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildBookHeader(),
                    _buildSectionSelector(),
                    if (_controller.errorMessage != null)
                      _buildErrorMessage(),
                    Expanded(
                      child: _buildSelectedSection(),
                    ),
                    _buildBottomBar(),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildBookHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.navy,
            AppTheme.blue,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR PUBLISHING WORKSPACE',
            style: TextStyle(
              color: AppTheme.gold,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.bookTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _controller.hasUnsavedChanges
                ? 'Unsaved publishing changes'
                : 'Your book publishing settings',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSelector() {
    final sections = [
      (Icons.menu_book_outlined, 'Interior'),
      (Icons.palette_outlined, 'Cover'),
      (Icons.picture_as_pdf_outlined, 'Export'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(sections.length, (index) {
          final selected = _selectedSection == index;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedSection = index;
                  });
                },
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.navy
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? AppTheme.navy
                          : Colors.black12,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        sections[index].$1,
                        color: selected
                            ? Colors.white
                            : AppTheme.ink,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        sections[index].$2,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppTheme.ink,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _controller.errorMessage!,
        style: TextStyle(
          color: Colors.red.shade800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSelectedSection() {
    switch (_selectedSection) {
      case 0:
        return _buildInteriorSettings();
      case 1:
        return _buildCoverSection();
      case 2:
        return _buildExportSettings();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInteriorSettings() {
    final layout = _controller.layout;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle(
          'Interior layout',
          'Choose how the pages of your book will look.',
        ),
        const SizedBox(height: 18),
        _dropdown<BookFormat>(
          label: 'Book size',
          value: layout.format,
          values: BookFormat.values,
          display: _formatName,
          onChanged: (value) {
            if (value != null) {
              _controller.updateLayout(
                layout.copyWith(format: value),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        _dropdown<String>(
          label: 'Font family',
          value: layout.fontFamily,
          values: const [
            'Georgia',
            'Garamond',
            'Times New Roman',
            'Arial',
            'Roboto',
          ],
          display: (value) => value,
          onChanged: (value) {
            if (value != null) {
              _controller.updateLayout(
                layout.copyWith(fontFamily: value),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        _sliderSetting(
          title: 'Body font size',
          value: layout.fontSize,
          min: 8,
          max: 18,
          divisions: 20,
          suffix: ' pt',
          onChanged: (value) {
            _controller.updateLayout(
              layout.copyWith(fontSize: value),
            );
          },
        ),
        _sliderSetting(
          title: 'Line spacing',
          value: layout.lineSpacing,
          min: 1,
          max: 2,
          divisions: 10,
          suffix: '×',
          onChanged: (value) {
            _controller.updateLayout(
              layout.copyWith(lineSpacing: value),
            );
          },
        ),
        _sliderSetting(
          title: 'Top margin',
          value: layout.topMargin,
          min: 0.25,
          max: 1.5,
          divisions: 25,
          suffix: '"',
          onChanged: (value) {
            _controller.updateLayout(
              layout.copyWith(topMargin: value),
            );
          },
        ),
        _sliderSetting(
          title: 'Bottom margin',
          value: layout.bottomMargin,
          min: 0.25,
          max: 1.5,
          divisions: 25,
          suffix: '"',
          onChanged: (value) {
            _controller.updateLayout(
              layout.copyWith(bottomMargin: value),
            );
          },
        ),
        _sliderSetting(
          title: 'Inside margin',
          value: layout.insideMargin,
          min: 0.25,
          max: 1.5,
          divisions: 25,
          suffix: '"',
          onChanged: (value) {
            _controller.updateLayout(
              layout.copyWith(insideMargin: value),
            );
          },
        ),
        _sliderSetting(
          title: 'Outside margin',
          value: layout.outsideMargin,
          min: 0.25,
          max: 1.5,
          divisions: 25,
          suffix: '"',
          onChanged: (value) {
            _controller.updateLayout(
              layout.copyWith(outsideMargin: value),
            );
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show page numbers'),
          value: layout.showPageNumbers,
          onChanged: (value) {
            _controller.updateLayout(
              layout.copyWith(showPageNumbers: value),
            );
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show running headers'),
          value: layout.showRunningHeaders,
          onChanged: (value) {
            _controller.updateLayout(
              layout.copyWith(showRunningHeaders: value),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCoverSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle(
          'Cover design',
          'Create the front, back, and spine of your book.',
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 38,
                color: AppTheme.gold,
              ),
              SizedBox(height: 10),
              Text(
                'Design your book cover',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Customize artwork, colors, typography, '
                'back-cover text, publisher logo, and spine.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CoverDesignerScreen(
                    controller: _controller,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.palette_outlined),
            label: const Text('Open Cover Designer'),
          ),
        ),
      ],
    );
  }

  Widget _buildExportSettings() {
    final export = _controller.export;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle(
          'Export preferences',
          'Choose how your finished book should be prepared.',
        ),
        const SizedBox(height: 18),
        _dropdown<BookExportFormat>(
          label: 'Export format',
          value: export.format,
          values: BookExportFormat.values,
          display: _exportFormatName,
          onChanged: (value) {
            if (value != null) {
              _controller.updateExport(
                export.copyWith(format: value),
              );
            }
          },
        ),
        const SizedBox(height: 18),
        _dropdown<PdfQuality>(
          label: 'Output quality',
          value: export.quality,
          values: PdfQuality.values,
          display: (value) => value.name.toUpperCase(),
          onChanged: (value) {
            if (value != null) {
              _controller.updateExport(
                export.copyWith(quality: value),
              );
            }
          },
        ),
        const SizedBox(height: 12),
        _switchSetting(
          'Include cover',
          export.includeCover,
          (value) => _controller.updateExport(
            export.copyWith(includeCover: value),
          ),
        ),
        _switchSetting(
          'Include table of contents',
          export.includeTableOfContents,
          (value) => _controller.updateExport(
            export.copyWith(includeTableOfContents: value),
          ),
        ),
        _switchSetting(
          'Include page numbers',
          export.includePageNumbers,
          (value) => _controller.updateExport(
            export.copyWith(includePageNumbers: value),
          ),
        ),
        _switchSetting(
          'Include PDF bookmarks',
          export.includeBookmarks,
          (value) => _controller.updateExport(
            export.copyWith(includeBookmarks: value),
          ),
        ),
        _switchSetting(
          'Embed fonts',
          export.embedFonts,
          (value) => _controller.updateExport(
            export.copyWith(embedFonts: value),
          ),
        ),
        _switchSetting(
          'Include print bleed',
          export.includeBleed,
          (value) => _controller.updateExport(
            export.copyWith(includeBleed: value),
          ),
        ),
        _switchSetting(
          'Right-to-left text',
          export.enableRightToLeft,
          (value) => _controller.updateExport(
            export.copyWith(enableRightToLeft: value),
          ),
        ),
        _switchSetting(
          'Grayscale output',
          export.grayscale,
          (value) => _controller.updateExport(
            export.copyWith(grayscale: value),
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: TextEditingController(
            text: export.customFileName,
          ),
          decoration: const InputDecoration(
            labelText: 'Custom export filename',
            hintText: 'My_Book',
            prefixIcon: Icon(Icons.drive_file_rename_outline),
          ),
          onChanged: (value) {
            _controller.updateExport(
              _controller.export.copyWith(
                customFileName: value,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _controller.hasUnsavedChanges
                  ? 'Changes not saved'
                  : 'All changes saved',
              style: TextStyle(
                color: _controller.hasUnsavedChanges
                    ? Colors.orange.shade800
                    : Colors.green.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _controller.isSaving ? null : _save,
            icon: _controller.isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              _controller.isSaving ? 'Saving...' : 'Save Settings',
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: AppTheme.navy,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          description,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> values,
    required String Function(T) display,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
      ),
      items: values.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(display(item)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _sliderSetting({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String suffix,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${value.toStringAsFixed(2)}$suffix',
              style: const TextStyle(
                color: AppTheme.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max).toDouble(),
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppTheme.blue,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
Widget _switchSetting(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  String _formatName(BookFormat format) {
    switch (format) {
      case BookFormat.pocket:
        return 'Pocket (5 × 8 inches)';
      case BookFormat.digest:
        return 'Digest (5.5 × 8.5 inches)';
      case BookFormat.trade:
        return 'Trade Paperback (6 × 9 inches)';
      case BookFormat.letter:
        return 'US Letter (8.5 × 11 inches)';
      case BookFormat.a4:
        return 'A4';
      case BookFormat.a5:
        return 'A5';
      case BookFormat.custom:
        return 'Custom Size';
    }
  }
  String _exportFormatName(BookExportFormat format) {
    switch (format) {
      case BookExportFormat.digitalPdf:
        return 'Digital PDF';
      case BookExportFormat.printReadyPdf:
        return 'Print-ready PDF';
      case BookExportFormat.epub:
        return 'EPUB eBook';
      case BookExportFormat.word:
        return 'Word Document';
    }
  }
}
