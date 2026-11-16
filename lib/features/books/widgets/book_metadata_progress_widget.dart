import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../services/book_metadata_completeness_service.dart';

class BookMetadataProgressWidget extends StatelessWidget {
  final BookMetadataCompletenessResult result;

  const BookMetadataProgressWidget({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = result.percentage;

    final Color progressColor = percentage >= 1
        ? Colors.green
        : percentage >= 0.6
            ? AppTheme.blue
            : Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Metadata Completion',
                    style: TextStyle(
                      color: AppTheme.navy,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${result.percentageValue}%',
                  style: TextStyle(
                    color: progressColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${result.completedFields} of ${result.totalFields} fields completed',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
            if (result.isComplete) ...[
              const SizedBox(height: 14),
              const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All tracked metadata fields are complete.',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 16),
              Text(
                'Fields still missing',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 9),
              ...result.missingFields.map(
                (field) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle_outlined,
                        size: 15,
                        color: Colors.orange.shade800,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          field,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
