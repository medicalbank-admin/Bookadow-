import 'package:flutter/material.dart';

import '../../books/controllers/book_library_controller.dart';
import '../../books/models/book_model.dart';
import '../../books/screens/book_details_screen.dart';
import '../../editor/screens/chapter_editor_screen.dart';
import '../../books/repositories/sqlite_book_repository.dart';
import '../../../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final BookLibraryController _controller;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = BookLibraryController(
      repository: SqliteBookRepository(),
    );

    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _createBook() async {
    final titleController = TextEditingController();
    final authorController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create a New Book'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Book title',
                  hintText: 'Enter your book title',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: authorController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Author name',
                  hintText: 'Enter author name',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;

                Navigator.pop(dialogContext, true);
              },
              child: const Text('Create Book'),
            ),
          ],
        );
      },
    );

    if (result != true) {
      titleController.dispose();
      authorController.dispose();
      return;
    }

    final title = titleController.text.trim();
    final author = authorController.text.trim();

    titleController.dispose();
    authorController.dispose();

    try {
      final book = await _controller.createBook(
        title: title,
        authorName: author,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${book.title}" created successfully.'),
        ),
      );

      _openBook(book.id);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not create book: $error'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _openBook(String bookId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookDetailsScreen(
          bookId: bookId,
          controller: _controller,
          onOpenChapter: (chapter) {
            _openChapter(bookId, chapter);
          },
        ),
      ),
    );
  }

  void _openChapter(
    String bookId,
    ChapterModel chapter,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChapterEditorScreen(
          bookId: bookId,
          chapter: chapter,
          controller: _controller,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            if (!_controller.isInitialized &&
                _controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (_controller.errorMessage != null &&
                !_controller.isInitialized) {
              return _DatabaseErrorView(
                message: _controller.errorMessage!,
                onRetry: _controller.initialize,
              );
            }

            return IndexedStack(
              index: _selectedIndex,
              children: [
                _DashboardView(
                  controller: _controller,
                  onCreateBook: _createBook,
                  onOpenBook: _openBook,
                  onViewLibrary: () {
                    setState(() => _selectedIndex = 1);
                  },
                ),
                _LibraryView(
                  controller: _controller,
                  onCreateBook: _createBook,
                  onOpenBook: _openBook,
                ),
                const _ProfileView(),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'My Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({
    required this.controller,
    required this.onCreateBook,
    required this.onOpenBook,
    required this.onViewLibrary,
  });

  final BookLibraryController controller;
  final VoidCallback onCreateBook;
  final ValueChanged<String> onOpenBook;
  final VoidCallback onViewLibrary;

  @override
  Widget build(BuildContext context) {
    final recentBooks = controller.books.take(3).toList();

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.navy,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_stories,
                  color: AppTheme.gold,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BOOKADOW',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppTheme.navy,
                      ),
                    ),
                    Text(
                      'Your Ideas. Beautifully Bound.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: controller.refresh,
                tooltip: 'Refresh library',
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppTheme.navy,
                  AppTheme.blue,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR NEXT MASTERPIECE STARTS HERE',
                  style: TextStyle(
                    color: AppTheme.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Turn your ideas\ninto beautiful books.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Write, organize, design and prepare '
                  'your manuscript for publishing.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: onCreateBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: AppTheme.navy,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Book'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'Your Writing Overview',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.menu_book,
                  title: 'Books',
                  value: '${controller.totalBooks}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.article_outlined,
                  title: 'Chapters',
                  value: '${controller.totalChapters}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.text_fields,
                  title: 'Words',
                  value: _formatNumber(controller.totalWords),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recently Written',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewLibrary,
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (recentBooks.isEmpty)
            _EmptyBooksCard(onCreateBook: onCreateBook)
          else
            ...recentBooks.map(
              (book) => _BookCard(
                book: book,
                onTap: () => onOpenBook(book.id),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'A little progress every day adds up to big results.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryView extends StatelessWidget {
  const _LibraryView({
    required this.controller,
    required this.onCreateBook,
    required this.onOpenBook,
  });

  final BookLibraryController controller;
  final VoidCallback onCreateBook;
  final ValueChanged<String> onOpenBook;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 12, 16),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Library',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.navy,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'All your creative projects in one place.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                onPressed: onCreateBook,
                icon: const Icon(Icons.add),
                tooltip: 'Create book',
              ),
            ],
          ),
        ),
        Expanded(
          child: controller.books.isEmpty
              ? Center(
                  child: _EmptyBooksCard(
                    onCreateBook: onCreateBook,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      4,
                      16,
                      24,
                    ),
                    itemCount: controller.books.length,
                    itemBuilder: (context, index) {
                      final book = controller.books[index];

                      return _BookCard(
                        book: book,
                        onTap: () => onOpenBook(book.id),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.blue,
            size: 23,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.navy,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.book,
    required this.onTap,
  });

  final BookModel book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        leading: Container(
          width: 48,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.navy,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: AppTheme.gold,
            size: 25,
          ),
        ),
        title: Text(
          book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '${book.chapterCount} chapters  •  '
            '${book.wordCount} words',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 15,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _EmptyBooksCard extends StatelessWidget {
  const _EmptyBooksCard({
    required this.onCreateBook,
  });

  final VoidCallback onCreateBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_stories_outlined,
            size: 52,
            color: AppTheme.blue,
          ),
          const SizedBox(height: 14),
          const Text(
            'Your library is waiting.',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Create your first book and begin your '
            'writing journey with BOOKADOW.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onCreateBook,
            icon: const Icon(Icons.add),
            label: const Text('Create Your First Book'),
          ),
        ],
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: AppTheme.navy,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppTheme.gold,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Your Profile',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: AppTheme.navy,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Personalize your BOOKADOW experience.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 30),
        const _ProfileOption(
          icon: Icons.person_outline,
          title: 'Personal Information',
        ),
        const _ProfileOption(
          icon: Icons.language,
          title: 'Language Preferences',
        ),
        const _ProfileOption(
          icon: Icons.cloud_outlined,
          title: 'Backup and Synchronization',
        ),
        const _ProfileOption(
          icon: Icons.settings_outlined,
          title: 'App Settings',
        ),
        const _ProfileOption(
          icon: Icons.info_outline,
          title: 'About BOOKADOW',
        ),
        const SizedBox(height: 30),
        const Text(
          'BOOKADOW',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.blue,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Your Ideas. Beautifully Bound.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppTheme.blue,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
      ),
    );
  }
}
class _DatabaseErrorView extends StatelessWidget {
  const _DatabaseErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.storage_outlined,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to open your library',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatNumber(int number) {
  if (number < 1000) return number.toString();

  if (number < 1000000) {
    final value = number / 1000;
    return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}K';
  }

  final value = number / 1000000;
  return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}M';
}
