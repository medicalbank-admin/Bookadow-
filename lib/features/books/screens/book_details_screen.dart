import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../controllers/book_library_controller.dart';
import '../models/book_model.dart';

class BookDetailsScreen extends StatelessWidget {
  final String bookId;
  final BookLibraryController controller;
  final ValueChanged<ChapterModel>? onOpenChapter;

  const BookDetailsScreen({
    super.key,
    required this.bookId,
    required this.controller,
    this.onOpenChapter,
  });

  Future<String?> _showTitleDialog(
    BuildContext context, {
    required String heading,
    required String initialValue,
  }) async {
    final textController = TextEditingController(
      text: initialValue,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(heading),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter title',
            ),
            onSubmitted: (value) {
              Navigator.pop(dialogContext, value.trim());
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
                  textController.text.trim(),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    textController.dispose();

    if (result == null || result.isEmpty) {
      return null;
    }

    return result;
  }

  Future<void> _addChapter(BuildContext context) async {
    final title = await _showTitleDialog(
      context,
      heading: 'New chapter',
      initialValue: '',
    );

    if (title == null) return;

    try {
      controller.addChapter(
        bookId: bookId,
        title: title,
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _renameChapter(
    BuildContext context,
    ChapterModel chapter,
  ) async {
    final title = await _showTitleDialog(
      context,
      heading: 'Rename chapter',
      initialValue: chapter.title,
    );

    if (title == null) return;

    try {
      controller.updateChapter(
        bookId: bookId,
        chapter: chapter.copyWith(title: title),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _deleteChapter(
    BuildContext context,
    ChapterModel chapter,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete chapter?'),
          content: Text(
            'Are you sure you want to delete "${chapter.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      controller.deleteChapter(
        bookId: bookId,
        chapterId: chapter.id,
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final book = controller.getBook(bookId);

        if (book == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Book')),
            body: const Center(
              child: Text('This book could not be found.'),
            ),
          );
        }

        final chapters = [...book.chapters]
          ..sort((a, b) => a.order.compareTo(b.order));

        return Scaffold(
          appBar: AppBar(
            title: Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                tooltip: 'Add chapter',
                onPressed: () => _addChapter(context),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addChapter(context),
            backgroundColor: AppTheme.navy,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('New chapter'),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.navy,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          color: AppTheme.gold,
                          size: 30,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          book.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (book.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            book.subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _BookStat(
                              icon: Icons.list_alt,
                              value: '${book.chapterCount}',
                              label: 'Chapters',
                            ),
                            const SizedBox(width: 24),
                            _BookStat(
                              icon: Icons.text_fields,
                              value: '${book.wordCount}',
                              label: 'Words',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Your chapters',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.ink,
                          ),
                        ),
                      ),
                      Text(
                        '${chapters.length} total',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: chapters.isEmpty
                      ? _EmptyChapters(
                          onCreate: () => _addChapter(context),
                        )
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            100,
                          ),
                          itemCount: chapters.length,
                          onReorder: (oldIndex, newIndex) {
                            try {
                              controller.reorderChapters(
                                bookId: bookId,
                                oldIndex: oldIndex,
                                newIndex: newIndex,
                              );
                            } catch (error) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(error.toString()),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context, index) {
                            final chapter = chapters[index];

                            return Card(
                              key: ValueKey(chapter.id),
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                onTap: onOpenChapter == null
                                    ? null
                                    : () => onOpenChapter!(chapter),
                                leading: Container(
                                  width: 42,
                                  height: 42,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppTheme.paper,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.navy,
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
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PopupMenuButton<String>(
                                      tooltip: 'Chapter options',
                                      onSelected: (action) {
                                        if (action == 'rename') {
                                          _renameChapter(
                                            context,
                                            chapter,
                                          );
                                        } else if (action == 'delete') {
                                          _deleteChapter(
                                            context,
                                            chapter,
                                          );
                                        }
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
                                    const Icon(
                                      Icons.drag_handle,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
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

class _BookStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _BookStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.gold, size: 18),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
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

class _EmptyChapters extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyChapters({
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.library_books_outlined,
              size: 58,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your story starts here',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first chapter and begin writing.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create first chapter'),
            ),
          ],
        ),
      ),
    );
  }
}
