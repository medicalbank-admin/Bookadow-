import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../controllers/book_metadata_controller.dart';
import '../models/book_metadata_model.dart';

class BookMetadataScreen extends StatefulWidget {
  final String bookId;
  final String bookTitle;
  final String authorName;

  const BookMetadataScreen({
    super.key,
    required this.bookId,
    this.bookTitle = '',
    this.authorName = '',
  });

  @override
  State<BookMetadataScreen> createState() =>
      _BookMetadataScreenState();
}

class _BookMetadataScreenState
    extends State<BookMetadataScreen> {
  late final BookMetadataController _controller;

  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _fields = {
    'isbn': TextEditingController(),
    'title': TextEditingController(),
    'subtitle': TextEditingController(),
    'author': TextEditingController(),
    'contributors': TextEditingController(),
    'publisher': TextEditingController(),
    'publicationDate': TextEditingController(),
    'edition': TextEditingController(),
    'language': TextEditingController(),
    'description': TextEditingController(),
    'keywords': TextEditingController(),
    'categories': TextEditingController(),
    'copyright': TextEditingController(),
    'website': TextEditingController(),
    'seriesName': TextEditingController(),
    'seriesNumber': TextEditingController(),
    'countryOfPublication': TextEditingController(),
  };

  bool _fieldsLoaded = false;

  @override
  void initState() {
    super.initState();

    _controller = BookMetadataController();
    _initialize();
  }

  Future<void> _initialize() async {
    await _controller.initialize(
      bookId: widget.bookId,
      title: widget.bookTitle,
      author: widget.authorName,
    );

    if (!mounted) return;

    final metadata = _controller.metadata;

    if (metadata != null) {
      _populateFields(metadata);
    }

    setState(() {
      _fieldsLoaded = true;
    });
  }

  void _populateFields(BookMetadataModel metadata) {
    final values = {
      'isbn': metadata.isbn,
      'title': metadata.title,
      'subtitle': metadata.subtitle,
      'author': metadata.author,
      'contributors': metadata.contributors,
      'publisher': metadata.publisher,
      'publicationDate': metadata.publicationDate,
      'edition': metadata.edition,
      'language': metadata.language,
      'description': metadata.description,
      'keywords': metadata.keywords,
      'categories': metadata.categories,
      'copyright': metadata.copyright,
      'website': metadata.website,
      'seriesName': metadata.seriesName,
      'seriesNumber': metadata.seriesNumber,
      'countryOfPublication': metadata.countryOfPublication,
    };

    for (final entry in values.entries) {
      _fields[entry.key]?.text = entry.value;
    }
  }

  void _updateField(String key, String value) {
    final metadata = _controller.metadata;

    if (metadata == null) return;

    final updated = metadata.copyWith(
      isbn: key == 'isbn' ? value : metadata.isbn,
      title: key == 'title' ? value : metadata.title,
      subtitle:
          key == 'subtitle' ? value : metadata.subtitle,
      author: key == 'author' ? value : metadata.author,
      contributors: key == 'contributors'
          ? value
          : metadata.contributors,
      publisher:
          key == 'publisher' ? value : metadata.publisher,
      publicationDate: key == 'publicationDate'
          ? value
          : metadata.publicationDate,
      edition: key == 'edition' ? value : metadata.edition,
      language:
          key == 'language' ? value : metadata.language,
      description: key == 'description'
          ? value
          : metadata.description,
      keywords:
          key == 'keywords' ? value : metadata.keywords,
      categories:
          key == 'categories' ? value : metadata.categories,
      copyright:
          key == 'copyright' ? value : metadata.copyright,
      website:
          key == 'website' ? value : metadata.website,
      seriesName:
          key == 'seriesName' ? value : metadata.seriesName,
      seriesNumber: key == 'seriesNumber'
          ? value
          : metadata.seriesNumber,
      countryOfPublication: key == 'countryOfPublication'
          ? value
          : metadata.countryOfPublication,
    );

    _controller.updateMetadata(updated);
  }

  Future<void> _saveMetadata() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await _controller.save();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Book metadata saved successfully.'
              : _controller.errorMessage ??
                  'Unable to save metadata.',
        ),
        backgroundColor:
            success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String key,
    String label, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: _fields[key],
        maxLines: maxLines,
        keyboardType: keyboardType,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: maxLines > 1,
          prefixIcon: null,
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
        onChanged: (value) => _updateField(key, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Metadata'),
        actions: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return IconButton(
                tooltip: 'Save metadata',
                onPressed: _controller.isSaving ||
                        !_fieldsLoaded
                    ? null
                    : _saveMetadata,
                icon: const Icon(Icons.save_outlined),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (!_fieldsLoaded || _controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_controller.metadata == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 42,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _controller.errorMessage ??
                          'Unable to load book metadata.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _initialize,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.navy,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        color: AppTheme.gold,
                        size: 35,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Publication Information',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Manage the official details of your book.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                _sectionTitle(
                  'Book Information',
                  'Basic information displayed in your publication.',
                ),
                _field(
                  'title',
                  'Book Title',
                  required: true,
                ),
                _field('subtitle', 'Subtitle'),
                _field(
                  'description',
                  'Book Description',
                  maxLines: 5,
                ),
                _field(
                  'language',
                  'Language Code',
                  hint: 'Example: en, ur, ar',
                  required: true,
                ),

                _sectionTitle(
                  'Author and Contributors',
                  'Credit the people involved in creating this book.',
                ),
                _field(
                  'author',
                  'Author Name',
                  required: true,
                ),
                _field(
                  'contributors',
                  'Contributors',
                  maxLines: 3,
                  hint: 'Editors, illustrators, translators...',
                ),

                _sectionTitle(
                  'Publishing Details',
                  'Publisher and publication information.',
                ),
                _field('publisher', 'Publisher'),
                _field(
                  'publicationDate',
                  'Publication Date',
                  hint: 'YYYY-MM-DD',
                ),
                _field(
                  'edition',
                  'Edition',
                  hint: 'Example: First Edition',
                ),
                _field(
                  'countryOfPublication',
                  'Country of Publication',
                ),
                _field('copyright', 'Copyright Information'),

                _sectionTitle(
                  'Identification and Discovery',
                  'Information used to identify and categorize your book.',
                ),
                _field(
                  'isbn',
                  'ISBN',
                  keyboardType: TextInputType.text,
                ),
                _field(
                  'keywords',
                  'Keywords',
                  maxLines: 2,
                  hint: 'Separate keywords with commas',
                ),
                _field(
                  'categories',
                  'Categories',
                  maxLines: 2,
                  hint: 'Example: Medicine, Education',
                ),

                _sectionTitle(
                  'Book Series',
                  'Optional series information.',
                ),
                _field('seriesName', 'Series Name'),
                _field(
                  'seriesNumber',
                  'Series Number',
                  keyboardType: TextInputType.number,
                ),

                _sectionTitle(
                  'Website',
                  'Official author or publisher website.',
                ),
                _field(
                  'website',
                  'Website URL',
                  hint: 'https://example.com',
                  keyboardType: TextInputType.url,
                ),

                if (_controller.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _controller.errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _controller.isSaving
                        ? null
                        : _saveMetadata,
                    icon: _controller.isSaving
                        ? const SizedBox(
                            height: 19,
                            width: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(
                      _controller.isSaving
                          ? 'Saving...'
                          : 'Save Book Metadata',
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }

    _controller.dispose();
    super.dispose();
  }
}
