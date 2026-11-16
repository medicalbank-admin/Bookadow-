import 'package:flutter/material.dart';

import '../controllers/book_metadata_controller.dart';
import '../models/book_metadata_model.dart';

class BookMetadataScreen extends StatefulWidget {
  final String bookId;
  final String initialTitle;
  final String initialAuthor;

  const BookMetadataScreen({
    super.key,
    required this.bookId,
    this.initialTitle = '',
    this.initialAuthor = '',
  });

  @override
  State<BookMetadataScreen> createState() =>
      _BookMetadataScreenState();
}

class _BookMetadataScreenState extends State<BookMetadataScreen> {
  late final BookMetadataController _controller;

  final Map<String, TextEditingController> _fields = {};

  final List<_MetadataField> _fieldDefinitions = [
    _MetadataField('isbn', 'ISBN', 'Enter ISBN', Icons.numbers),
    _MetadataField('title', 'Book title', 'Enter book title', Icons.book),
    _MetadataField('subtitle', 'Subtitle', 'Enter subtitle', Icons.title),
    _MetadataField('author', 'Author', 'Enter author name', Icons.person),
    _MetadataField(
      'contributors',
      'Contributors',
      'Editors, translators, illustrators',
      Icons.groups,
    ),
    _MetadataField(
      'publisher',
      'Publisher',
      'Enter publisher name',
      Icons.business,
    ),
    _MetadataField(
      'publicationDate',
      'Publication date',
      'YYYY-MM-DD',
      Icons.calendar_today,
    ),
    _MetadataField(
      'edition',
      'Edition',
      'First Edition',
      Icons.layers,
    ),
    _MetadataField(
      'language',
      'Language code',
      'en, ur, ar',
      Icons.language,
    ),
    _MetadataField(
      'description',
      'Book description',
      'Write a professional book description',
      Icons.description,
      multiline: true,
    ),
    _MetadataField(
      'keywords',
      'Keywords',
      'Separate keywords with commas',
      Icons.key,
    ),
    _MetadataField(
      'categories',
      'Categories',
      'Enter book categories',
      Icons.category,
    ),
    _MetadataField(
      'copyright',
      'Copyright',
      'Enter copyright information',
      Icons.copyright,
    ),
    _MetadataField(
      'website',
      'Author or publisher website',
      'https://example.com',
      Icons.public,
    ),
    _MetadataField(
      'seriesName',
      'Series name',
      'Enter series name',
      Icons.menu_book,
    ),
    _MetadataField(
      'seriesNumber',
      'Series number',
      'Enter series number',
      Icons.format_list_numbered,
    ),
    _MetadataField(
      'countryOfPublication',
      'Country of publication',
      'Enter country',
      Icons.public,
    ),
  ];

  bool _fieldsLoaded = false;

  @override
  void initState() {
    super.initState();

    _controller = BookMetadataController(
      bookId: widget.bookId,
    );

    _controller.addListener(_onControllerChanged);
    _initialize();
  }

  Future<void> _initialize() async {
    await _controller.initialize();

    if (!mounted) return;

    if (!_controller.hasMetadata) {
      _controller.createMetadata(
        title: widget.initialTitle,
        author: widget.initialAuthor,
      );
    }

    _loadFields();
  }

  void _loadFields() {
    final metadata = _controller.metadata;

    if (metadata == null || _fieldsLoaded) return;

    final values = <String, String>{
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
      _fields[entry.key] = TextEditingController(
        text: entry.value,
      );
    }

    _fieldsLoaded = true;
    setState(() {});
  }

  void _onControllerChanged() {
    if (!mounted) return;

    if (!_fieldsLoaded &&
        !_controller.isLoading &&
        _controller.metadata != null) {
      _loadFields();
    } else {
      setState(() {});
    }
  }

  BookMetadataModel _buildMetadata() {
    final current = _controller.metadata!;

    return current.copyWith(
      isbn: _value('isbn'),
      title: _value('title'),
      subtitle: _value('subtitle'),
      author: _value('author'),
      contributors: _value('contributors'),
      publisher: _value('publisher'),
      publicationDate: _value('publicationDate'),
      edition: _value('edition'),
      language: _value('language'),
      description: _value('description'),
      keywords: _value('keywords'),
      categories: _value('categories'),
      copyright: _value('copyright'),
      website: _value('website'),
      seriesName: _value('seriesName'),
      seriesNumber: _value('seriesNumber'),
      countryOfPublication: _value('countryOfPublication'),
    );
  }

  String _value(String key) {
    return _fields[key]?.text.trim() ?? '';
  }

  Future<void> _saveMetadata() async {
    if (_controller.isSaving) return;

    if (_controller.metadata == null) {
      _showMessage('Metadata is not ready yet.');
      return;
    }

    _controller.updateMetadata(_buildMetadata());

    final success = await _controller.save();

    if (!mounted) return;

    if (success) {
      _showMessage('Book metadata saved successfully.');
    } else {
      _showMessage(
        _controller.errorMessage ?? 'Unable to save metadata.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();

    for (final field in _fields.values) {
      field.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Metadata'),
        actions: [
          IconButton(
            tooltip: 'Save metadata',
            onPressed: _controller.isSaving ? null : _saveMetadata,
            icon: const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _controller.errorMessage != null && !_fieldsLoaded
              ? _buildErrorState()
              : !_fieldsLoaded
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Text(
                          'Publication Information',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage the information that identifies and '
                          'describes your book.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 22),
                        _buildSection(
                          'Book Identity',
                          Icons.menu_book,
                          [
                            'isbn',
                            'title',
                            'subtitle',
                            'author',
                            'contributors',
                          ],
                        ),
                        _buildSection(
                          'Publication Details',
                          Icons.business,
                          [
                            'publisher',
                            'publicationDate',
                            'edition',
                            'language',
                            'countryOfPublication',
                          ],
                        ),
                        _buildSection(
                          'Description and Discovery',
                          Icons.search,
                          [
                            'description',
                            'keywords',
                            'categories',
                          ],
                        ),
                        _buildSection(
                          'Copyright and Online Presence',
                          Icons.verified_user_outlined,
                          [
                            'copyright',
                            'website',
                          ],
                        ),
                        _buildSection(
                          'Book Series',
                          Icons.library_books,
                          [
                            'seriesName',
                            'seriesNumber',
                          ],
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _controller.isSaving
                              ? null
                              : _saveMetadata,
                          icon: _controller.isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            _controller.isSaving
                                ? 'Saving...'
                                : 'Save Metadata',
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    List<String> fieldKeys,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...fieldKeys.map(_buildField),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String key) {
    final definition = _fieldDefinitions.firstWhere(
      (field) => field.key == key,
    );

    final controller = _fields[key]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: definition.multiline ? 5 : 1,
        minLines: definition.multiline ? 3 : 1,
        keyboardType: key == 'description'
            ? TextInputType.multiline
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: definition.label,
          hintText: definition.hint,
          prefixIcon: Icon(definition.icon),
          alignLabelWithHint: definition.multiline,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 46,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              _controller.errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _initialize,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataField {
  final String key;
  final String label;
  final String hint;
  final IconData icon;
  final bool multiline;

  const _MetadataField(
    this.key,
    this.label,
    this.hint,
    this.icon, {
    this.multiline = false,
  });
}
