import 'package:flutter/material.dart';

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
  late final TextEditingController _contentController;

  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.chapter.title,
    );

    _contentController = TextEditingController(
      text: _extractPlainText(widget.chapter.contentJson),
    );

    _titleController.addListener(_markChanged);
    _contentController.addListener(_markChanged);
  }

  String _extractPlainText(String contentJson) {
    try {
      final decoded = contentJson;

      if (decoded == ChapterModel.emptyContent) {
        return '';
      }

      return decoded;
    } catch (_) {
      return '';
    }
  }

  void _markChanged() {
    if (!_hasChanges && mounted) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  int get _wordCount {
    final text = _contentController.text.trim();

    if (text.isEmpty) return 0;

    return text
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  int get _characterCount => _contentController.text.length;

  String _encodeContent(String text) {
    final escaped = text
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"')
        .replaceAll('\n', r'\n');

    return '[{"insert":"$escaped\\n"}]';
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
      final updatedChapter = widget.chapter.copyWith(
        title: title,
        contentJson: _encodeContent(_contentController.text),
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
          content: Text('Chapter updated successfully.'),
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

  @override
  void dispose() {
    _titleController.removeListener(_markChanged);
    _contentController.removeListener(_markChanged);

    _titleController.dispose();
    _contentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !_hasChanges) return;

        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Unsaved changes'),
              content: const Text(
                'You have unsaved changes. Save before leaving?',
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
                  onPressed: () async {
                    Navigator.pop(dialogContext, false);
                    await _saveChapter();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );

        if (shouldLeave == true && mounted) {
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
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.edit_note,
                    color: AppTheme.blue,
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
                      color: AppTheme.ink,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    minHeight: 540,
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    22,
                    24,
                    22,
                    30,
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
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        height: 2,
                        width: 55,
                        color: AppTheme.gold,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _contentController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.8,
                          color: AppTheme.ink,
                        ),
                        decoration: const InputDecoration(
                          hintText:
                              'Begin writing your chapter here...',
                          border: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
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
                  Text(
                    'BOOKADOW',
                    style: TextStyle(
                      color: AppTheme.navy.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
