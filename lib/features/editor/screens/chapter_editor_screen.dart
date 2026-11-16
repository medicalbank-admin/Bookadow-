
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../theme/app_theme.dart';
import '../../books/controllers/book_liberary_controller.dart';
import '../../books/models/book_model.dart';
import '../services/editor_autosave_service.dart';

class ChapterEditorScreen extends StatefulWidget {
  const ChapterEditorScreen({
    super.key,
    required this.bookId,
    required this.chapter,
    required this.controller,
  });

  final String bookId;
  final ChapterModel chapter;
  final BookLibraryController controller;

  @override
  State<ChapterEditorScreen> createState() =>
      _ChapterEditorScreenState();
}

class _ChapterEditorScreenState extends State<ChapterEditorScreen> {
  late final QuillController _quillController;
  late final EditorAutosaveService _autosaveService;

  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  bool _isLeaving = false;

  String _lastSavedContent = '';

  @override
  void initState() {
    super.initState();

    _loadDocument();

    _autosaveService = EditorAutosaveService(
      onSave: () => _saveChapter(),
      delay: const Duration(seconds: 2),
      onError: _handleAutosaveError,
    );

    _quillController.addListener(_onDocumentChanged);
  }

  void _loadDocument() {
    try {
      final decoded = jsonDecode(widget.chapter.contentJson);

      final document = Document.fromJson(
        List<dynamic>.from(decoded as List),
      );

      _quillController = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (_) {
      _quillController = QuillController.basic();
    }

    _lastSavedContent = _currentContent;
  }

  String get _currentContent {
    return jsonEncode(
      _quillController.document.toDelta().toJson(),
    );
  }

  void _onDocumentChanged() {
    if (!mounted) return;

    final changed = _currentContent != _lastSavedContent;

    setState(() {
      _hasUnsavedChanges = changed;
    });

    if (changed) {
      _autosaveService.schedule();
    } else {
      _autosaveService.cancel();
    }
  }

  Future<void> _saveChapter({
    bool showFeedback = false,
  }) async {
    if (_isSaving || !_hasUnsavedChanges) return;

    final content = _currentContent;

    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }

    try {
      final updatedChapter = widget.chapter.copyWith(
        contentJson: content,
        updatedAt: DateTime.now(),
      );

      await widget.controller.updateChapter(
        bookId: widget.bookId,
        chapter: updatedChapter,
      );

      _lastSavedContent = content;

      if (!mounted) return;

      setState(() {
        _hasUnsavedChanges = _currentContent != content;
      });

      if (showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chapter saved successfully.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to save chapter: $error'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      } else {
        rethrow;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _handleAutosaveError(Object error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Automatic saving failed: $error'),
        backgroundColor: Colors.red.shade700,
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            _autosaveService.schedule();
          },
        ),
      ),
    );
  }

  Future<bool> _confirmLeaving() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'You have changes that have not been saved. '
            'Would you like to save before leaving?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Discard'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, null);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == false) return false;

    if (result == true) return true;

    try {
      await _autosaveService.saveNow();
      return !_hasUnsavedChanges;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save changes: $error'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }

      return false;
    }
  }

  Future<void> _handleBack() async {
    if (_isLeaving || _isSaving) return;

    final canLeave = await _confirmLeaving();

    if (!mounted || !canLeave) return;

    _isLeaving = true;
    Navigator.of(context).pop();
  }

  Future<void> _manualSave() async {
    _autosaveService.cancel();

    try {
      await _saveChapter(showFeedback: true);
    } catch (_) {
      // The save method already displays the error.
    }
  }

  @override
  void dispose() {
    _autosaveService.dispose();
    _quillController.removeListener(_onDocumentChanged);
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges && !_isSaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.chapter.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _isSaving
                    ? 'Saving...'
                    : _hasUnsavedChanges
                        ? 'Changes pending'
                        : 'All changes saved',
                style: TextStyle(
                  fontSize: 11,
                  color: _isSaving
                      ? AppTheme.blue
                      : _hasUnsavedChanges
                          ? Colors.orange.shade700
                          : Colors.green.shade700,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Undo',
              onPressed: _quillController.hasUndo
                  ? _quillController.undo
                  : null,
              icon: const Icon(Icons.undo),
            ),
            IconButton(
              tooltip: 'Redo',
              onPressed: _quillController.hasRedo
                  ? _quillController.redo
                  : null,
              icon: const Icon(Icons.redo),
            ),
            IconButton(
              tooltip: 'Save chapter',
              onPressed: _isSaving || !_hasUnsavedChanges
                  ? null
                  : _manualSave,
              icon: const Icon(Icons.save_outlined),
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: QuillSimpleToolbar(
                  controller: _quillController,
                  config: const QuillSimpleToolbarConfig(
                    showBoldButton: true,
                    showItalicButton: true,
                    showUnderLineButton: true,
                    showStrikeThrough: true,
                    showColorButton: true,
                    showBackgroundColorButton: true,
                    showHeaderStyle: true,
                    showListBullets: true,
                    showListNumbers: true,
                    showQuote: true,
                    showIndent: true,
                    showLink: true,
                    showUndo: true,
                    showRedo: true,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 18,
                  ),
                  child: QuillEditor.basic(
                    controller: _quillController,
                    config: const QuillEditorConfig(
                      placeholder: 'Start writing your chapter...',
                      padding: EdgeInsets.zero,
                      expands: true,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.paper,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedBuilder(
  animation: _quillController,
  builder: (context, child) {
                        final text = _quillController.document
                            .toPlainText()
                            .trim();

                        final words = text.isEmpty
                            ? 0
                            : text
                                .split(RegExp(r'\s+'))
                                .where((word) => word.isNotEmpty)
                                .length;

                        return Text(
                          '$words words',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    if (_isSaving)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    else
                      Icon(
                        _hasUnsavedChanges
                            ? Icons.edit
                            : Icons.cloud_done_outlined,
                        size: 16,
                        color: _hasUnsavedChanges
                            ? Colors.orange
                            : Colors.green,
                      ),
                    const SizedBox(width: 6),
                    Text(
                      _isSaving
                          ? 'Saving'
                          : _hasUnsavedChanges
                              ? 'Autosave pending'
                              : 'Saved locally',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
