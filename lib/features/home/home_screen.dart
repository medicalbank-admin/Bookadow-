import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  final List<BookProject> _books = [];

  Future<void> _createBook() async {
    final controller = TextEditingController();

    final String? title = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create a new book'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Enter your book title',
              prefixIcon: Icon(Icons.menu_book_outlined),
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
                  controller.text.trim(),
                );
              },
              child: const Text('Create Book'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (title == null || title.isEmpty || !mounted) {
      return;
    }

    setState(() {
      _books.insert(
        0,
        BookProject(
          title: title,
          chapters: 0,
          wordCount: 0,
          progress: 0,
        ),
      );

      _selectedTab = 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title added to your library'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: AppTheme.navy,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: AppTheme.gold,
                size: 23,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'BOOKADOW',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
                fontSize: 17,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: SafeArea(
        child: IndexedStack(
          index: _selectedTab,
          children: [
            DashboardView(
              books: _books,
              onCreateBook: _createBook,
              onOpenLibrary: () {
                setState(() => _selectedTab = 1);
              },
            ),
            LibraryView(
              books: _books,
              onCreateBook: _createBook,
            ),
            const ProfileView(),
          ],
        ),
      ),

      floatingActionButton: _selectedTab == 2
          ? null
          : FloatingActionButton.extended(
              onPressed: _createBook,
              backgroundColor: AppTheme.navy,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Book'),
            ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
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

// ================= DASHBOARD =================

class DashboardView extends StatelessWidget {
  const DashboardView({
    super.key,
    required this.books,
    required this.onCreateBook,
    required this.onOpenLibrary,
  });

  final List<BookProject> books;
  final VoidCallback onCreateBook;
  final VoidCallback onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 110),
      children: [
        const Text(
          'YOUR CREATIVE SPACE',
          style: TextStyle(
            color: AppTheme.blue,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.7,
          ),
        ),

        const SizedBox(height: 9),

        const Text(
          'Every great book\nbegins with a page.',
          style: TextStyle(
            fontSize: 29,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: AppTheme.ink,
          ),
        ),

        const SizedBox(height: 22),

        // Main welcome banner

        Container(
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [
                AppTheme.navy,
                Color(0xFF294A6B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppTheme.gold,
                    size: 19,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'YOUR NEXT MASTERPIECE',
                    style: TextStyle(
                      color: Color(0xFFE8D6B5),
                      fontSize: 10,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              const Text(
                'Turn your ideas\ninto a real book.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Write, organize, design and publish '
                'your books in one place.',
                style: TextStyle(
                  color: Color(0xFFD6DFE9),
                  height: 1.5,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: onCreateBook,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: AppTheme.navy,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 13,
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Start a New Book'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        // Statistics

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Workspace',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextButton(
              onPressed: onOpenLibrary,
              child: const Text('View Library'),
            ),
          ],
        ),

        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.menu_book_outlined,
                value: '${books.length}',
                label: 'Books',
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: StatCard(
                icon: Icons.edit_note_rounded,
                value: '${books.fold<int>(
                  0,
                  (total, book) => total + book.wordCount,
                )}',
                label: 'Words',
              ),
            ),
            const SizedBox(width: 9),
            const Expanded(
              child: StatCard(
                icon: Icons.auto_stories_outlined,
                value: 'Ready',
                label: 'Workspace',
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),

        const Text(
          'Continue Writing',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 13),

        if (books.isEmpty)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 38,
                  color: AppTheme.blue,
                ),
                SizedBox(height: 10),
                Text(
                  'Your library is waiting.',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Create your first book and start writing.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        else
          ...books.take(3).map(
            (book) => Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: BookTile(book: book),
            ),
          ),
      ],
    );
  }
}

// ================= LIBRARY =================

class LibraryView extends StatelessWidget {
  const LibraryView({
    super.key,
    required this.books,
    required this.onCreateBook,
  });

  final List<BookProject> books;
  final VoidCallback onCreateBook;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        const Text(
          'My Library',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          '${books.length} books in your workspace',
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          decoration: InputDecoration(
            hintText: 'Search your books',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        const SizedBox(height: 20),

        if (books.isEmpty)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              children: [
                Icon(
                  Icons.library_books_outlined,
                  size: 48,
                  color: AppTheme.blue,
                ),
                SizedBox(height: 12),
                Text(
                  'No books yet',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Your next book starts here.',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          )
        else
          ...books.map(
            (book) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BookTile(book: book),
            ),
          ),

        OutlinedButton.icon(
          onPressed: onCreateBook,
          icon: const Icon(Icons.add),
          label: const Text('Create Another Book'),
        ),
      ],
    );
  }
}

// ================= BOOK TILE =================

class BookTile extends StatelessWidget {
  const BookTile({
    super.key,
    required this.book,
  });

  final BookProject book;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 74,
            decoration: BoxDecoration(
              color: const Color(0xFFE9E4D8),
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x18000000),
                  blurRadius: 5,
                  offset: Offset(2, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppTheme.navy,
              size: 29,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '${book.chapters} chapters · '
                  '${book.wordCount} words',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 10),

                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: book.progress,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFECEFF2),
                    color: AppTheme.blue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.chevron_right,
            color: Colors.black38,
          ),
        ],
      ),
    );
  }
}

// ================= STATISTICS =================

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.blue,
            size: 21,
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= PROFILE =================

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 37,
              backgroundColor: Color(0xFFE8EDF4),
              child: Icon(
                Icons.person_outline,
                size: 40,
                color: AppTheme.navy,
              ),
            ),

            SizedBox(height: 15),

            Text(
              'Your Author Profile',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),

            SizedBox(height: 7),

            Text(
              'Your account, preferences and cloud '
              'synchronization settings will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= BOOK MODEL =================

class BookProject {
  const BookProject({
    required this.title,
    required this.chapters,
    required this.wordCount,
    required this.progress,
  });

  final String title;
  final int chapters;
  final int wordCount;
  final double progress;
}
