import 'package:flutter/material.dart';

import '../models/book_cover_model.dart';
import '../models/book_layout_model.dart';
import '../screens/publishing_preflight_screen.dart';
import '../services/book_export_manager.dart';

class PublishingPreflightNavigationCard extends StatelessWidget {
  final String bookTitle;
  final String authorName;
  final String fileName;
  final List<ExportChapter> chapters;
  final BookLayoutModel layout;
  final BookCoverModel cover;
  final ValueChanged<bool>? onReviewCompleted;

  const PublishingPreflightNavigationCard({
    super.key,
    required this.bookTitle,
    required this.authorName,
    required this.fileName,
    required this.chapters,
    required this.layout,
    required this.cover,
    this.onReviewCompleted,
  });

  Future<void> _openReview(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PublishingPreflightScreen(
          bookTitle: bookTitle,
          authorName: authorName,
          fileName: fileName,
          chapters: chapters,
          layout: layout,
          cover: cover,
        ),
      ),
    );

    if (result != null) {
      onReviewCompleted?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openReview(context),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.fact_check_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Publishing Readiness Check',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Review your manuscript before exporting.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
