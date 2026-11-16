
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../controllers/book_liberary_controller.dart';
import '../models/book_model.dart';

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({
    super.key,
    required this.bookId,
    required this.controller,
    required this.onOpenChapter,
  });

  final String bookId;
  final BookLibraryController controller;
  final ValueChanged<ChapterModel> onOpenChapter;

  @override
  State<BookDetailsScreen> createState() =>
      _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  bool _isWorking = false;

  BookModel? get _book => widget.controller.getBook(widget.bookId);

  Future<void> _addChapter() async {
    final title = await _showTitleDialog(
      title: 'New Chapter',
      hint: 'Enter chapter title',
      actionLabel: 'Create Chapter',
    );

    if (title == null || title.trim().isEmpty) return;

    setState(() => _isWorking = true);

    try {
      await widget.controller.addChapter(
        bookId: widget.bookId,
        title: title.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chapter created successfully.')),
      );
    } catch (error) {
      _showError('Could not create chapter: $error');
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _renameChapter(ChapterModel chapter) async {
    final title = await _showTitleDialog(
      title: 'Rename Chapter',
      hint: 'Enter new chapter title',
      initialValue: chapter.title,
      actionLabel: 'Save Changes',
    );

    if (title == null || title.trim().isEmpty) return;

    setState(() => _isWorking = true);

    try {
      await widget.controller.updateChapter(
        bookId: widget.bookId,
        chapter: chapter.copyWith(title: title.trim()),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chapter renamed successfully.')),
      );
    } catch (error) {
      _showError('Could not rename chapter: $error');
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _deleteChapter(ChapterModel chapter) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Chapter?'),
          content: Text(
            'Are you sure you want to delete "${chapter.title}"? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isWorking = true);

    try {
      await widget.controller.deleteChapter(
        bookId: widget.bookId,
        chapterId: chapter.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chapter deleted.')),
      );
    } catch (error) {
      _showError('Could not delete chapter: $error');
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<String?> _showTitleDialog({
    required String title,
    required String hint,
    required String actionLabel,
    String initialValue = '',
  }) async {
    final textController = TextEditingController(
      text: initialValue,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: textController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: hint,
            ),
            onSubmitted: (value) {
              Navigator.pop(dialogContext, value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  textController.text,
                );
              },
              child: Text(actionLabel),
            ),
          ],
        );
      },
    );

    textController.dispose();
    return result;
  }

  Future<void> _reorderChapters(
    int oldIndex,
    int newIndex,
  ) async {
    try {
      await widget.controller.reorderChapters(
        bookId: widget.bookId,
        oldIndex: oldIndex,
        newIndex: newIndex,
      );
    } catch (error) {
      _showError('Could not reorder chapters: $error');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final book = _book;

        if (book == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Book Details'),
            ),
            body: Center(
              child: widget.controller.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Book not found.'),
            ),
          );
        }

        final chapters = [...book.chapters]
          ..sort((a, b) => a.order.compareTo(b.order));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Book Details'),
            actions: [
              IconButton(
                tooltip: 'Add chapter',
                onPressed: _isWorking ? null : _addChapter,
                icon: const Icon(Icons.add),
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _isWorking ? null : _addChapter,
            backgroundColor: AppTheme.navy,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('New Chapter'),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BookHeader(book: book),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Your Chapters',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${chapters.length} chapters',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: chapters.isEmpty
                      ? _EmptyChapters(onAdd: _addChapter)
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            4,
                            16,
                            100,
                          ),
                          itemCount: chapters.length,
                          onReorder: _reorderChapters,
                          itemBuilder: (context, index) {
                            final chapter = chapters[index];

                            return _ChapterTile(
                              key: ValueKey(chapter.id),
                              chapter: chapter,
                              number: index + 1,
                              onOpen: () {
                                widget.onOpenChapter(chapter);
                              },
                              onRename: () {
                                _renameChapter(chapter);
                              },
                              onDelete: () {
                                _deleteChapter(chapter);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BookHeader extends StatelessWidget {
  const _BookHeader({
    required this.book,
  });

  final BookModel book;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.menu_book_rounded,
            color: AppTheme.gold,
            size: 32,
          ),
          const SizedBox(height: 18),
          Text(
            book.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (book.subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              book.subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              _HeaderStat(
                icon: Icons.article_outlined,
                value: '${book.chapterCount}',
                label: 'Chapters',
              ),
              const SizedBox(width: 24),
              _HeaderStat(
                icon: Icons.text_fields,
                value: '${book.wordCount}',
                label: 'Words',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.gold, size: 19),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChapterTile extends StatelessWidget {
  const _ChapterTile({
    super.key,
    required this.chapter,
    required this.number,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
  });

  final ChapterModel chapter;
  final int number;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onOpen,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        leading: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.paper,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            number.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: AppTheme.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(
          chapter.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${chapter.wordCount} words',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.drag_handle,
              color: Colors.grey,
              size: 20,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'rename') onRename();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'rename',
                  child: Text('Rename'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChapters extends StatelessWidget {
  const _EmptyChapters({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 58,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your book is waiting for its first chapter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start writing by creating your first chapter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Create First Chapter'),
            ),
          ],
        ),
      ),
    );
  }
}
