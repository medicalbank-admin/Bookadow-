
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../theme/app_theme.dart';
import '../../books/controllers/book_library_controller.dart';
import '../../books/models/book_model.dart';

class ChapterEditorScreen extends StatefulWidget {
  final String bookId;
  final ChapterModel chapter;
  final BookLibraryController controller;

  const ChapterEditorScreen({
    super.key,
    required this.bookId,
    required this.chapter,
    required this.controller,
  });

  @override
  State<ChapterEditorScreen> createState() =>
      _ChapterEditorScreenState();
}

class _ChapterEditorScreenState
    extends State<ChapterEditorScreen> {
  late final TextEditingController _titleController;
  late final QuillController _quillController;

  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.chapter.title,
    );

    _quillController = QuillController.basic();

    _loadDocument();

    _titleController.addListener(_markChanged);
    _quillController.addListener(_markChanged);
  }

  void _loadDocument() {
    try {
      final decoded = jsonDecode(widget.chapter.contentJson);

      _quillController.document = Document.fromJson(
        List<dynamic>.from(decoded as List),
      );
    } catch (_) {
      // Start with a clean document if stored content is invalid.
      _quillController.document = Document();
    }
  }

  void _markChanged() {
    if (!_hasChanges && mounted) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  String get _plainText {
    return _quillController.document.toPlainText();
  }

  int get _wordCount {
    final text = _plainText.trim();

    if (text.isEmpty) return 0;

    return text
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  int get _characterCount {
    return _plainText.trim().length;
  }

  Future<void> _saveChapter() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a chapter title.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final contentJson = jsonEncode(
        _quillController.document.toDelta().toJson(),
      );

      final updatedChapter = widget.chapter.copyWith(
        title: title,
        contentJson: contentJson,
      );

      widget.controller.updateChapter(
        bookId: widget.bookId,
        chapter: updatedChapter,
      );

      if (!mounted) return;

      setState(() {
        _hasChanges = false;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chapter saved successfully.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save chapter: $error'),
        ),
      );
    }
  }

  Future<bool> _confirmExit() async {
    if (!_hasChanges) return true;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Unsaved changes'),
          content: const Text(
            'Would you like to save your changes before leaving?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, 'stay');
              },
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, 'discard');
              },
              child: const Text('Discard'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, 'save');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == 'discard') return true;

    if (result == 'save') {
      await _saveChapter();
      return mounted && !_hasChanges;
    }

    return false;
  }

  @override
  void dispose() {
    _titleController.removeListener(_markChanged);
    _quillController.removeListener(_markChanged);

    _titleController.dispose();
    _quillController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await _confirmExit();

        if (shouldExit && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.paper,
        appBar: AppBar(
          title: const Text('Writing Studio'),
          actions: [
            IconButton(
              tooltip: 'Save chapter',
              onPressed: _isSaving ? null : _saveChapter,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildStatusBar(),
              _buildFormattingToolbar(),
              Expanded(
                child: _buildWritingPage(),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 11,
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit_note,
            color: AppTheme.blue,
            size: 21,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _hasChanges
                  ? 'Unsaved changes'
                  : 'All changes saved',
              style: TextStyle(
                color: _hasChanges
                    ? Colors.orange.shade800
                    : Colors.green.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$_wordCount words',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattingToolbar() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 5,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: QuillSimpleToolbar(
          controller: _quillController,
          config: const QuillSimpleToolbarConfig(
            multiRowsDisplay: false,
            showFontFamily: false,
            showFontSize: true,
            showBoldButton: true,
            showItalicButton: true,
            showUnderLineButton: true,
            showStrikeThrough: true,
            showColorButton: true,
            showBackgroundColorButton: true,
            showClearFormat: true,
            showHeaderStyle: true,
            showListNumbers: true,
            showListBullets: true,
            showQuote: true,
            showIndent: true,
            showLink: true,
            showUndo: true,
            showRedo: true,
          ),
        ),
      ),
    );
  }

  Widget _buildWritingPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 550,
        ),
        padding: const EdgeInsets.fromLTRB(
          22,
          24,
          22,
          35,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: AppTheme.navy,
              ),
              decoration: const InputDecoration(
                hintText: 'Chapter title',
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              height: 2,
              width: 55,
              color: AppTheme.gold,
            ),
            const SizedBox(height: 24),
            QuillEditor.basic(
              controller: _quillController,
              config: const QuillEditorConfig(
                padding: EdgeInsets.zero,
                placeholder: 'Begin writing your chapter here...',
                expands: false,
                autoFocus: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            '$_characterCount characters',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          const Text(
            'BOOKADOW',
            style: TextStyle(
              color: AppTheme.navy,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
